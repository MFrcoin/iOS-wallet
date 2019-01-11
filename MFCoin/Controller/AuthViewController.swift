//
//  AuthViewController.swift
//  MFCoin
//
//  Created by Admin on 07.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var replyPassTF: UITextField!
    @IBOutlet weak var underLinePassView: UIView!
    @IBOutlet weak var underReplyPassView: UIView!
    @IBOutlet weak var passErrorLabel: UILabel!
    @IBOutlet weak var replyPassErrorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passTF.delegate = self
        replyPassTF.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        underLinePassView.backgroundColor = .clear
        underReplyPassView.backgroundColor = .clear
        passErrorLabel.text = ""
        replyPassErrorLabel.text = ""
        touchFaceId()
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        if passTF.text == replyPassTF.text {
            guard let password = DAKeychain.shared["pass"] else {
                passErrorLabel.text = "Нет такого аккаунта"
                return }
            print(password)
            if password == passTF.text {
                let sb = UIStoryboard.init(name: "Coins", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! CoinsTabBarController
                self.show(vc, sender: sender)
            } else {
                passErrorLabel.text = "Пароль не подходит"
                replyPassErrorLabel.text = ""
            }
        } else {
            replyPassErrorLabel.text = "Пароли не совпадают"
        }
    }
    
    @IBAction func skipForward(_ sender: UIButton) {
        
    }
    
    func touchFaceId() {
        BiometricIDAuth.shared.authenticateUser { (answer) in
            if answer == "success" {
                let sb = UIStoryboard.init(name: "Coins", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! CoinsTabBarController
                self.show(vc, sender: nil)
            } else {
                DispatchQueue.main.async {
                    self.passErrorLabel.text = answer
                    self.replyPassErrorLabel.text = ""
                }
            }
        }
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            underLinePassView.backgroundColor = Colors.blueColor
        }
        if textField.tag == 20 {
            underReplyPassView.backgroundColor = Colors.blueColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 10 {
            underLinePassView.backgroundColor = .clear
        }
        if textField.tag == 20 {
            underReplyPassView.backgroundColor = .clear
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
