//
//  ViewController.swift
//  MFCoin
//
//  Created by Admin on 22.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit
//import BitcoinKit


class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    //""Override existing wallet?
    //If you create a new wallet, your existing wallet will be lost unless you backed up your recovery phrase
    
}

//    func createWallet() {
//
//        do {
//            // from Testnet Cashaddr
//            let cashaddrTest = try!  AddressFactory.create("bchtest:pr6m7j9njldwwzlg9v7v53unlr4jkmx6eyvwc0uz5t")
//            print ("cashaddrTest \(cashaddrTest)")
//            // from Mainnet Cashaddr
//            let cashaddrMain = try! AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
//            print ("cashaddrMain \(cashaddrMain)")
//            // from Base58 format
//
//            let address = try! AddressFactory.create("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
//            print ("address \(address)")
//            print ("*---------------------*")
//        }
//        do {
//            let privateKey = PrivateKey(network: .testnet) // You can choose .mainnet or .testnet
//            let wallet = Wallet(privateKey: privateKey)
//            print ("privateKey \(privateKey)")
//            print ("wallet \(wallet)")
//            print ("*---------------------*")
//        }
//        do {
//            let wallet = try! Wallet(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
//            print ("wallet2 \(wallet)")
//            print ("*---------------------*")
//        }
//
//    }
