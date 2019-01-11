//
//  CreateWalletViewController.swift
//  MFCoin
//
//  Created by Admin on 29.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit
import HSBitcoinKit
import HSHDWalletKit

class CreateWalletViewController: UIViewController {
    @IBOutlet weak var newSeedTV: UITextView!
    @IBOutlet weak var iSaveSeedSwitch: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newSeedTV.text = ""
        testFunc()
    }

    func testFunc() {
        do {
            let mnemonic = try! Mnemonic.generate(strength: .default, language: .english)
            print (mnemonic)
            for word in mnemonic {
                newSeedTV.text += "\(word) "
            }
            DAKeychain.shared["mnemonic"] = newSeedTV.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
//            let seed = Mnemonic.seed(mnemonic: mnemonic)
//           // print(seed.base64EncodedString())
//            let bitKit = BitcoinKit.init(withWords: mnemonic, coin: .bitcoin(network: .testNet))
//            print(bitKit.balance)
//            print(bitKit.debugInfo)
//            print(bitKit.lastBlockInfo?.headerHash ?? "headerHash")
//            print(bitKit.lastBlockInfo?.height ?? "height")
//            print(bitKit.lastBlockInfo?.timestamp ?? "timestamp")
//            print(bitKit.receiveAddress)
            
        }
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
    
    @IBAction func skipForward(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "Пропустить проверку", message: "Пожалуйста, удостоверьтесь во всяком таком и бла-бла-бла", preferredStyle: .alert)
        let alertActionOk = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionSkip = UIAlertAction.init(title: "Skip", style: .default, handler: { (alert) in
            let sb = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "setPass") as! SetPasswordViewController
            self.show(vc, sender: sender)
        })
        alert.addAction(alertActionOk)
        alert.addAction(alertActionSkip)
        self.present(alert, animated: true, completion: nil)
    }
    
}




//do {
//    let privateKey = PrivateKey(network: .mainnet) // You can choose .mainnet or .testnet
//    let wallet = Wallet(privateKey: privateKey)
//    print ("privateKey.description \(privateKey.description)")
//    print ("privateKey.publicKey() \(privateKey.publicKey())")
//    print ("wallet.privateKey.description \(wallet.privateKey.description)")
//    print ("wallet.publicKey.description \(wallet.publicKey.description)")
//    print ("wallet.network.dnsSeeds \(wallet.network.dnsSeeds)")
//    print ("wallet.network.name \(wallet.network.name)")
//    print ("wallet.network.alias \(wallet.network.alias)")
//    print ("wallet.network.port \(wallet.network.port)")
//    print ("wallet.network.scheme \(wallet.network.scheme)")
//    print ("wallet.serialized() \(wallet.serialized())")
//    print ("*---------------------*")
//}
//do {
//    let wallet = try! Wallet(wif: "92pMamV6jNyEq9pDpY4f6nBy9KpV2cfJT4L5zDUYiGqyQHJfF1K")
//    print ("wallet2.privateKey \(wallet.privateKey)")
//    print ("wallet2.publicKey \(wallet.publicKey)")
//    print ("*---------------------*")
//}


