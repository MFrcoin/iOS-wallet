//
//  ViewController.swift
//  MFCoin
//
//  Created by Admin on 22.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift


class StartViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    let kitManager = KitManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        start()
        enterButton.layer.cornerRadius = Constants.CORNER_RADIUS
        createButton.layer.cornerRadius = Constants.CORNER_RADIUS
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hidesBarsWhenVerticallyCompact = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnTap = false
    }
    
    private func start() {
        if !UserDefaults.standard.bool(forKey: Constants.FIRSTTIME) {
            UserDefaults.standard.set(true, forKey: Constants.FIRSTTIME)
            clearAll()
            RealmHelper.shared.setCoins()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.hidesBarsWhenVerticallyCompact = true
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsWhenKeyboardAppears = true
    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        if kitManager.getWords() != "" {
            navigationController?.setNavigationBarHidden(false, animated: false)
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "authVC") as! AuthViewController
            show(vc, sender: nil)
        } else {
            goCreate()
        }
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if kitManager.getWords() != "" {
            alert(.create)
        } else {
            goCreate()
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        if kitManager.getWords() != "" {
            alert(.recreate)
        } else {
            goRecreate()
        }
    }
    
    private func alert(_ choise: Choise) {
        let alert = UIAlertController.init(title: "Override existing wallet?", message: "If you create a new wallet, your existing wallet will be lost unless you backed up your recovery phrase", preferredStyle: .alert)
        let alertActionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionOk = UIAlertAction.init(title: "Ok", style: .default, handler: { (ok) in
            self.clearAll()
            RealmHelper.shared.setCoins()
            if choise == .create {
                self.goCreate()
            } else {
                self.goRecreate()
            }
        })
        alert.addAction(alertActionCancel)
        alert.addAction(alertActionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func goCreate() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "createWalletVC") as! CreateWalletViewController
        show(vc, sender: nil)
    }
    
    private func goRecreate() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "recreateVC") as! RecreateViewController
        self.show(vc, sender: nil)
    }

    private func clearAll() {
        DAKeychain.shared[Constants.MNEMONIC_KEY] = ""
        DAKeychain.shared[Constants.PASS_KEY] = ""
        DAKeychain.shared[Constants.PASSPHRASE_KEY] = ""
        DAKeychain.shared[Constants.BIOMETRICS] = ""
        
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}

enum Choise {
    case create
    case recreate
}
