//
//  CreateWalletViewController.swift
//  MFCoin
//
//  Created by Admin on 29.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit
import SwiftSocket

class CreateWalletViewController: UIViewController  {
    
    @IBOutlet weak var newSeedTV: UITextView!
    @IBOutlet weak var iSaveSeedSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    let kitManager = KitManager.shared
    let realm = RealmHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        kitManager.createWords()
        newSeedTV.text = kitManager.getWords()
    }
    
    
    @IBAction func goForward(_ sender: UIButton) {
        if newSeedTV.text != "" && iSaveSeedSwitch.isOn {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "diffPhrase") as! DiffPhraseViewController
            show(vc, sender: sender)
        } else {
            let alert = UIAlertController.init(title: "Сохраните фразу!", message: "Пожалуйста, удостоверьтесь что фраза сохранена!", preferredStyle: .alert)
            let alertActionOk = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertActionOk)
            self.present(alert, animated: true, completion: nil)
        }
    }

}