//    private func createSeed() {
//        do {
//            let mnemonic = try! Mnemonic.generate()
//            print ("mnemonic \(mnemonic)")
//            for word in mnemonic {
//                newSeedTV.text += "\(word) "
//            }
//            // Generate seed from the mnemonic
//            let seed = Mnemonic.seed(mnemonic: mnemonic)
//            let wallet = HDWallet(seed: seed, network: .mainnetBTC) //mainnet for BitcoinCash
//            let HDPrvKey = try! wallet.extendedPrivateKey(index: 0) //HDPrvKey.extended() получить приватный ключ!
//            let HDPubKey = try! wallet.extendedPublicKey(index: 0) //HDPubKey.extended()  получить публичный ключ!
//            let adres = try! wallet.receiveAddress().cashaddr
//            let adres58 = try! wallet.receiveAddress().base58
//
//
//            print ("HDPrvKey.extended() \(HDPrvKey.extended())")
//            print ("HDPubKey.extended() \(HDPubKey.extended())")
//            print ("receiveAddress \(adres)")
//            print ("receiveAddress 58 \(adres58)")
////            let adresprivateKey = try! wallet.privateKey(index: 1).toWIF()
////            let adreschangeAddress = try! wallet.changeAddress()
////            let adres = try! wallet.receiveAddress()
//           // print ("keychain \(keychain)")
//            //let privateKey2 = try! keychain.derivedKey(path: "m/").extended()
//            // print ("privateKey3 \(privateKey2)")
//
//            print ("HDPrvKey.privateKey() \(HDPrvKey.privateKey())")
//
//            print ("HDPubKey() \(HDPubKey.publicKey())")
//
//          //  print ("HDPrvKey.privateKey() \(HDPrvKey.privateKey())")
//            print ("HDPrvKey.childIndex \(HDPrvKey.childIndex)")
//            print ("HDPrvKey.depth \(HDPrvKey.depth)")
//            print ("HDPrvKey.network.name \(HDPrvKey.network.name)")
//            print ("HDPrvKey.network.scheme \(HDPrvKey.network.scheme)")
//
//            print ("HDPubKey.chainCode.base64EncodedString() \(HDPubKey.chainCode.base64EncodedString())")
//            print ("HDPubKey.fingerprint \(HDPubKey.fingerprint)")
//            print ("HDPubKey.network.alias \(HDPubKey.network.alias)")
//            print ("HDPubKey.network.name \(HDPubKey.network.name)")
//            print ("HDPubKey.network.scheme \(HDPubKey.network.scheme)")
//            print ("HDPubKey.publicKey().description \(HDPubKey.publicKey().description)")
//            print ("HDPubKey.publicKey().toLegacy().cashaddr \(HDPubKey.publicKey().toLegacy().cashaddr)")
//            print ("HDPubKey.publicKey().toLegacy().type \(HDPubKey.publicKey().toLegacy().type)")
//            print ("HDPubKey.publicKey().toCashaddr().base58 \(HDPubKey.publicKey().toCashaddr().base58)")
//            print ("*---------------------*")
////            print ("adresprivateKey \(adresprivateKey)")
////            print ("adreschangeAddress \(adreschangeAddress)")
////            print ("adres \(adres)")
////            print ("wallet3.balance.words \(wallet.balance.words)")
////            print ("wallet3.transactions \(wallet.transactions)")
////            print ("wallet3.unspentTransactions \(wallet.unspentTransactions)")
////            print ("wallet3.balance \(wallet.balance)")
////           // print ("wallet3 \(wallet.publicKey(index: <#T##UInt32#>))")
////            print ("*---------------------*")
//////        }
//////
//////        do {
////            // from Testnet Cashaddr
////            let cashaddrTest = try!  AddressFactory.create("\(adreschangeAddress)")
////
////            print ("cashaddrTest \(cashaddrTest.base58)")
////            // from Mainnet Cashaddr
////            let cashaddrMain = try! AddressFactory.create("bitcoincash:qpjdpjrm5zvp2al5u4uzmp36t9m0ll7gd525rss978")
////            print ("cashaddrMain \(cashaddrMain.base58)")
////            // from Base58 format
////
////            let address = try! AddressFactory.create("1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN")
////            print ("address \(address)")
////            print ("*---------------------*")
//        }







//        do {
//            // m/0'
//            let mnemonic = try! Mnemonic.generate()
//
//            print ("mnemonic2 \(mnemonic)")
//            let seed = Mnemonic.seed(mnemonic: mnemonic)
//            print ("seed \(seed)")
//            let privateKey = HDPrivateKey(seed: seed, network: .testnet)
//            print ("privateKey \(privateKey)")
//            let m0prv = try! privateKey.derived(at: 0, hardened: true)
//            print ("m0prv \(m0prv)")
//
//            // m/0'/1
//            let m01prv = try! m0prv.derived(at: 1)
//            print ("m01prv \(m01prv)")
//
//            // m/0'/1/2'
//            let m012prv = try! m01prv.derived(at: 2, hardened: true)
//            print ("m012prv \(m012prv)")
//            print ("*---------------------*")
//
//            //            let keychain = HDKeychain(seed: seed, network: .mainnet)
//            //            let privateKey2 = try! keychain.derivedKey(path: "m/44'/1'/0'/0/0").extended()
//            //            print ("keychain \(keychain)")
//            //            print ("privateKey3 \(privateKey2)")
//            //            let extendedKey = privateKey2.extended()
//            //            print ("extendedKey \(extendedKey)")
//        }
//}
