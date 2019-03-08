//
//  ViewController.swift
//  MFCoin
//
//  Created by Admin on 22.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit
import SwiftSocket
import CryptoSwift


class StartViewController: UIViewController {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enterButton.layer.cornerRadius = Constants.CORNER_RADIUS
        createButton.layer.cornerRadius = Constants.CORNER_RADIUS
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func update(){
        //ShapeShift().getFees()
        FiatTicker().setPrice()
    }
    
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        if KitManager().getWords() != "" {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "authVC") as! AuthViewController
            show(vc, sender: nil)
        } else {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "createWalletVC") as! CreateWalletViewController
            show(vc, sender: nil)
        }
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if KitManager().getWords() != "" {
            alert()
        } else {
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "createWalletVC") as! CreateWalletViewController
            show(vc, sender: nil)
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        
    }
    
    private func alert() {
       
        let alert = UIAlertController.init(title: "Override existing wallet?", message: "If you create a new wallet, your existing wallet will be lost unless you backed up your recovery phrase", preferredStyle: .alert)
        let alertActionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionOk = UIAlertAction.init(title: "Ok", style: .default, handler: { (ok) in
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "createWalletVC") as! CreateWalletViewController
            self.show(vc, sender: nil)
        })
        alert.addAction(alertActionCancel)
        alert.addAction(alertActionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //""Override existing wallet?
    //If you create a new wallet, your existing wallet will be lost unless you backed up your recovery phrase
    
}


