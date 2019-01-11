import Foundation

class GetBlockHashesTask: PeerTask {

    var blockHashes = [Data]()

    private let maxAllowedIdleTime = 10.0
    private let minAllowedIdleTime = 1.0
    private let maxExpectedBlockHashesCount: Int32 = 500
    private let minExpectedBlockHashesCount: Int32 = 6

    private let blockLocatorHashes: [Data]
    private let expectedHashesMinCount: Int32
    private let allowedIdleTime: Double

    init(hashes: [Data], expectedHashesMinCount: Int32, dateGenerator: @escaping () -> Date = Date.init) {
        self.blockLocatorHashes = hashes

        var resolvedExpectedHashesMinCount = expectedHashesMinCount
        if resolvedExpectedHashesMinCount < minExpectedBlockHashesCount {
            resolvedExpectedHashesMinCount = minExpectedBlockHashesCount
        }
        if resolvedExpectedHashesMinCount > maxExpectedBlockHashesCount {
            resolvedExpectedHashesMinCount = maxExpectedBlockHashesCount
        }

        var resolvedAllowedIdleTime = Double(resolvedExpectedHashesMinCount) * maxAllowedIdleTime / Double(maxExpectedBlockHashesCount)
        if resolvedAllowedIdleTime < minAllowedIdleTime {
            resolvedAllowedIdleTime = minAllowedIdleTime
        }

        self.expectedHashesMinCount = resolvedExpectedHashesMinCount
        self.allowedIdleTime = resolvedAllowedIdleTime

        super.init(dateGenerator: dateGenerator)
    }

    override func start() {
        requester?.getBlocks(hashes: blockLocatorHashes)
        resetTimer()
    }

    override func handle(items: [InventoryItem]) -> Bool {
        let newHashes = items
                .filter { item in return item.objectType == .blockMessage }
                .map { item in return item.hash }

        guard !newHashes.isEmpty else {
            return false
        }

        resetTimer()

        for hash in newHashes {
            if blockLocatorHashes.contains(hash) {
                // If peer sends us a hash which we have in blockLocatorHashes, it means it's just a stale block hash.
                // Because, otherwise it doesn't conform with P2P protocol
                return true
            }
        }

        if blockHashes.count < newHashes.count {
            blockHashes = newHashes
        }

        if newHashes.count >= expectedHashesMinCount {
            delegate?.handle(completedTask: self)
        }

        return true
    }

    override func checkTimeout() {
        if let lastActiveTime = lastActiveTime {
            if dateGenerator().timeIntervalSince1970 - lastActiveTime > allowedIdleTime {
                delegate?.handle(completedTask: self)
            }
        }
    }

    func equalTo(_ task: GetBlockHashesTask?) -> Bool {
        guard let task = task else {
            return false
        }

        return blockLocatorHashes == task.blockLocatorHashes && expectedHashesMinCount == task.expectedHashesMinCount
    }

}
