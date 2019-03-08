//
//  Constants.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//
import UIKit

class Constants {
    static let MNEMONIC_KEY = "mnemonic"
    static let PASS_KEY = "password_key"
    static let BLUECOLOR = UIColor.init(red: 33/255, green: 184/255, blue: 186/255, alpha: 1)
    static let CORNER_RADIUS: CGFloat = 5
    static let SEQUENCE_FINAL: UInt32 = 0xffffffff
    static let PURPOSE = 44
    static let UPDATE = NSNotification.Name(rawValue: "UpdateInfo")
    static let BIOMETRICS = "biometrics_bool"
}

enum FiatHeads: String, CaseIterable {
    case rub = "rub"
    case usd = "usd"
    case gbp = "gbp"
    case eur = "eur"
}
