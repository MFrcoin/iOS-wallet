import Foundation
import HSCryptoKit
import RealmSwift

class PublicKey: Object {

    enum InitError: Error {
        case invalid
        case wrongNetwork
    }

    let outputs = LinkingObjects(fromType: TransactionOutput.self, property: "publicKey")

    @objc dynamic var account = 0
    @objc dynamic var index = 0
    @objc dynamic var external = true
    @objc dynamic var raw = Data()
    @objc dynamic var keyHash = Data()
    @objc dynamic var scriptHashForP2WPKH = Data()
    @objc dynamic var keyHashHex: String = ""

    override class func primaryKey() -> String? {
        return "keyHashHex"
    }

    convenience init(withAccount account: Int, index: Int, external: Bool, hdPublicKeyData data: Data) {
        self.init()
        self.account = account
        self.index = index
        self.external = external
        raw = data
        keyHash = CryptoKit.sha256ripemd160(data)

        scriptHashForP2WPKH = CryptoKit.sha256ripemd160(OpCode.scriptWPKH(keyHash))
        keyHashHex = keyHash.hex
    }

}
