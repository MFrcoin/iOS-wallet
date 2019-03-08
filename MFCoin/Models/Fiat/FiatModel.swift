//
//  FiatModel.swift
//  MFCoin
//
//  Created by Admin on 28.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class FiatModel: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var value: Float = 0.0
    @objc dynamic var head = false
    
    convenience init(name: String, value: Float) {
        self.init()
        self.name = name
        self.value = value
    }
}

