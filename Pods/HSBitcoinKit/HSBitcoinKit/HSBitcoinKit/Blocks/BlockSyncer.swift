import HSCryptoKit
import RealmSwift

class BlockSyncer {

    private let listener: ISyncStateListener
    private let realmFactory: IRealmFactory
    private let network: INetwork
    private let transactionProcessor: ITransactionProcessor
    private let blockchain: IBlockchain
    private let addressManager: IAddressManager
    private let bloomFilterManager: IBloomFilterManager

    private let hashCheckpointThreshold: Int
    private var needToReDownload = false

    private let logger: Logger?

    var localDownloadedBestBlockHeight: Int32 {
        let height = realmFactory.realm.objects(Block.self).sorted(byKeyPath: "height").last?.height
        return Int32(height ?? 0)
    }

    var localKnownBestBlockHeight: Int32 {
        let realm = realmFactory.realm

        let blocks = realm.objects(Block.self).sorted(byKeyPath: "height")
        let newBlockHashesCount = realm.objects(BlockHash.self).filter("height = 0").filter { blockHash in
            return blocks.filter("reversedHeaderHashHex = %@", blockHash.reversedHeaderHashHex).first == nil
        }.count

        if let lastBlockHeight = blocks.last?.height {
            return Int32(lastBlockHeight + newBlockHashesCount)
        } else {
            return Int32(newBlockHashesCount)
        }
    }

    init(realmFactory: IRealmFactory, network: INetwork, listener: ISyncStateListener,
         transactionProcessor: ITransactionProcessor, blockchain: IBlockchain, addressManager: IAddressManager, bloomFilterManager: IBloomFilterManager,
         hashCheckpointThreshold: Int = 100, logger: Logger? = nil) {
        self.realmFactory = realmFactory
        self.network = network
        self.transactionProcessor = transactionProcessor
        self.blockchain = blockchain
        self.addressManager = addressManager
        self.bloomFilterManager = bloomFilterManager
        self.hashCheckpointThreshold = hashCheckpointThreshold
        self.listener = listener

        self.logger = logger

        let realm = realmFactory.realm
        if realm.objects(Block.self).count == 0, let checkpointBlockHeader = network.checkpointBlock.header {
            let checkpointBlock = Block(withHeader: checkpointBlockHeader, height: network.checkpointBlock.height)
            try? realm.write {
                realm.add(checkpointBlock)
            }
        }

        listener.initialBestBlockHeightUpdated(height: localDownloadedBestBlockHeight)
    }

    // We need to clear block hashes when sync peer is disconnected
    private func clearBlockHashes() throws {
        let realm = realmFactory.realm

        try realm.write {
            realm.delete(realm.objects(BlockHash.self).filter("height = 0"))
        }
    }

    private func clearNotFullBlocks() throws {
        let realm = realmFactory.realm

        let blockReversedHashes = realm.objects(BlockHash.self)
                .filter("reversedHeaderHashHex != %@", network.checkpointBlock.reversedHeaderHashHex)
                .map { $0.reversedHeaderHashHex }

        let blocksToDelete = realm.objects(Block.self).filter(NSPredicate(format: "reversedHeaderHashHex IN %@", Array(blockReversedHashes)))

        try realm.write {
            blockchain.deleteBlocks(blocks: blocksToDelete, realm: realm)
        }
    }

}

extension BlockSyncer: IBlockSyncer {

    func prepareForDownload() {
        do {
            try addressManager.fillGap()
            bloomFilterManager.regenerateBloomFilter()
            needToReDownload = false

            try clearNotFullBlocks()
            try clearBlockHashes()

            blockchain.handleFork(realm: realmFactory.realm)
        } catch {
            logger?.error(error)
        }
    }

    func downloadStarted() {
    }

    func downloadIterationCompleted() {
        if needToReDownload {
            try? addressManager.fillGap()
            bloomFilterManager.regenerateBloomFilter()
            needToReDownload = false
        }
    }

    func downloadCompleted() {
        blockchain.handleFork(realm: realmFactory.realm)
    }

    func downloadFailed() {
        prepareForDownload()
    }

    func getBlockHashes() -> [BlockHash] {
        let realm = realmFactory.realm
        let blockHashes = realm.objects(BlockHash.self).sorted(by: [SortDescriptor(keyPath: "order"), SortDescriptor(keyPath: "height")])

        return blockHashes.prefix(500).map { BlockHash(value: $0) }
    }

    func getBlockLocatorHashes(peerLastBlockHeight: Int32) -> [Data] {
        let realm = realmFactory.realm
        var blockLocatorHashes = [Data]()

        if let lastBlockHash = realm.objects(BlockHash.self).filter("height = 0").sorted(byKeyPath: "order").last {
            blockLocatorHashes.append(lastBlockHash.headerHash)
        }

        if blockLocatorHashes.isEmpty {
            realm.objects(Block.self).sorted(byKeyPath: "height", ascending: false).prefix(10).forEach { block in
                blockLocatorHashes.append(block.headerHash)
            }
        }


        let checkPointBlock = realm.objects(Block.self).filter("height = %@", peerLastBlockHeight).first ?? network.checkpointBlock
        blockLocatorHashes.append(checkPointBlock.headerHash)

        return blockLocatorHashes
    }

    func add(blockHashes: [Data]) {
        let realm = realmFactory.realm
        var lastOrder = 0

        if let lastHash = realm.objects(BlockHash.self).sorted(byKeyPath: "order").last {
            lastOrder = lastHash.order
        }

        var hashes = [BlockHash]()
        for hash in blockHashes {
            if realm.objects(BlockHash.self).filter("reversedHeaderHashHex = %@", hash.reversedHex).count == 0 {
                lastOrder = lastOrder + 1
                hashes.append(BlockHash(withHeaderHash: hash, height: 0, order: lastOrder))
            }
        }

        try? realm.write {
            realm.add(hashes)
        }
    }

    func handle(merkleBlock: MerkleBlock, maxBlockHeight: Int32) throws {
        let realm = realmFactory.realm

        var block: Block!
        try realm.write {
            if let height = merkleBlock.height {
                block = blockchain.forceAdd(merkleBlock: merkleBlock, height: height, realm: realm)
            } else {
                block = try blockchain.connect(merkleBlock: merkleBlock, realm: realm)
            }

            do {
                try transactionProcessor.process(transactions: merkleBlock.transactions, inBlock: block, skipCheckBloomFilter: self.needToReDownload, realm: realm)
            } catch _ as BloomFilterManager.BloomFilterExpired {
                self.needToReDownload = true
            }

            if !self.needToReDownload, let blockHash = realm.objects(BlockHash.self).filter("headerHash = %@", block.headerHash).first {
                realm.delete(blockHash)
            }
        }

        listener.currentBestBlockHeightUpdated(height: Int32(block.height), maxBlockHeight: maxBlockHeight)
    }

    func shouldRequestBlock(withHash hash: Data) -> Bool {
        let realm = realmFactory.realm
        return realm.objects(Block.self).filter("headerHash == %@", hash).count == 0
    }

}
