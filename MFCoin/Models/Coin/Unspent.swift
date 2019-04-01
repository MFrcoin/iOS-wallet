//
//  Unspent.swift
//  MFCoin
//
//  Created by Admin on 30.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class Unspent: Object {
    @objc dynamic var txHash = ""
    @objc dynamic var txPos = 0
    @objc dynamic var height = 0
    @objc dynamic var value = 0
    @objc dynamic var isUnspent = false
    
    convenience init(result: Listunspent.Result) {
        self.init()
        self.txHash = result.tx_hash ?? ""
        self.txPos = result.tx_pos ?? 0
        self.height = result.height ?? 0
        self.value = result.value ?? 0
        self.isUnspent = false
    }
}
