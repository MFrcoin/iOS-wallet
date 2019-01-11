import Foundation
import HSCryptoKit

class OpCode {
    static let p2pkhStart = Data(bytes: [OpCode.dup, OpCode.hash160])
    static let p2pkhFinish = Data(bytes: [OpCode.equalVerify, OpCode.checkSig])

    static let p2pkFinish = Data(bytes: [OpCode.checkSig])

    static let p2shStart = Data(bytes: [OpCode.hash160])
    static let p2shFinish = Data(bytes: [OpCode.equal])

    static let pFromShCodes = [checkSig, checkSigVerify, checkMultiSig, checkMultiSigVerify]

    static let pushData1: UInt8 = 0x4c
    static let pushData2: UInt8 = 0x4d
    static let pushData4: UInt8 = 0x4e
    static let dup: UInt8 = 0x76
    static let hash160: UInt8 = 0xA9
    static let equal: UInt8 = 0x87
    static let equalVerify: UInt8 = 0x88
    static let checkSig: UInt8 = 0xAC
    static let checkSigVerify: UInt8 = 0xAD
    static let checkMultiSig: UInt8 = 0xAE
    static let checkMultiSigVerify: UInt8 = 0xAF
    static let endIf: UInt8 = 0x68

    static func value(fromPush code: UInt8) -> UInt8? {
        if code == 0 {
            return 0
        }

        let represent = Int(code) - 0x50
        if represent >= 1, represent <= 16 {
            return UInt8(represent)
        }
        return nil
    }

    static func push(_ value: Int) -> Data {
        guard value != 0 else {
            return Data([0])
        }
        guard value <= 16 else {
            return Data()
        }
        return Data([UInt8(value + 0x50)])
    }

    static func push(_ data: Data) -> Data {
        let length = data.count
        var bytes = Data()

        switch length {
        case 0x00...0x4b: bytes = Data(bytes: [UInt8(length)])
        case 0x4c...0xff: bytes = Data(bytes: [OpCode.pushData1]) + UInt8(length).littleEndian
        case 0x0100...0xffff: bytes = Data(bytes: [OpCode.pushData2]) + UInt16(length).littleEndian
        case 0x10000...0xffffffff: bytes = Data(bytes: [OpCode.pushData4]) + UInt32(length).littleEndian
        default: return data
        }

        return bytes + data
    }

    static func scriptWPKH(_ data: Data, versionByte: Int = 0) -> Data {
        return OpCode.push(versionByte) + OpCode.push(data)
    }

}
