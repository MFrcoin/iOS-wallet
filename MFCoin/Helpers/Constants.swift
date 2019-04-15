//
//  Constants.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//
import UIKit

class Constants {
    static let MNEMONIC_KEY = "mn3m0n1c"
    static let PASSPHRASE_KEY = "p4ssphr4s3"
    static let PASS_KEY = "p4ssw0rd_k3y"
    static let BLUECOLOR = UIColor.init(red: 33/255, green: 184/255, blue: 186/255, alpha: 1)
    static let GREENCOLOR = UIColor.init(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    static let CORNER_RADIUS: CGFloat = 5
    static let SEQUENCE_FINAL: UInt32 = 0xffffffff
    static let PURPOSE = 44
    static let UPDATE = NSNotification.Name(rawValue: "UpdateInfo")
    static let INSUFFICIENTFUNDS = NSNotification.Name(rawValue: "InsufficientFunds")
    static let SENDED = NSNotification.Name(rawValue: "SENDED")
    static let SUCCESS = NSNotification.Name(rawValue: "SUCCESS")
    static let SUCCESS2 = NSNotification.Name(rawValue: "SUCCESS2")
    static let BIOMETRICS = "biometrics_bool"
    static let MYBALANCE = "myBalance"
    static let FIRSTTIME = "FirstTimeStart"
    static let DEFAULTFEE = 100000
}

enum FiatHeads: String, CaseIterable {
    case rub = "rub"
    case usd = "usd"
    case gbp = "gbp"
    case eur = "eur"
}
