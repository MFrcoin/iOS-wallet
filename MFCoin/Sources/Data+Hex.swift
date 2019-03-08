// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

extension Data {
    /// Initializes `Data` with a hex string representation.
    public init?(hexString: String) {
        let string: String
        if hexString.hasPrefix("0x") {
            string = String(hexString.dropFirst(2))
        } else {
            string = hexString
        }

        // Convert the string to bytes for better performance
        guard let stringData = string.data(using: .ascii, allowLossyConversion: true) else {
            return nil
        }

        self.init(capacity: string.count / 2)
        let stringBytes = Array(stringData)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            guard let high = Data.value(of: stringBytes[i]) else {
                return nil
            }
            if i < stringBytes.count - 1, let low = Data.value(of: stringBytes[i + 1]) {
                append((high << 4) | low)
            } else {
                append(high)
            }
        }
    }

    /// Converts an ASCII byte to a hex value.
    private static func value(of nibble: UInt8) -> UInt8? {
        guard let letter = String(bytes: [nibble], encoding: .ascii) else { return nil }
        return UInt8(letter, radix: 16)
    }

    /// Returns the hex string representation of the data.
    public var hexString: String {
        return map({ String(format: "%02x", $0) }).joined()
    }
}

public extension KeyedDecodingContainerProtocol {
    func decodeHexString(forKey key: Self.Key) throws -> Data {
        let hexString = try decode(String.self, forKey: key)
        guard let data = Data(hexString: hexString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected hexadecimal string")
        }
        return data
    }

    func decodeHexStringIfPresent(forKey key: Self.Key) throws -> Data? {
        guard let hexString = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let data = Data(hexString: hexString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected hexadecimal string")
        }
        return data
    }
}

public extension UInt8 {
    public func ck_bits() -> [String] {
        let totalBitsCount = MemoryLayout<UInt8>.size * 8
        
        var bitsArray = [String](repeating: "0", count: totalBitsCount)
        
        for j in 0 ..< totalBitsCount {
            let bitVal: UInt8 = 1 << UInt8(totalBitsCount - 1 - j)
            let check = self & bitVal
            
            if (check != 0) {
                bitsArray[j] = "1"
            }
        }
        return bitsArray
    }
}

public extension Data {
    public func ck_toBitArray() -> [String] {
        var toReturn = [String]()
        for num: UInt8 in bytes {
            
            toReturn.append(contentsOf: num.ck_bits())
        }
        return toReturn
    }
}

extension Data: BinaryConvertible {
    static func +(lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        return data
    }
}

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    func to(type: String.Type) -> String {
        return String(bytes: self, encoding: .ascii)!.replacingOccurrences(of: "\0", with: "")
    }
    
    func to(type: VarInt.Type) -> VarInt {
        let value: UInt64
        let length = self[0..<1].to(type: UInt8.self)
        switch length {
        case 0...252:
            value = UInt64(length)
        case 0xfd:
            value = UInt64(self[1...2].to(type: UInt16.self))
        case 0xfe:
            value = UInt64(self[1...4].to(type: UInt32.self))
        case 0xff:
            fallthrough
        default:
            value = self[1...8].to(type: UInt64.self)
        }
        return VarInt(value)
    }
}
