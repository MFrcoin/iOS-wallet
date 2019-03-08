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
    var fiatPrice:Float = 0.0
    var head = "USD"
    var balance:Float = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        firstMoneyTF.delegate = self
        secondMoneyTF.delegate = self
        addressTF.delegate = self
        
        firstMoneyTF.addDoneToolbar()
        secondMoneyTF.addDoneToolbar()
        
        sendButton.layer.cornerRadius = Constants.CORNER_RADIUS
        guard let coinUnw = coin else {return}
        setInfo(coinUnw)
    }
    
    private func setInfo(_ coin: CoinModel) {
        balance = convert.convertValue(value: coin.balance)
        firstMoneyLabel.text = coin.shortName
        firstMoneyTF.text = String(balance)
        secondMoneyTF.text = String(setFiatAmount(coin))
        secondMoneyLabel.text = head
    }
    
    private func sendSuccess() {
        firstMoneyTF.text = ""
        secondMoneyTF.text = ""
        addressTF.text = ""
    }
    
    private func setFiatAmount(_ coin: CoinModel) -> Float {
        let fiat = RealmHelper.shared.getHeadFiat()
        print (fiat.name, coin.fiatPrice)
        //let header = fiats.filter("head == true")
        fiatPrice = Float(coin.fiatPrice)
        head = fiat.name.uppercased()
        let balance = ConvertValue().convertSatoshToFiat(satoshi: coin.balance, rate: coin.fiatPrice)
        return Float(balance)
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        guard let coinUnw = coin else {return}
        let balance = convert.convertValue(value: coinUnw.balance)
        firstMoneyTF.text = String(balance)
        secondMoneyTF.text = String(balance*fiatPrice)
        print("switch on")
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
        
        let convertAmount = ConvertValue.shared.convertValueToSatoshi(value: dAmount)
        if dAmount > 0.0 && convertAmount < coinUnw.balance {
            print(address, convertAmount)
            let ts = TransactionsSender(coin: coinUnw, toAddress: address, amount: convertAmount)
            ts.sendToSomeAddress(Int64(convertAmount))
            statusLabel.text = "Sended"
            print("send button pressed")
        } else {
            print("send ERROR")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let textFromTag = textField.text else {return}
        guard let floatFromText: Float = Float(textFromTag) else {return}
        if textField.tag == 10 {
            secondMoneyTF.text = String(floatFromText*fiatPrice)
        }
        if textField.tag == 20 {
            firstMoneyTF.text = String(floatFromText/fiatPrice)
        }
    }
    
}

extension SendViewController: ScannerDelegate {
    func qrCodeReader(info: String) {
        addressTF.text = info
    }
}
