//
//  SweepPaperViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class SweepPaperViewController: UIViewController, ScannerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var privateKeyTF: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        privateKeyTF.delegate = self
    }
    
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "scannerController") as! ScannerViewController
        vc.delegate = self
        show(vc, sender: nil)
    }
    
    @IBAction func goForwardPressed(_ sender: UIButton) {
        print ("goForward Pressed")
    }
    
    func qrCodeReader(info: String) {
        privateKeyTF.text = info
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
