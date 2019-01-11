//
//  RecreateViewController.swift
//  MFCoin
//
//  Created by Admin on 08.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import HSBitcoinKit
import HSHDWalletKit

class RecreateViewController: UIViewController, ScannerDelegate, UITextFieldDelegate {

    @IBOutlet weak var bip39PassphraseTF: UITextField!
    @IBOutlet weak var bip39ViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineBip39View: UIView!
    @IBOutlet weak var undelinePassPhraseView: UIView!
    @IBOutlet weak var errorPhraseLabel: UILabel!

    @IBOutlet weak var bip39Switch: UISwitch!
    @IBOutlet weak var phraseTF: UITextField!
    
    @IBOutlet weak var bip39View: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bip39ViewConstraint.constant = 0
        bip39View.isHidden = true
        bip39PassphraseTF.delegate = self
        phraseTF.delegate = self
    }
    
    
    @IBAction func switchPressed(_ sender: Any) {
        if bip39Switch.isOn {
            phraseTF.isEnabled = false
            UIView.animate(withDuration: 0.5) {
                self.bip39ViewConstraint.constant = 160
                self.bip39View.isHidden = false
            }
        } else {
            phraseTF.isEnabled = true
            UIView.animate(withDuration: 0.5) {
                self.bip39ViewConstraint.constant = 0
                self.bip39View.isHidden = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        undelinePassPhraseView.backgroundColor = .clear
        underlineBip39View.backgroundColor = .clear
        errorPhraseLabel.text = ""
    }
    
    @IBAction func scanPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "scannerController") as! ScannerViewController
        vc.delegate = self
        show(vc, sender: sender)
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "setPass") as! SetPasswordViewController
        show(vc, sender: sender)
    }
    
    func qrCodeReader(info: String) {
        phraseTF.text = info
        let bitKit = BitcoinKit.init(withWords: [info], coin: .bitcoin(network: .testNet))
        print (bitKit.debugInfo)
    }
    
    
    //"Could not verify your recovery phrase. Word list size must be multiple of three words."
    //"Could not verify your recovery phrase. Word list is empty."
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            undelinePassPhraseView.backgroundColor = Colors.blueColor
        }
        if textField.tag == 20 {
            underlineBip39View.backgroundColor = Colors.blueColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 10 {
            undelinePassPhraseView.backgroundColor = .clear
        }
        if textField.tag == 20 {
            underlineBip39View.backgroundColor = .clear
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 
}
