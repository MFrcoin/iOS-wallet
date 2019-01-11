import Foundation

/// The reject message is sent when messages are rejected.
struct RejectMessage: IMessage {
    /// type of message rejected
    let message: VarString
    /// code relating to rejected message
    /// 0x01  REJECT_MALFORMED
    /// 0x10  REJECT_INVALID
    /// 0x11  REJECT_OBSOLETE
    /// 0x12  REJECT_DUPLICATE
    /// 0x40  REJECT_NONSTANDARD
    /// 0x41  REJECT_DUST
    /// 0x42  REJECT_INSUFFICIENTFEE
    /// 0x43  REJECT_CHECKPOINT
    let ccode: UInt8
    /// text version of reason for rejection
    let reason: VarString
    /// Optional extra data provided by some errors.
    /// Currently, all errors which provide this field fill it with the TXID or
    /// block header hash of the object being rejected, so the field is 32 bytes.
    let data: Data

    init(message: VarString, ccode: UInt8, reason: VarString, data: Data) {
        self.message = message
        self.ccode = ccode
        self.reason = reason
        self.data = data
    }

    init(data: Data) {
        let byteStream = ByteStream(data)

        message = byteStream.read(VarString.self)
        ccode = byteStream.read(UInt8.self)
        reason = byteStream.read(VarString.self)
        self.data = Data()
    }

    func serialized() -> Data {
        return Data()
    }

}
