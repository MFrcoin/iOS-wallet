import Foundation

enum AddressType: UInt8 { case pubKeyHash = 0, scriptHash = 8 }

protocol Address: class {
    var type: AddressType { get }
    var scriptType: ScriptType { get }
    var keyHash: Data { get }
    var stringValue: String { get }
}

extension Address {

    var scriptType: ScriptType {
        switch type {
            case .pubKeyHash: return .p2pkh
            case .scriptHash: return .p2sh
        }
    }

}

class LegacyAddress: Address, Equatable {
    let type: AddressType
    let keyHash: Data
    let stringValue: String

    init(type: AddressType, keyHash: Data, base58: String) {
        self.type = type
        self.keyHash = keyHash
        self.stringValue = base58
    }

    static func ==<T: Address>(lhs: LegacyAddress, rhs: T) -> Bool {
        guard let rhs = rhs as? LegacyAddress else {
            return false
        }
        return lhs.type == rhs.type && lhs.keyHash == rhs.keyHash
    }
}

class SegWitAddress: Address, Equatable {
    let type: AddressType
    let keyHash: Data
    let stringValue: String
    let version: UInt8

    var scriptType: ScriptType {
        switch type {
        case .pubKeyHash: return .p2wpkh
        case .scriptHash: return .p2wsh
        }
    }

    init(type: AddressType, keyHash: Data, bech32: String, version: UInt8) {
        self.type = type
        self.keyHash = keyHash
        self.stringValue = bech32
        self.version = version
    }

    static func ==<T: Address>(lhs: SegWitAddress, rhs: T) -> Bool {
        guard let rhs = rhs as? SegWitAddress else {
            return false
        }
        return lhs.type == rhs.type && lhs.keyHash == rhs.keyHash && lhs.version == rhs.version
    }
}

class CashAddress: Address, Equatable {
    let type: AddressType
    let keyHash: Data
    let stringValue: String
    let version: UInt8

    init(type: AddressType, keyHash: Data, cashAddrBech32: String, version: UInt8) {
        self.type = type
        self.keyHash = keyHash
        self.stringValue = cashAddrBech32
        self.version = version
    }

    static func ==<T: Address>(lhs: CashAddress, rhs: T) -> Bool {
        guard let rhs = rhs as? CashAddress else {
            return false
        }
        return lhs.type == rhs.type && lhs.keyHash == rhs.keyHash && lhs.version == rhs.version
    }

}
