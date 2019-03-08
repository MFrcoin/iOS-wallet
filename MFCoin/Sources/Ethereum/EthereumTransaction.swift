// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import BigInt

/// Ethereum transaction.
public struct EthereumTransaction {
    public var nonce: BigInt
    public var gasPrice: BigInt
    public var gasLimit: BigInt
    public var to: EthereumAddress?
    public var amount: BigInt
    public var payload: Data?

    // Signature values
    public var v = BigInt()
    public var r = BigInt()
    public var s = BigInt()

    /// Creates a `Transaction`.
    public init(
        nonce: BigInt,
        gasPrice: BigInt,
        gasLimit: BigInt,
        to: EthereumAddress?,
        amount: BigInt,
        payload: Data?
    ) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        self.amount = amount
        self.payload = payload
    }

    /// Signs this transaction by filling in the `v`, `r`, and `s` values.
    ///
    /// - Parameters:
    ///   - chainID: chain identifier, defaults to `1`
    ///   - hashSigner: function to use for signing the hash
    public mutating func sign(chainID: Int = 1, hashSigner: (Data) throws -> Data) rethrows {
        let signer = EIP155Signer(chainID: BigInt(chainID))
        let hash = signer.hash(transaction: self)
        let signature = try hashSigner(hash)
        (r, s, v) = signer.values(signature: signature)
    }
}
