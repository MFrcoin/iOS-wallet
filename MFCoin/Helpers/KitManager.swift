//
//  KitManager.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift

class KitManager {
    static let shared = KitManager()
    let realm = RealmHelper.shared
    let server = ServerConnect.shared
    let coinList = CoinsList.shared
    
    func createWords() {
        print("create words")
        clearAll()
        let words = "response friend student farm tumble morning also purse random tennis bullet expect"
        //MbJtMsgyx9DegEuWGgiLCSdie8NisPvPDm
        //let mnemonic = Mnemonic.init(language: .english).toString()
        //print("mnemonic \(mnemonic)")
        //Mnemonic.create(strength: .normal, language: .english)
        save(words: words.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func diffWords(words: String) -> Bool {
        guard let metaPhrase = DAKeychain.shared[Constants.MNEMONIC_KEY] else { return false }
        return words == metaPhrase
    }
    
    func initSelectedWallets() {
        let walletsCoins = realm.selCoins
        let mnemonic = getWords()
        for coin in walletsCoins {
            initHDWallet(coin, mnemonic)
        }
        FiatTicker().setPrice()
    }

    
    private func initHDWallet(_ coinModel: CoinModel, _ words: String) {
        let purpose = 44 //bip44
        let hdWallet = HDWallet.init(mnemonic: words)
        
        for i in 0...3 {
            let derPathExt = DerivationPath.init(purpose: purpose, coinType: coinModel.index, account: 0, change: 0, address: i)
            let derPathInt = DerivationPath.init(purpose: purpose, coinType: coinModel.index, account: 0, change: 1, address: i)
            
            guard let prefixPrivate = coinList.getPrivateKeyPrefix(coin: coinModel) else { return }
            let privKeyExtWif = hdWallet.getKey(at: derPathExt).toWIF(prefix: [prefixPrivate])
            let privKeyIntWif = hdWallet.getKey(at: derPathInt).toWIF(prefix: [prefixPrivate])
            
            let privKeyExt = hdWallet.getKey(at: derPathExt)
            let privKeyInt = hdWallet.getKey(at: derPathInt)
            
            guard let prefixP2PKH = coinList.getP2PKHPrefix(coin: coinModel) else {return}
            let addrLegExt = privKeyExt.publicKey(compressed: true).legacyBitcoinAddress(prefix: prefixP2PKH).base58String
            let addrLegInt = privKeyInt.publicKey(compressed: true).legacyBitcoinAddress(prefix: prefixP2PKH).base58String
            save(coinModel, derPathExt.description, addrLegExt, 0, i, privKeyExtWif)
            save(coinModel, derPathInt.description, addrLegInt, 1 ,i, privKeyIntWif)
        }
    }
    
    private func clearAll() {
        print("clear all")
        realm.clearSelectedCoins()
        DAKeychain.shared[Constants.MNEMONIC_KEY] = ""
    }
}


//MARK: GETTER
extension KitManager {
    
    func getBalances() {
        DispatchQueue.global(qos: .utility).async {
            let result = self.realm.selCoins
            for coin in result {
                try! Realm().write {
                    coin.balance = 0
                    coin.unBalance = 0
                }
                for derPath in coin.derPaths {
                    if let scriptHash = self.getRevercesScriptHash(address: derPath.address) {
                        self.server.sendRequest(coin: coin, command: .getBalanceScrH, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                            if let result = response as? GetBalance {
                                guard let confirmed = result.result.confirmed,
                                    let unconfirmed = result.result.unconfirmed else { return }
                                if confirmed > 0 || unconfirmed > 0 {
                                    try! Realm().write {
                                        derPath.balance = confirmed
                                        derPath.unBalance = unconfirmed
                                        coin.balance += derPath.balance
                                        coin.unBalance += derPath.unBalance
                                    }
                                }
                            }
                        })
                    }
                }
                DispatchQueue.main.async{
                    NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
                }
            }
        }
    }
    
    func getListunspent(_ coinUnw: CoinModel) {
        let coinRef = ThreadSafeReference(to: coinUnw)
        DispatchQueue.global(qos: .utility).async {
            //let result = self.realm.selCoins
            let bRealm = try! Realm()
            if let coin = bRealm.resolve(coinRef) {
                //for coin in result {
                for derPath in coin.derPaths {
                    
                    try! bRealm.write {
                        bRealm.delete(derPath.input)
                    }
                    if let scriptHash = self.getRevercesScriptHash(address: derPath.address) {
                        self.server.sendRequest(coin: coin, command: .listunspent, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                            if let results = response as? Listunspent {
                                try! Realm().write {
                                    for result in results.result {
                                        if self.newhash(derPath, result.tx_hash!) {
                                            let input = Input.init(result: result)
                                            derPath.input.append(input)
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                //NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
            }
        }
    }
    
    func sendTx(_ results: Results<CoinModel>, tx: String) {
        let results = ThreadSafeReference(to: results)
        DispatchQueue.global().async {
            do {
                let bRealm = try Realm()
                if let result = bRealm.resolve(results) {
                    for coin in result {
                        if let scriptHash = self.getRevercesScriptHash(address: coin.currentAddrE) {
                            let altInfo = "\"\(tx)\""
                            self.server.sendRequest(coin: coin, command: .broadcast, altInfo: altInfo, id: coin.shortName, { (response) in
                                if let list = response as? Broadcast {
                                    
                                }
                            })
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func getWords() -> String {
        print ("get words")
        guard let metaPhrase = DAKeychain.shared[Constants.MNEMONIC_KEY] else {
            createWords()
            return getWords()
        }
        if metaPhrase == "" {
            createWords()
            return getWords()
        }
        return metaPhrase
    }
    
    private func newhash(_ path: CoinDerPaths, _ hash: String) -> Bool {
        if path.input.count == 0 {return true}
        for pHash in path.input {
            if pHash.txHash == hash {
                return false
            }
        }
        return true
    }
    
    private func getRevercesScriptHash(address: String) -> String? {
        guard let addr = BitcoinAddress.init(string: address) else { return nil }
        let p2pkh = BitcoinScript.buildPayToPublicKeyHash(address: addr)
        let sha = p2pkh.bytes.sha256()
        let reversed = [UInt8](sha.reversed()).toHexString()
        return reversed
    }
}

//MARK: SAVER
extension KitManager {
    
    private func save(words: String) {
        DAKeychain.shared[Constants.MNEMONIC_KEY] = words
    }
    
    private func save(_ coin: CoinModel, _ derPath: String,
                      _ address: String, _ change: Int,
                      _ index: Int, _ wif: String) {
        let realm = try! Realm()
        try! realm.write {
            let path = coin.derPaths.filter("path = %@", derPath)
            if path.count == 0 {
                let dPath = CoinDerPaths.init(path: derPath, address: address, change: change, index: index, wif: wif)
                coin.derPaths.append(dPath)
                if coin.currentAddrE == "" && change == 0 {
                    coin.currentAddrE = address
                }
                if coin.currentAddrI == "" && change == 1 {
                    coin.currentAddrI = address
                }
            }
        }
    }
    
}



