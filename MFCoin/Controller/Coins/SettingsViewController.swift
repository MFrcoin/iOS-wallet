//
//  SettingsViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
   
    @IBOutlet weak var biometricsSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    let sb = UIStoryboard.init(name: "Settings", bundle: nil)
    
    override func viewDidLoad() {
        guard let biometrics = DAKeychain.shared[Constants.BIOMETRICS] else { return }
        biometricsSwitch.setOn(biometrics == "true", animated: false)
    }
    
    @IBAction func switchedPressed(_ sender: UISwitch) {
         DAKeychain.shared[Constants.BIOMETRICS] = "\(sender.isOn)"
    }
    
    @IBAction func restoreWalletPressed(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "recreateVC") as! RecreateViewController
        show(vc, sender: nil)
    }
    
    @IBAction func showPhrasePressed(_ sender: UIButton) {
        let vc = sb.instantiateViewController(withIdentifier: "recoveryPhraseVC") as! RecoveryPhraseViewController
        show(vc, sender: nil)
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        let vc = sb.instantiateViewController(withIdentifier: "changePassVC") as! ChangePasswordViewController
        show(vc, sender: nil)
    }
 
    @IBAction func exchangeRatesPressed(_ sender: UIButton) {
        let vc = sb.instantiateViewController(withIdentifier: "exchTableVC") as! ExchRatesTableViewController
        show(vc, sender: nil)
    }
    
    @IBAction func transactionFeesPressed(_ sender: UIButton) {
        let vc = sb.instantiateViewController(withIdentifier: "transactionFeesVC") as! TransactFeesTableViewController
        show(vc, sender: nil)
    }
    
    @IBAction func sweepPaperPressed(_ sender: UIButton) {
        let vc = sb.instantiateViewController(withIdentifier: "sweepPaperVC") as! SweepPaperViewController
        show(vc, sender: nil)
    }
    
    
}
