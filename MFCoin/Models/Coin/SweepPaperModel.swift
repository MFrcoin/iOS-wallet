//
//  SweepPaperModel.swift
//  MFCoin
//
//  Created by Admin on 02.04.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class SweepPaperModel: Object {
    @objc dynamic var privateKey = ""
    @objc dynamic var address = ""
    @objc dynamic var balance: Int64 = 0
    @objc dynamic var prefix = 0x33
    var unspent = List<Unspent>()
}
