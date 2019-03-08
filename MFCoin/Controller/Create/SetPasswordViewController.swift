//
//  SetPasswordViewController.swift
//  MFCoin
//
//  Created by Admin on 07.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class SetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var setPasswordTextField: UITextField!
    @IBOutlet weak var passUnderLineView: UIView!
    @IBOutlet weak var passErrorLabel: UILabel!
    @IBOutlet weak var replyPassTextField: UITextField!
    @IBOutlet weak var replyPassUnderLineView: UIView!
    @IBOutlet weak var replyPassErrorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPasswordTextField.delegate = self
        replyPassTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        passUnderLineView.backgroundColor = .clear
        replyPassUnderLineView.backgroundColor = .clear
        passErrorLabel.text = ""
        replyPassErrorLabel.text = ""
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        if getDiffPassword() {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setCoins") as! SetCoinsTableViewController
            show(vc, sender: sender)
        }
    }
    
    @IBAction func skipForward(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "", message: "By not setting a password, your wallet can be accessed without authorization.", preferredStyle: .alert)
        let alertActionOk = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionSkip = UIAlertAction.init(title: "Skip", style: .default, handler: { (alert) in
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setCoins") as! SetCoinsTableViewController
            self.show(vc, sender: sender)
        })
        alert.addAction(alertActionOk)
        alert.addAction(alertActionSkip)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getDiffPassword() -> Bool {
        guard let password = setPasswordTextField.text else {
            passErrorLabel.text = "Set password"
            return false
        }
        if password.count < 10 {
            passErrorLabel.text = "Password is too short, minimum 10 characters."
            return false
        }
        //"Password 4444 is too common to be safely used."
        //"Passwords don't match."
        guard let replyPassword = replyPassTextField.text else {
            replyPassErrorLabel.text = "Set reply password"
            return false }
        if password == replyPassword {
            DAKeychain.shared["pass"] = password
            return true
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            passUnderLineView.backgroundColor = Constants.BLUECOLOR
        }
        if textField.tag == 20 {
            replyPassUnderLineView.backgroundColor = Constants.BLUECOLOR
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 10 {
            passUnderLineView.backgroundColor = .clear
        }
        if textField.tag == 20 {
            replyPassUnderLineView.backgroundColor = .clear
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
