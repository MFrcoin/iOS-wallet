//
//  CoinsList.swift
//  MFCoin
//
//  Created by Admin on 09.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

struct address {
    let host: String
    let port: Int
}

struct CoinStruct {
    let index: Int
    let name: String
    let fullName: String
    let shortName: String
    let logo: String
    let addr: address
}

class CoinsList {
    static let shared = CoinsList()
    
    func coinInit(coin: SLIP.CoinType) -> CoinStruct? {
        switch coin {
        case .bitcoin:
            return CoinStruct.init(index: coin.rawValue, name: "bitcoin", fullName: getFullName(coin), shortName: "BTC", logo: "bitcoin", addr: getAddr(coin))
        case .mfcoin:
            return CoinStruct.init(index: coin.rawValue, name: "mfcoin", fullName: getFullName(coin), shortName: "MFC", logo: "mfcoin", addr: getAddr(coin))
        case .dash: return CoinStruct.init(index: coin.rawValue, name: "dash", fullName: getFullName(coin), shortName: "Dash", logo: "dash", addr: getAddr(coin))
        case .litecoin: return CoinStruct.init(index: coin.rawValue, name: "litecoin", fullName: getFullName(coin), shortName: "LTC", logo: "litecoin", addr: getAddr(coin))
        default: return nil
        }
    }
    
    private func getAddr(_ coin: SLIP.CoinType) -> address {
        switch coin {
        case .bitcoin: return address(host: "btc-cce-1.coinomi.net", port: 5001)
        case .dash: return address(host: "drk-cce-2.coinomi.net", port: 5013)
        case .litecoin: return address(host: "ltc-cce-1.coinomi.net", port: 5002)
        case .mfcoin: return address(host: "node2.mfcoin.net", port: 23000)
        default: return address(host: "", port: 0)
        }
    }
    
    private func getFullName(_ coin: SLIP.CoinType) -> String {
        switch coin {
        case .bitcoin: return "Bitcoin"
        case .mfcoin: return "MFCoin"
        case .litecoin: return "Litecoin"
        case .dash: return "Dash"
        default:
            return "not support"
        }
    }
    
    func getP2PKHPrefix(coin: CoinModel) -> UInt8? {
        switch coin.fullName {
        case "Bitcoin": return 0x00
        case "MFCoin": return 0x33
        case "Litecoin": return 0x30
        case "Dash": return 0x4C
        default: return nil
        }
    }
    
    func getPrivateKeyPrefix(coin: CoinModel) -> UInt8? {
        switch coin.fullName {
        case "Bitcoin": return 0x80
        case "MFCoin": return 0xb3
        case "Litecoin": return 0xb3
        case "Dash": return 0x4C
        default: return nil
        }
    }
    
    func getBlockchainUrl(coin: CoinModel) -> String {
        switch coin.fullName {
        case "Bitcoin": return "https://www.blockchain.com/btc/tx/"
        case "MFCoin": return "https://block.mfcoin.net/tx/"
        case "Litecoin": return "https://chain.so/tx/LTC/"
        case "Dash": return "https://explorer.dash.org/tx/"
        default: return ""
        }
    }
}
