//
//  TransactionsSender.swift
//  MFCoin
//
//  Created by Admin on 25.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift

class TransactionsSender {
    //https://github.com/yenom/BitcoinKit/blob/master/Tests/BitcoinKitTests/TransactionTests.swift
    
    let kitManager = KitManager.shared
    let realmManager = RealmHelper.shared
    var coin: CoinModel?
    var toAddress = ""
    var amount = 0
    var coinIndex = 0
    var fee = 100000
    
    convenience init(coin: CoinModel, toAddress: String, amount: Int) {
        self.init()
        self.coin = coin
        self.coinIndex = coin.index
        self.fee = coin.fee
        self.toAddress = toAddress
        self.amount = amount
    }
    
    private func getPrivateKeys(coin: CoinModel) -> [PrivateKey] {
        var keys = [PrivateKey]()
        for path in coin.derPaths {
            if path.unspent.count > 0 {
                if let privateKey = PrivateKey(wif: path.wif) {
                    keys.append(privateKey)
                }
            }
        }
        return keys
    }
    
    public func sendToSomeAddress(_ amount: Int64) {
        var utxos: [BitcoinUnspentTransaction] = []
        let coins = realmManager.selCoins
        guard let coinUnw = coin else {return}
        let mfcoin = coins.filter("index == %@", coinUnw.index)[0]
        var changeAddress = ""
        for path in mfcoin.derPaths {
            for input in path.unspent {
                guard let toAd = BitcoinAddress.init(string: path.address) else {return}
                let lockingScript1 = BitcoinScript.buildPayToPublicKeyHash(address: toAd)
                let txid: Data = Data(hex: String(input.txHash))
                let txHash: Data = Data(txid.reversed())
                let txIndex = UInt32(input.txPos)
                
                let unspentOutput = BitcoinTransactionOutput(value: Int64(input.value), script: lockingScript1)
                let unspentOutpoint = BitcoinOutPoint(hash: txHash, index: txIndex)
                
                let utxo = BitcoinUnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
                utxos.append(utxo)
            }
            if changeAddress == "" {
                if path.change == 1 {
                    changeAddress = path.address
                }
            }
        }
        
        guard let toAddr = BitcoinAddress(string: toAddress) else {return}
        guard let changeAddr = BitcoinAddress(string: changeAddress) else {return}
        guard let unsignedTx = createUnsignedTx(toAddr: toAddr, amount: amount, changeAddr: changeAddr, utxos: utxos) else { return }
        
        let signedTx = signTx(unsignedTx: unsignedTx, keys: getPrivateKeys(coin: coinUnw))
        let info = "\"\(signedTx.hexEncoded)\""
        ServerConnect().sendRequest(coin: coinUnw, command: .broadcast, altInfo: info, id: coinUnw.shortName, { (response) in
            if let list = response as? Broadcast {
                DispatchQueue.main.async{
                    let userInfo = [ "txId" : list.result ]
                    NotificationCenter.default.post(name: Constants.SENDED, object: nil, userInfo: userInfo)
                }
            }
        })
    }
    
    private func selectTx(from utxos: [BitcoinUnspentTransaction], amount: Int64) -> (utxos: [BitcoinUnspentTransaction], fee: Int64)? {
        let selector = BitcoinUnspentSelector.init()
        do {
            let answer = try selector.select(from: utxos, targetValue: BigInt(amount))
            return (answer.utxos, Int64(answer.fee))
        } catch let error{
            print(error)
        }
        return nil
    }
    
    private func createUnsignedTx(toAddr: BitcoinAddress, amount: Int64, changeAddr: BitcoinAddress, utxos: [BitcoinUnspentTransaction]) -> BitcoinUnsignedTransaction? {
        guard let (utxos, fee) = selectTx(from: utxos, amount: amount) else {return nil}
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - amount - fee
        let lockingScriptTo = BitcoinScript.buildPayToPublicKeyHash(address: toAddr)
        let lockingScriptChange = BitcoinScript.buildPayToPublicKeyHash(address: changeAddr)
        let toOutput = BitcoinTransactionOutput(value: amount, script: lockingScriptTo)
        let changeOutput = BitcoinTransactionOutput(value: change, script: lockingScriptChange)
        let unsignedInputs = utxos.map { BitcoinTransactionInput(previousOutput: $0.outpoint, script: BitcoinScript(data: Data()), sequence: Constants.SEQUENCE_FINAL) }
        let tx = BitcoinTransaction(version: 1, inputs: unsignedInputs, outputs: [toOutput, changeOutput], lockTime: 0)
        return BitcoinUnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    private func signTx(unsignedTx: BitcoinUnsignedTransaction, keys: [PrivateKey]) -> BitcoinTransaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: BitcoinTransaction {
            return BitcoinTransaction(version: 1, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: 0)
        }
        
        let hashType: SignatureHashType = .all
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            
            var pubKeyhash = Data()
            if let matchPay = utxo.output.script.matchPayToPubkeyHash() {
                pubKeyhash = BitcoinScript(data: matchPay).data
            }
            let keysOfUtxo: [PrivateKey] = keys.filter {
                $0.publicKey(compressed: true).pubkeyHash == pubKeyhash
            }
            guard let key = keysOfUtxo.first else {
                continue
            }
            let sighash: Data = transactionToSign.getSignatureHashBase(scriptCode: utxo.output.script, index: i, hashType: hashType)
            let signature: Data = Crypto.signAsDER(hash: sighash, privateKey: key.data)
            let txin = inputsToSign[i]
            let pubkey = key.publicKey(compressed: true)
            let unlockingScriptData = BitcoinScript.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            let unlockingScript = BitcoinScript(data: unlockingScriptData)
            
            inputsToSign[i] = BitcoinTransactionInput(previousOutput: txin.previousOutput, script: unlockingScript, sequence: Constants.SEQUENCE_FINAL)
        }
        return transactionToSign
    }
}


