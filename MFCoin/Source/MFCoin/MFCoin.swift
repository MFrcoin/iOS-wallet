//
//  MFCoin.swift
//  MFCoin
//
//  Created by Admin on 18.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation

public typealias MFCoinAddress = BitcoinAddress
public typealias MFCoinBech32Address = BitcoinBech32Address

public final class MFCoin: Bitcoin {
    
     override public var coinType: SLIP.CoinType {
        return .mfcoin
    }
    
     override public var xpubVersion: SLIP.HDVersion? {
        switch self.coinPurpose {
        case .bip44:
            return SLIP.HDVersion.xpub
        case .bip49:
            return SLIP.HDVersion.ypub
        case .bip84:
            return SLIP.HDVersion.zpub
        }
    }
    
    override public var xprvVersion: SLIP.HDVersion? {
        switch self.coinPurpose {
        case .bip44:
            return SLIP.HDVersion.xprv
        case .bip49:
            return SLIP.HDVersion.yprv
        case .bip84:
            return SLIP.HDVersion.zprv
        }
    }
    
    /// Public key hash address prefix.
    ///
    /// - SeeAlso: https://en.bitcoin.it/wiki/List_of_address_prefixes
     override public var p2pkhPrefix: UInt8 {
        switch network {
        case .main:
            return 0x33
        case .test:
            return 0x6f
        }
    }
    
    /// Private key prefix.
    ///
    /// - SeeAlso: https://en.bitcoin.it/wiki/List_of_address_prefixes
     override public var privateKeyPrefix: UInt8 {
        switch network {
        case .main:
            return 0xb3
        case .test:
            return 0xef
        }
    }
    
    /// Pay to script hash (P2SH) address prefix.
    ///
    /// - SeeAlso: https://en.bitcoin.it/wiki/List_of_address_prefixes
     override public var p2shPrefix: UInt8 {
        switch network {
        case .main:
            return 0x20
        case .test:
            return 0xc4
        }
    }
    
     override public var hrp: SLIP.HRP {
        switch network {
        case .main:
            return .mfcoin
        case .test:
            return .bitcoinTest
        }
    }
}
