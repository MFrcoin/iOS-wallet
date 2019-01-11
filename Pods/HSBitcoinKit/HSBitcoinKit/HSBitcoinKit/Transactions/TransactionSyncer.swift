import Foundation
import RealmSwift

class TransactionSyncer {
    private let realmFactory: IRealmFactory
    private let transactionProcessor: ITransactionProcessor
    private let addressManager: IAddressManager
    private let bloomFilterManager: IBloomFilterManager
    private let maxRetriesCount: Int
    private let retriesPeriod: Double // seconds
    private let totalRetriesPeriod: Double // seconds

    init(realmFactory: IRealmFactory, processor: ITransactionProcessor, addressManager: IAddressManager, bloomFilterManager: IBloomFilterManager,
         maxRetriesCount: Int = 3, retriesPeriod: Double = 60, totalRetriesPeriod: Double = 60 * 60 * 24) {
        self.realmFactory = realmFactory
        self.transactionProcessor = processor
        self.addressManager = addressManager
        self.bloomFilterManager = bloomFilterManager
        self.maxRetriesCount = maxRetriesCount
        self.retriesPeriod = retriesPeriod
        self.totalRetriesPeriod = totalRetriesPeriod
    }

}

extension TransactionSyncer: ITransactionSyncer {

    func pendingTransactions() -> [Transaction] {
        let realm = realmFactory.realm

        let pendingTransactions = realm.objects(Transaction.self).filter("status = %@", TransactionStatus.new.rawValue).filter { transaction in
            if let sentTransaction = realm.objects(SentTransaction.self).filter("reversedHashHex = %@", transaction.reversedHashHex).first {
                return sentTransaction.retriesCount < self.maxRetriesCount &&
                        sentTransaction.lastSendTime < CACurrentMediaTime() - self.retriesPeriod &&
                        sentTransaction.firstSendTime > CACurrentMediaTime() - self.totalRetriesPeriod
            } else {
                return true
            }
        }

        return Array(pendingTransactions)
    }

    func handle(sentTransaction transaction: Transaction) {
        let realm = realmFactory.realm

        guard let transaction = realm.objects(Transaction.self)
                .filter("reversedHashHex = %@ AND status = %@", transaction.reversedHashHex, TransactionStatus.new.rawValue)
                .first else {
            return
        }

        try? realm.write {
            if let sentTransaction = realm.objects(SentTransaction.self).filter("reversedHashHex = %@", transaction.reversedHashHex).first {
                sentTransaction.lastSendTime = CACurrentMediaTime()
                sentTransaction.retriesCount = sentTransaction.retriesCount + 1
            } else {
                realm.add(SentTransaction(reversedHashHex: transaction.reversedHashHex))
            }
        }
    }

    func handle(transactions: [Transaction]) {
        guard !transactions.isEmpty else {
            return
        }

        let realm = realmFactory.realm
        var needToUpdateBloomFilter = false

        try? realm.write {
            do {
                try self.transactionProcessor.process(transactions: transactions, inBlock: nil, skipCheckBloomFilter: false, realm: realm)
            } catch _ as BloomFilterManager.BloomFilterExpired {
                needToUpdateBloomFilter = true
            }
        }

        if needToUpdateBloomFilter {
            try? addressManager.fillGap()
            bloomFilterManager.regenerateBloomFilter()
        }
    }

    func shouldRequestTransaction(hash: Data) -> Bool {
        let realm = realmFactory.realm
        return realm.objects(Transaction.self).filter("reversedHashHex = %@ AND status = %@", hash.reversedHex, TransactionStatus.relayed.rawValue).isEmpty
    }

}
