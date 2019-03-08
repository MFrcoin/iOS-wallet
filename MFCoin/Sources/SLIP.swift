// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public struct SLIP {
    /// Coin type for Level 2 of BIP44.
    ///
    /// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0044.md
    public enum CoinType: Int, CaseIterable {
        case bitcoin = 0
        case litecoin = 2
        case bitcoincash = 145
        case dash = 5
        case ethereum = 60
        case ethereumClassic = 61
        case mfcoin = 99
        case thunderToken = 1001
        case go = 6060
        case poa = 178
        case tron = 195
        case vechain = 818
        case callisto = 820
        case tomoChain = 889
        case wanchain = 5718350
        case icon = 74
        case eos = 194
    }

    /// Network type for coins with distinguished testnet keys derivation
    ///
    /// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0044.md
    public enum Network: Int {
        case main
        case test = 1
    }

    ///  Registered HD version bytes
    ///
    /// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0132.md

    public enum HDVersion: UInt32 {
        // Bitcoin
        case xpub = 0x0488b21e
        case xprv = 0x0488ade4
        case ypub = 0x049d7cb2
        case yprv = 0x049d7878
        case zpub = 0x04b24746
        case zprv = 0x04b2430c
        // Litecoin
        case ltub = 0x019da462
        case ltpv = 0x019d9cfe
        case mtub = 0x01b26ef6
        case mtpv = 0x01b26792
    }

    ///  Registered human-readable parts for BIP-0173
    ///
    /// - SeeAlso: https://github.com/satoshilabs/slips/blob/master/slip-0173.md
    public enum HRP: String, CaseIterable {
        case bitcoin = "bc"
        case bitcoinTest = "tb"
        case litecoin = "ltc"
        case litecoinTest = "tltc"
        case mfcoin = "b3"
        case bitcoincash = "bitcoincash"
        case bitcoincashTest = "bchtest"
    }
    

}
