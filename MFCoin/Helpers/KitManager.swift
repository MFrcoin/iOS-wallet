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
        DAKeychain.shared[Constants.MNEMONIC_KEY] = ""
        DAKeychain.shared[Constants.PASSPHRASE_KEY] = ""
        let words = Mnemonic.init(language: .english).toString()
        save(words: words.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func diffWords(words: String) -> Bool {
        guard let metaPhrase = DAKeychain.shared[Constants.MNEMONIC_KEY] else { return false }
        return words == metaPhrase
    }
    
    func initSelectedWallets() {
        let walletsCoins = realm.selCoins
        let mnemonic = getWords()
        let phrase = getPhrase()
        
        for coin in walletsCoins {
            initHDWallet(coin, mnemonic, phrase, i: 0)
        }
        FiatTicker().setPrice()
    }
    
    private func initHDWallet(_ coinModel: CoinModel, _ words: String, _ phrase: String, i: Int) {
        
        let purpose = 44 //bip44
        let hdWallet = HDWallet.init(mnemonic: words, passphrase: phrase)
        
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
        
        let historyExt = getHistory(coin: coinModel, address: addrLegExt)
        let historyInt = getHistory(coin: coinModel, address: addrLegInt)
        if historyExt.count > 0 || historyInt.count > 0 {
            save(coinModel, derPathExt.description, addrLegExt, 0, i, privKeyExtWif, historyExt)
            save(coinModel, derPathInt.description, addrLegInt, 1 ,i, privKeyIntWif, nil)
            initHDWallet(coinModel, words, phrase, i: i+1)
        } else {
            save(coinModel, derPathExt.description, addrLegExt, 0, i, privKeyExtWif, nil)
            save(coinModel, derPathInt.description, addrLegInt, 1 ,i, privKeyIntWif, nil)
        }
    }
    
}


//MARK: GETTER
extension KitManager {
    
    func getOnline() {
        DispatchQueue.global(qos: .utility).async {
            let realm = try! Realm()
            let coins = RealmHelper.shared.getAllCoins()
            for coin in coins {
                ServerConnect.shared.sendRequest(coin: coin, command: .version, altInfo: "", id: coin.shortName) { (response) in
                    try! realm.write {
                        if let ping = response as? Version {
                            if ping.result != nil {
                                coin.online = true
                            } else {
                                coin.online = false
                            }
                        } 
                    }
                }
            }
        }
    }
    
    private func getHistory(coin: CoinModel, address: String) -> [History] {
        var answer = [History]()
        if let scriptHash = getRevercesScriptHash(address: address) {
            server.sendRequest(coin: coin, command: .getHistory, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                if let histories = response as? GetHistory {
                    for result in histories.result {
                        guard let txHash = result.tx_hash,
                            let height = result.height else { return }
                        let history = History(txId: txHash, height: height)
                        if self.isNewHistory(coin, history) {
                            answer.append(history)
                        }
                    }
                }
            })
        }
        return answer
    }
    
    private func isNewHistory(_ coin: CoinModel, _ history: History) -> Bool {
        for path in coin.derPaths {
            for historyPath in path.history {
                if historyPath.txId == history.txId {
                    return false
                }
            }
        }
        return true
    }
    
    func updateHistory() {
        DispatchQueue.global(qos: .utility).async {
            let walletsCoins = self.realm.selCoins
            for coin in walletsCoins {
                for path in coin.derPaths {
                    let histories = self.getHistory(coin: coin, address: path.address)
                    if histories.count > 0 {
                        try! Realm().write {
                            path.history.removeAll()
                            for history in histories {
                                path.history.append(history)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getBalances(_ coinUnw: CoinModel) {
        let coinRef = ThreadSafeReference(to: coinUnw)
        DispatchQueue.global(qos: .utility).async {
            let bRealm = try! Realm()
            if let coin = bRealm.resolve(coinRef) {
                for derPath in coin.derPaths {
                    if let scriptHash = self.getRevercesScriptHash(address: derPath.address) {
                        self.server.sendRequest(coin: coin, command: .getBalanceScrH, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                            if let balance = response as? GetBalance {
                                guard let confirmed = balance.result.confirmed,
                                    let unconfirmed = balance.result.unconfirmed else { return }
                                if confirmed > 0 || unconfirmed > 0 {
                                    try! Realm().write {
                                        derPath.balance = confirmed
                                        derPath.unBalance = unconfirmed
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getListunspent(_ coinUnw: CoinModel) {
        let coinRef = ThreadSafeReference(to: coinUnw)
        DispatchQueue.global(qos: .utility).async {
            let bRealm = try! Realm()
            if let coin = bRealm.resolve(coinRef) {
                for derPath in coin.derPaths {
                    try! bRealm.write {
                        bRealm.delete(derPath.unspent)
                    }
                    if let scriptHash = self.getRevercesScriptHash(address: derPath.address) {
                        self.server.sendRequest(coin: coin, command: .listunspent, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                            if let listunspents = response as? Listunspent {
                                try! Realm().write {
                                    for listunspent in listunspents.result {
                                        guard let hash = listunspent.tx_hash,
                                            let height = listunspent.height else {return}
                                        if height > 0 {
                                            if self.newhash(derPath, hash) {
                                                let input = Unspent.init(result: listunspent)
                                                derPath.unspent.append(input)
                                            }
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getTransactions(_ coinUnw: CoinModel) {
        let coinRef = ThreadSafeReference(to: coinUnw)
        DispatchQueue.global(qos: .utility).async {
            let bRealm = try! Realm()
            if let coin = bRealm.resolve(coinRef) {
                for derPath in coin.derPaths {
                    for history in derPath.history {
                        self.server.sendRequest(coin: coin, command: .getTransactions, altInfo: "\"\(history.txId)\", true", id: coin.shortName, { (response) in
                            if let txHistory = response as? GetTxHistory {
                                let cRealm = try! Realm()
                                let txid = txHistory.result.txid
                                let result = cRealm.objects(TxHistory.self).filter("txid = %@", txid)
                                try! cRealm.write {
                                    if result.count == 1 {
                                        result[0].confirmation = txHistory.result.confirmations ?? 0
                                        if let time = txHistory.result.time {
                                            if time > 0 {
                                                result[0].date = time
                                                result[0].nowDate = (time - Int(Date.timeIntervalBetween1970AndReferenceDate*1000))
                                            }
                                        }
                                    } else {
                                        let history = TxHistory(coin: coin, tx: txHistory,
                                                                address: derPath.address, change: derPath.change)
                                        cRealm.delete(result)
                                        cRealm.add(history)
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func getWords() -> String {
        guard let metaPhrase = DAKeychain.shared[Constants.MNEMONIC_KEY] else {
            return ""
        }
        return metaPhrase
    }
    
    func getPhrase() -> String {
        guard let phrase = DAKeychain.shared[Constants.PASSPHRASE_KEY] else {
            return ""
        }
        return phrase
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
                      _ index: Int, _ wif: String, _ histories: [History]?) {
        let realm = try! Realm()
        try! realm.write {
            let path = coin.derPaths.filter("path = %@", derPath)
            if path.count == 0 {
                let dPath = CoinDerPaths.init(path: derPath, address: address, change: change, index: index, wif: wif)
                if let historiesUnw = histories {
                    for history in historiesUnw {
                        dPath.history.append(history)
                    }
                }
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


//MARK: IsNew?
extension KitManager {
    private func newhash(_ path: CoinDerPaths, _ hash: String) -> Bool {
        if path.unspent.count == 0 {return true}
        for pHash in path.unspent {
            if pHash.txHash == hash {
                return false
            }
        }
        return true
    }
}


