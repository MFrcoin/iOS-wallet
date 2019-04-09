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
    var fiatPrice:Float = 0.0
    var head = "USD"
    var currentAddress = ""
    var currentQr: UIImage?
    var shareImage: UIImage?
    @objc dynamic var inputSatoshi: String?
    @objc dynamic var inputFiat: String?
    var inSatoshiObservation: NSKeyValueObservation?
    var inFiatObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        inSatoshiObservation = observe(\ReceiveViewController.inputSatoshi, options: .new) { (vc, change) in
            guard let upText = change.newValue as? String else { return }
            guard let fUpText = Float(upText) else { return }
            self.secondMoneyTF.text = String(fUpText*self.fiatPrice)
        }
        inFiatObservation = observe(\ReceiveViewController.inputFiat, options: .new) { (vc, change) in
            guard let upText = change.newValue as? String else { return }
            guard let fUpText = Float(upText) else { return }
            self.firstMoneyTF.text = String(fUpText*self.fiatPrice)
        }
    }
    
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
        qrImage.image = currentQr
        shareImage = qrImage.asImage()
        let fiat = RealmHelper.shared.getHeadFiat()
        fiatPrice = Float(coinNew.fiatPrice)
        head = fiat.name.uppercased()
        secondMoneyTF.placeholder = head
    }

    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let shareImageObj = shareImage {
            let activityViewController = UIActivityViewController(activityItems: [currentAddress, shareImageObj], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.openInIBooks, .assignToContact, .markupAsPDF,
                                                            .postToTencentWeibo, .postToVimeo,
                                                            .postToWeibo, .saveToCameraRoll]
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchButtonPressed(_ sender: UIButton) {
        let switchTrue = (sender.tag == 10)
        qrImage.isHidden = !switchTrue
        addressLabel.isHidden = switchTrue
        switchLeftButton.isHidden = switchTrue
        switchRightButton.isHidden = !switchTrue
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

    @IBAction func anotherAddressPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "newAddressTVC") as! NewAddressTVC
        guard let coinUnw = coin else {return}
        vc.coin = coinUnw
        show(vc, sender: nil)
    }
}

extension UIImageView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
