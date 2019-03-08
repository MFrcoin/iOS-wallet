//
//  CoinDerPaths.swift
//  MFCoin
//
//  Created by Admin on 01.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import RealmSwift

class CoinDerPaths: Object {
    
    @objc dynamic var path = ""
    @objc dynamic var isUsed = false
    @objc dynamic var address = ""
    @objc dynamic var balance = 0
    @objc dynamic var unBalance = 0
    @objc dynamic var change = 0
    @objc dynamic var index = 0
    @objc dynamic var wif = ""
    
    var input = List<Input>()
    var output = List<Output>()
    
    convenience init(path: String, address: String, change: Int, index: Int, wif: String) {
        self.init()
        self.path = path
        self.address = address
        self.change = change
        self.index = index
        self.wif = wif
    }
}
