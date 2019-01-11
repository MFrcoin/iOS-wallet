import BigInt

class EDAValidator: IBlockValidator {
    let difficultyEncoder: IDifficultyEncoder
    let blockHelper: IBlockHelper

    init(encoder: IDifficultyEncoder, blockHelper: IBlockHelper) {
        difficultyEncoder = encoder
        self.blockHelper = blockHelper
    }

    func validate(candidate: Block, block: Block, network: INetwork) throws {
        guard let candidateHeader = candidate.header, let blockHeader = block.header else {
            throw Block.BlockError.noHeader
        }
        if blockHeader.bits == network.maxTargetBits {
            if candidateHeader.bits != network.maxTargetBits {
                throw BlockValidatorError.notEqualBits
            }
            return
        }
        guard let cursorBlock = blockHelper.previous(for: block, index: 6) else {
            throw BlockValidatorError.noPreviousBlock
        }
        let mpt6blocks = try blockHelper.medianTimePast(block: block) - blockHelper.medianTimePast(block: cursorBlock)
        if(mpt6blocks >= 12 * 3600) {
            let pow = difficultyEncoder.decodeCompact(bits: blockHeader.bits) >> 2
            let powBits = min(difficultyEncoder.encodeCompact(from: pow), network.maxTargetBits)

            guard powBits == candidateHeader.bits else {
                throw BlockValidatorError.notEqualBits
            }
        } else {
            guard blockHeader.bits == candidateHeader.bits else {
                throw BlockValidatorError.notEqualBits
            }
        }
    }

}
