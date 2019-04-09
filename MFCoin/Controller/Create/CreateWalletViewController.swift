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
    
    
    @IBOutlet weak var newSeedLabel: SRCopyableLabel!
    @IBOutlet weak var iSaveSeedSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    let kitManager = KitManager.shared
    let realm = RealmHelper.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = Constants.CORNER_RADIUS
        nextButton.backgroundColor = .gray
        kitManager.createWords()
        newSeedLabel.text = kitManager.getWords()
        
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        if newSeedLabel.text != "" && iSaveSeedSwitch.isOn {
            KitManager().getOnline()
            FiatTicker().setPrice()
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "diffPhrase") as! DiffPhraseViewController
            show(vc, sender: sender)
        }
    }
    
    @IBAction func saveSeedSwitched(_ sender: UISwitch) {
        nextButton.isEnabled = sender.isOn
        nextButton.backgroundColor = {
            if sender.isOn { return Constants.BLUECOLOR }
            else { return .gray }
        }()
    }
}



