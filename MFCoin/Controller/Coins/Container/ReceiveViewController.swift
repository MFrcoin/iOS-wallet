//
//  ReceiveViewController.swift
//  MFCoin
//
//  Created by Admin on 16.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class ReceiveViewController: UIViewController,UITextFieldDelegate {

    var coin: CoinModel?
    
    @IBOutlet weak var firstMoneyTF: UITextField!
    @IBOutlet weak var secondMoneyTF: UITextField!
    @IBOutlet weak var switchRightButton: UIButton!
    @IBOutlet weak var switchLeftButton: UIButton!
    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var shareButtonView: UIView!
    @IBOutlet weak var previousAddressesView: UIView!
    var fiatPrice:Float = 0.0
    var head = "USD"
    var currentAddress = ""
    var currentQr: UIImage?
    
    override func viewWillAppear(_ animated: Bool) {
        firstMoneyTF.delegate = self
        firstMoneyTF.addDoneToolbar()
        secondMoneyTF.delegate = self
        secondMoneyTF.addDoneToolbar()
        shareButtonView.layer.cornerRadius = Constants.CORNER_RADIUS
        if let coinUnw = coin {
            setupInfo(coinUnw)
        }
    }
    
    private func setupInfo(_ coinNew: CoinModel) {
        firstMoneyTF.placeholder = "\(coinNew.shortName)"
        
        switchLeftButton.isHidden = true
        switchRightButton.isHidden = false
        addressLabel.isHidden = true
        currentAddress = coinNew.currentAddrE
        addressLabel.text = currentAddress
        currentQr = QRCodeGenerate.shared.generateQRCode(from: coinNew)
        qrImage.image = QRCodeGenerate.shared.generateQRCode(from: coinNew)
        
        previousAddressesView.isHidden = true
        previousAddressesView.isUserInteractionEnabled = false
        
        let fiat = RealmHelper.shared.getHeadFiat()
        fiatPrice = Float(coinNew.fiatPrice)
        head = fiat.name.uppercased()
        secondMoneyTF.placeholder = head
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let imageCard = currentQr {
            let activityVC = UIActivityViewController(activityItems: [imageCard, currentAddress], applicationActivities: [])
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func previousAddressesButtonPressed(_ sender: UIButton) {
        print("previousAddressesButtonPressed")
    }
    
    @IBAction func switchButtonPressed(_ sender: UIButton) {
        let switchTrue = (sender.tag == 10)
        qrImage.isHidden = !switchTrue
        addressLabel.isHidden = switchTrue
        switchLeftButton.isHidden = switchTrue
        switchRightButton.isHidden = !switchTrue
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard let textFromTag = textField.text else {return}
        guard let floatFromText: Float = Float(textFromTag) else {return}
        if textField.tag == 20 {
            secondMoneyTF.text = String(floatFromText*fiatPrice)
        }
        if textField.tag == 30 {
            firstMoneyTF.text = String(floatFromText/fiatPrice)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
