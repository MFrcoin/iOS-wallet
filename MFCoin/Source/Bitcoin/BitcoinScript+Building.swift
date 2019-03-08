// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public extension BitcoinScript {
    /// Builds a standard 'pay to public key hash' script.
    public static func buildPayToPublicKeyHash(address: BitcoinAddress) -> BitcoinScript {
        let pubKeyHash = address.data.dropFirst()
        return BitcoinScript.buildPayToPublicKeyHash(pubKeyHash)
    }

    /// Builds a standard 'pay to public key hash' script.
    public static func buildPayToPublicKeyHash(_ hash: Data) -> BitcoinScript {
        var data = Data(capacity: 5 + hash.count)
        data.append(contentsOf: [OpCode.OP_DUP, OpCode.OP_HASH160])
        data.append(UInt8(hash.count))
        data.append(Data(hash))
        data.append(contentsOf: [OpCode.OP_EQUALVERIFY, OpCode.OP_CHECKSIG])
        return BitcoinScript(data: data)
    }

    /// Builds a standard 'pay to script hash' script.
    public static func buildPayToScriptHash(script: BitcoinScript) -> BitcoinScript {
        return buildPayToScriptHash(Crypto.sha256ripemd160(script.data))
    }

    /// Builds a standard 'pay to script hash' script.
    public static func buildPayToScriptHash(_ scriptHash: Data) -> BitcoinScript {
        precondition(scriptHash.count == 20)
        var data = Data()
        data.append(OpCode.OP_HASH160)
        data.append(UInt8(scriptHash.count))
        data.append(Data(scriptHash))
        data.append(OpCode.OP_EQUAL)
        return BitcoinScript(data: data)
    }

    /// Builds a pay-to-witness-public-key-hash (P2WPKH) script.
    public static func buildPayToWitnessPubkeyHash(_ hash: Data) -> BitcoinScript {
        precondition(hash.count == 20)
        var data = Data()
        data.append(OpCode.OP_0)
        data.append(0x14)
        data.append(Data(hash))
        return BitcoinScript(data: data)
    }

    /// Builds a pay-to-witness-script-hash (P2WSH) script.
    public static func buildPayToWitnessScriptHash(_ hash: Data) -> BitcoinScript {
        precondition(hash.count == 32)
        var data = Data()
        data.append(OpCode.OP_0)
        data.append(0x20)
        data.append(Data(hash))
        return BitcoinScript(data: data)
    }
    
    public static func buildPublicKeyUnlockingScript(signature: Data, pubkey: PublicKey, hashType: SignatureHashType) -> Data {
        var data: Data = Data([UInt8(signature.count + 1)]) + signature + UInt8(SignatureHashType.all.rawValue)
        data += VarInt(pubkey.data.count).serialized()
        data += pubkey.data
        return data
    }

    /// Encodes a small integer
    static func encodeNumber(_ n: Int) -> UInt8 {
        assert(n >= 0 && n <= 16)
        if n == 0 {
            return OpCode.OP_0
        }
        return OpCode.OP_1 + UInt8(n - 1)
    }
}

extension Data {
    init?(hex2: String) {
        let len = hex2.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex2.index(hex2.startIndex, offsetBy: i * 2)
            let k = hex2.index(j, offsetBy: 2)
            let bytes = hex2[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
