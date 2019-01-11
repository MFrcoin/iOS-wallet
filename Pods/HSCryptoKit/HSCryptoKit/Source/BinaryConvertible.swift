import Foundation

public protocol BinaryConvertible {
    static func +(lhs: Data, rhs: Self) -> Data
    static func +=(lhs: inout Data, rhs: Self)
}

public extension BinaryConvertible {
    public static func +(lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }

    public static func +=(lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension UInt8 : BinaryConvertible {}
extension UInt16 : BinaryConvertible {}
extension UInt32 : BinaryConvertible {}
extension UInt64 : BinaryConvertible {}
extension Int8 : BinaryConvertible {}
extension Int16 : BinaryConvertible {}
extension Int32 : BinaryConvertible {}
extension Int64 : BinaryConvertible {}
extension Int : BinaryConvertible {}

extension Bool : BinaryConvertible {
    public static func +(lhs: Data, rhs: Bool) -> Data {
        return lhs + (rhs ? UInt8(0x01) : UInt8(0x00)).littleEndian
    }
}

extension String : BinaryConvertible {
    public static func +(lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .ascii) else { return lhs}
        return lhs + data
    }
}

extension Data : BinaryConvertible {
    public static func +(lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        return data
    }
}
