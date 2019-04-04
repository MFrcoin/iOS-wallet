//
//  RecreateViewController.swift
//  MFCoin
//
//  Created by Admin on 08.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class RecreateViewController: UIViewController, ScannerDelegate, UITextFieldDelegate {

    @IBOutlet weak var bip39PassphraseTF: UITextField!
    @IBOutlet weak var bip39ViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineBip39View: UIView!
    @IBOutlet weak var undelinePassPhraseView: UIView!
    @IBOutlet weak var errorPhraseLabel: UILabel!

    @IBOutlet weak var bip39Switch: UISwitch!
    @IBOutlet weak var phraseTF: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bip39View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bip39ViewConstraint.constant = 0
        bip39View.isHidden = true
        bip39PassphraseTF.delegate = self
        phraseTF.delegate = self
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
    }
    
    @IBAction func switchPressed(_ sender: Any) {
        if bip39Switch.isOn {
            UIView.animate(withDuration: 0.5) {
                self.bip39ViewConstraint.constant = 160
                self.bip39View.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.bip39ViewConstraint.constant = 0
                self.bip39View.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        undelinePassPhraseView.backgroundColor = .gray
        underlineBip39View.backgroundColor = .gray
        errorPhraseLabel.text = ""
    }
    
    @IBAction func scanPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "scannerController") as! ScannerViewController
        vc.delegate = self
        show(vc, sender: nil)
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        if phraseTF.text != "" {
            guard let words = phraseTF.text else {return}
            save(words: words.trimmingCharacters(in: .whitespacesAndNewlines))
            if bip39Switch.isOn {
                if bip39PassphraseTF.text != "" {
                    guard let phrase = bip39PassphraseTF.text else {return}
                    save(phrase: phrase.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
            KitManager().getOnline()
            FiatTicker().setPrice()
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setPass") as! SetPasswordViewController
            show(vc, sender: sender)
        }
    }
    
    func qrCodeReader(info: String) {
        phraseTF.text = info
    }
    
    private func save(words: String) {
        DAKeychain.shared[Constants.MNEMONIC_KEY] = words
    }
    
    private func save(phrase: String) {
        DAKeychain.shared[Constants.PASSPHRASE_KEY] = phrase
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            undelinePassPhraseView.backgroundColor = Constants.BLUECOLOR
        }
        if textField.tag == 20 {
            underlineBip39View.backgroundColor = Constants.BLUECOLOR
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 10 {
            undelinePassPhraseView.backgroundColor = .gray
        }
        if textField.tag == 20 {
            underlineBip39View.backgroundColor = .gray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 
}
