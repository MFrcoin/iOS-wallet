//
//  SweepPaperViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift
import BigInt


class SweepPaperViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var privateKeyTF: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    var mfCoin: CoinModel?
    var privateKey: PrivateKey?
    
    override func viewWillAppear(_ animated: Bool) {
        statusLabel.text = ""
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        privateKeyTF.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(readyToSend), name: Constants.UPDATE , object: nil)
    }
    
    @objc func readyToSend(){
        DispatchQueue.main.async{
            self.sendToSomeAddress()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "scannerController") as! ScannerViewController
        vc.delegate = self
        show(vc, sender: nil)
    }
    
    @IBAction func goForwardPressed(_ sender: UIButton) {
        guard let pKey = privateKeyTF.text else { return }
        if pKey != "" {
            startSweep(pKey: pKey)
        } else {
            setStatus(.notFound)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
}

//MARK: Scanner
extension SweepPaperViewController: ScannerDelegate {
    
    func qrCodeReader(info: String) {
        if let dotIndex = info.firstIndex(of: ":") {
            let wName = info[..<dotIndex]
            let startAddressIndex = info.index(after: dotIndex)
            let wKey = info[startAddressIndex...]
            guard let coinUnw = mfCoin else {
                setStatus(.failure)
                return
            }
            if wName == coinUnw.fullName {
                privateKeyTF.text = String(wKey)
            } else {
                setStatus(.notSupported)
            }
        } else {
            privateKeyTF.text = info
        }
    }
}

//MARK: StartSweep
extension SweepPaperViewController {
    
    private func startSweep(pKey: String) {
        if let privKey = PrivateKey.init(wif: pKey) {
            initSweepPaper(privKey)
        }
        let data = Data(hex: pKey)
        if let privateKey = PrivateKey(data: data) {
            initSweepPaper(privateKey)
        }
    }
    
    private func initSweepPaper(_ pKey: PrivateKey) {
        privateKey = pKey
        let name = "mfcoin"
        mfCoin = RealmHelper.shared.getAllCoins().filter("name = %@", name)[0]
        var address = ""
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(SweepPaperModel.self))
            let sPaper = SweepPaperModel()
            sPaper.privateKey = pKey.description
            address = pKey.publicKey(compressed: true).legacyBitcoinAddress(prefix: 0x33).base58String
            sPaper.address = address
            realm.add(sPaper)
        }
        getListunspent(address: address)
    }
    
    private func getListunspent(address: String) {
        guard let coin = mfCoin else {return}
        if let scriptHash = getRevercesScriptHash(address: address) {
            ServerConnect.shared.sendRequest(coin: coin, command: .listunspent, altInfo: "\"\(scriptHash)\"", id: coin.shortName, { (response) in
                if let listunspents = response as? Listunspent {
                    let realm = try! Realm()
                    let sPaper = realm.objects(SweepPaperModel.self)[0]
                    try! realm.write {
                        for listunspent in listunspents.result {
                            guard let txhash = listunspent.tx_hash else {return}
                            guard let balance = listunspent.value else {return}
                            if self.newhash(sPaper, txhash) {
                                let input = Unspent.init(result: listunspent)
                                sPaper.balance += Int64(balance)
                                sPaper.unspent.append(input)
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
                    }
                }
            })
        }
    }
    
    private func getRevercesScriptHash(address: String) -> String? {
        guard let addr = BitcoinAddress.init(string: address) else { return nil }
        let p2pkh = BitcoinScript.buildPayToPublicKeyHash(address: addr)
        let sha = p2pkh.bytes.sha256()
        let reversed = [UInt8](sha.reversed()).toHexString()
        return reversed
    }
    
    private func newhash(_ sPaper: SweepPaperModel, _ hash: String) -> Bool {
        if sPaper.unspent.count == 0 {return true}
        for pHash in sPaper.unspent {
            if pHash.txHash == hash {
                return false
            }
        }
        return true
    }
    
//MARK: Status
    private func setStatus(_ status: SweepStatus) {
        switch status {
        case .notFound:
            statusLabel.textColor = .red
            statusLabel.text = "Private key not found."
        case .offline:
            statusLabel.textColor = .red
            statusLabel.text = "Offline"
        case .online:
            statusLabel.textColor = Constants.BLUECOLOR
            statusLabel.text = "Online"
        case .success:
            statusLabel.textColor = Constants.BLUECOLOR
            statusLabel.text = "Success"
        case .failure:
            statusLabel.textColor = .red
            statusLabel.text = "Unknowable error"
        case .notSupported:
            statusLabel.textColor = .red
            statusLabel.text = "Private key not supported."
        }
    }
}

enum SweepStatus {
    case notFound
    case offline
    case online
    case success
    case failure
    case notSupported
}

//MARK: Send
extension SweepPaperViewController {
    
    @objc func sendToSomeAddress() {
        let sPaper = try! Realm().objects(SweepPaperModel.self)[0]
        var utxos: [BitcoinUnspentTransaction] = []
        guard let coin = mfCoin else {return}
        let changeAddress = coin.currentAddrE
            for input in sPaper.unspent {
                guard let toAd = BitcoinAddress.init(string: coin.currentAddrE) else {return}
                let lockingScript1 = BitcoinScript.buildPayToPublicKeyHash(address: toAd)
                let txid: Data = Data(hex: String(input.txHash))
                let txHash: Data = Data(txid.reversed())
                let txIndex = UInt32(input.txPos)
                
                let unspentOutput = BitcoinTransactionOutput(value: Int64(input.value), script: lockingScript1)
                let unspentOutpoint = BitcoinOutPoint(hash: txHash, index: txIndex)
                
                let utxo = BitcoinUnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
                utxos.append(utxo)
            }
        
        guard let toAddr = BitcoinAddress(string: sPaper.address) else {return}
        guard let changeAddr = BitcoinAddress(string: changeAddress) else {return}
        let amount = sPaper.balance
        guard let unsignedTx = createUnsignedTx(toAddr: toAddr, amount: amount, changeAddr: changeAddr, utxos: utxos) else { return }
        
        guard let privateKey = privateKey else { return }
        
        let signedTx = signTx(unsignedTx: unsignedTx, keys: [privateKey])
        let info = "\"\(signedTx.hexEncoded)\""
        print("info \(info)")
        ServerConnect().sendRequest(coin: coin, command: .broadcast, altInfo: info, id: "SweepPaper", { (response) in
            if let list = response as? Broadcast {
                DispatchQueue.main.async{
                    self.statusLabel.text = list.result
                }
                print("list.result \(list.result)")
            }
        })
    }
    
    private func selectTx(from utxos: [BitcoinUnspentTransaction], amount: Int64) -> (utxos: [BitcoinUnspentTransaction], fee: Int64)? {
        let selector = BitcoinUnspentSelector.init()
        do {
            let answer = try selector.select(from: utxos, targetValue: BigInt(amount))
            guard let coin = mfCoin else {return nil}
            return (answer.utxos, Int64(coin.fee))
        } catch let error{
            print("error \(error)")
        }
        return nil
    }
    
    private func createUnsignedTx(toAddr: BitcoinAddress, amount: Int64, changeAddr: BitcoinAddress, utxos: [BitcoinUnspentTransaction]) -> BitcoinUnsignedTransaction? {
        guard let (utxos, fee) = selectTx(from: utxos, amount: amount) else {return nil}
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let change: Int64 = totalAmount - fee
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

extension SweepPaperViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            setStatus(.online)
        default:
            setStatus(.offline)
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            self.present(alert, animated: true)
        }
    }
}
