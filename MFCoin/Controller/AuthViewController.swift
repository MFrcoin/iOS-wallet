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
    @IBOutlet weak var underLinePassView: UIView!
    @IBOutlet weak var passErrorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        underLinePassView.backgroundColor = .gray
        passErrorLabel.text = ""
        guard let biometrics = DAKeychain.shared[Constants.BIOMETRICS] else { return }
        if biometrics == "true" {
            touchFaceId()
        }
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        guard let password = DAKeychain.shared[Constants.PASS_KEY] else {
            gogo()
            return }
        if password == passTF.text {
            gogo()
        } else {
            passErrorLabel.text = "Password is incorrect"
        }
    }
    
    func touchFaceId() {
        BiometricIDAuth.shared.authenticateUser { (answer) in
            if answer == "success" {
                self.gogo()
            } else {
                DispatchQueue.main.async {
                    self.passErrorLabel.text = answer
                }
            }
        }
    }
    
    private func gogo() {
        KitManager().getOnline()
        FiatTicker().setPrice()
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! CoinsTabBarController
        self.present(vc, animated: true)
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            underLinePassView.backgroundColor = Constants.BLUECOLOR
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField.tag == 10 {
            underLinePassView.backgroundColor = .gray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
