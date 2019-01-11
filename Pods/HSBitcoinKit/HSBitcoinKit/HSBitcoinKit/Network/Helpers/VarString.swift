import Foundation
import HSCryptoKit

/// Variable length string can be stored using a variable length integer followed by the string itself.
struct VarString : ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    let length: VarInt
    let value: String

    init(stringLiteral value: String) {
        self.init(value)
    }

    init(_ value: String) {
        self.value = value
        length = VarInt(value.data(using: .ascii)!.count)
    }

    func serialized() -> Data {
        var data = Data()
        data += length.serialized()
        data += value
        return data
    }
}

extension VarString : CustomStringConvertible {
    var description: String {
        return "\(value)"
    }
}
