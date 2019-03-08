//
//  History.swift
//  MFCoin
//
//  Created by Admin on 24.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import RealmSwift


class Input: Object {
    @objc dynamic var txHash = ""
    @objc dynamic var txPos = 0
    @objc dynamic var height = 0
    @objc dynamic var value: Int = 0
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

class Output: Object {
    @objc dynamic var id = ""
    @objc dynamic var txHash = ""
    @objc dynamic var height = 0
    @objc dynamic var value: Int = 0
    @objc dynamic var txId: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var toAddress = ""
    
    convenience init(id: String, txHash: String, height: Int, balance: Int, txId: String) {
        self.init()
        self.id = id
        self.txHash = txHash
        self.height = height
        self.value = balance
        self.txId = txId
        self.date = Date()
    }
}
