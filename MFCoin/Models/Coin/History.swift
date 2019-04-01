//
//  History.swift
//  MFCoin
//
//  Created by Admin on 24.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class History: Object {
    @objc dynamic var height = 0
    @objc dynamic var txId = ""
    
    convenience init(txId: String, height: Int) {
        self.init()
        self.txId = txId
        self.height = height
    }
}
