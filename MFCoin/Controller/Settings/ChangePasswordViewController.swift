//
//  ChangePasswordViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var oldPassTF: UITextField!
    @IBOutlet weak var newPassTF: UITextField!
    @IBOutlet weak var repeatPassTF: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        initController()
    }
    
    private func initController() {
        changeButton.layer.cornerRadius = Constants.CORNER_RADIUS
        errorLabel.text = ""
        oldPassTF.delegate = self
        newPassTF.delegate = self
        repeatPassTF.delegate = self
    }
    
    @IBAction func changeButtonPressed(_ sender: UIButton) {
        if let oldPass = DAKeychain.shared[Constants.PASS_KEY] {
            if oldPass == oldPassTF.text {
                if getBoolNewPass() {
                    DAKeychain.shared[Constants.PASS_KEY] = repeatPassTF.text
                } else {
                    errorLabel.text = "Repeat password incorrect"
                }
            } else {
                errorLabel.text = "Old password incorrect"
            }
        }
    }
    
    private func getBoolNewPass() -> Bool {
        return newPassTF.text == repeatPassTF.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
