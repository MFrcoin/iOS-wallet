//
//  SendViewController.swift
//  MFCoin
//
//  Created by Admin on 16.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class SendViewController: UIViewController, UITextFieldDelegate {

    var coin: CoinModel?
    let convert = ConvertValue.shared
    
    @IBOutlet weak var firstMoneyLabel: UILabel!
    @IBOutlet weak var secondMoneyLabel: UILabel!
    @IBOutlet weak var firstMoneyTF: UITextField!
    @IBOutlet weak var secondMoneyTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    var fiatPrice: Float = 0.0
    var head = "USD"
    var balance: Float = 0.0
    @objc dynamic var inputSatoshi: String?
    @objc dynamic var inputFiat: String?
    var inputSatoshiObservation: NSKeyValueObservation?
    var inputFiatObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        inputSatoshiObservation = observe(\SendViewController.inputSatoshi, options: .new) { (vc, change) in
            guard let upText = change.newValue as? String else { return }
            guard let fUpText = Float(upText) else { return }
            self.secondMoneyTF.text = String(fUpText*self.fiatPrice)
        }
        inputFiatObservation = observe(\SendViewController.inputFiat, options: .new) { (vc, change) in
            guard let upText = change.newValue as? String else { return }
            guard let fUpText = Float(upText) else { return }
            self.firstMoneyTF.text = String(fUpText*self.fiatPrice)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(insuffFunds), name: Constants.INSUFFICIENTFUNDS, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.SENDED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        firstMoneyTF.delegate = self
        secondMoneyTF.delegate = self
        addressTF.delegate = self
        
        firstMoneyTF.addDoneToolbar()
        secondMoneyTF.addDoneToolbar()
        
        sendButton.layer.cornerRadius = Constants.CORNER_RADIUS
        guard let coinUnw = coin else {return}
        setInfo(coinUnw)
    }
    
    
    @objc func update(_ notification: Notification) {
        if let text = notification.userInfo?["txId"] {
            statusLabel.textColor = Constants.BLUECOLOR
            statusLabel.text = "\(text)"
        } else {
            setSendStatus(status: .failure)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Constants.INSUFFICIENTFUNDS, object: nil)
        NotificationCenter.default.removeObserver(self, name: Constants.SENDED, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }
    
    @objc func insuffFunds() {
        setSendStatus(status: .insufficientFunds)
    }
    
    private func setInfo(_ coin: CoinModel) {
        balance = Float(convert.convert(value: coin.balance))
        firstMoneyLabel.text = coin.shortName
        firstMoneyTF.text = String(balance)
        secondMoneyTF.text = String(setFiatAmount(coin))
        secondMoneyLabel.text = head
    }
    
    private func setFiatAmount(_ coin: CoinModel) -> Float {
        let fiat = RealmHelper.shared.getHeadFiat()
        fiatPrice = Float(coin.fiatPrice)
        head = fiat.name.uppercased()
        let balance = convert.convertSatoshToFiat(satoshi: coin.balance, rate: coin.fiatPrice)
        return Float(balance)
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        if sender.isOn {
            guard let coinUnw = coin else {return}
            let balance = Float(convert.convert(value: coinUnw.balance))
            firstMoneyTF.text = String(balance)
            secondMoneyTF.text = String(balance*fiatPrice)
        }
    }
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "scannerController") as! ScannerViewController
        vc.delegate = self
        show(vc, sender: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let coinUnw = coin,
            let address = addressTF.text,
            let amount = firstMoneyTF.text,
            let dAmount: Double = Double(amount) else { return }
        
        let convertAmount = convert.convertValueToSatoshi(value: dAmount)
        if dAmount > 0.0 && convertAmount < coinUnw.balance {
            if BitcoinAddress.isValid(string: address) {
            let ts = TransactionsSender(coin: coinUnw, toAddress: address, amount: convertAmount)
            ts.sendToSomeAddress(Int64(convertAmount))
            //setSendStatus(status: .success)
            } else {
                setSendStatus(status: .invalidAddress)
            }
        } else {
            setSendStatus(status: .insufficientFunds)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func firstMoneyChanged(_ sender: UITextField) {
        inputSatoshi = sender.text
    }
    
    @IBAction func secondMoneyChanged(_ sender: UITextField) {
        inputFiat = sender.text
    }
    
    private func setSendStatus(status: SendedStatus) {
        switch status {
        case .success:
            statusLabel.textColor = Constants.BLUECOLOR
            statusLabel.text = "Sended"
            KitManager().getBalances()
            RealmHelper().updateTitleBalance()
        case .insufficientFunds:
            statusLabel.textColor = .red
            statusLabel.text = "Insufficient funds"
        case .invalidAddress:
            statusLabel.textColor = .red
            statusLabel.text = "Address is invalid"
        case .online:
            statusLabel.textColor = Constants.BLUECOLOR
            statusLabel.text = "Online"
        case .offline:
            statusLabel.textColor = .red
            statusLabel.text = "Offline"
        case .failure:
            statusLabel.textColor = .red
            statusLabel.text = "Unknown ERROR"
        }
    }
    
}

extension SendViewController: ScannerDelegate {
    func qrCodeReader(info: String) {
        if let dotIndex = info.firstIndex(of: ":") {
            let wName = info[..<dotIndex]
            let startAddressIndex = info.index(after: dotIndex)
            let wAddress = info[startAddressIndex...]
            guard let coinUnw = coin else {
                setSendStatus(status: .online)
                return
            }
            if wName == coinUnw.fullName {
                addressTF.text = String(wAddress)
            } else {
                setSendStatus(status: .invalidAddress)
            }
        } else {
            addressTF.text = info
        }
    }
}

extension SendViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            setSendStatus(status: .online)
        default:
            setSendStatus(status: .offline)
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            self.present(alert, animated: true)
        }
    }
}

enum SendedStatus {
    case success
    case failure
    case insufficientFunds
    case online
    case offline
    case invalidAddress
}
