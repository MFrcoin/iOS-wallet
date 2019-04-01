//
//  CoinModel.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class CoinModel: Object {
    
    @objc dynamic var index:Int = 0
    @objc dynamic var name = ""
    @objc dynamic var fullName = ""
    @objc dynamic var shortName = ""
    @objc dynamic var logo = ""
    @objc dynamic var coinsCount = ""
    @objc dynamic var price: Float = 0.0
    @objc dynamic var fiatPrice: Double = 0.0
    @objc dynamic var isSelected = false
    @objc dynamic var host = ""
    @objc dynamic var port:Int = 0
    @objc dynamic var currentAddrE = ""
    @objc dynamic var currentAddrI = ""
    @objc dynamic var balance: Int = 0
    @objc dynamic var unBalance: Int = 0
    @objc dynamic var fee: Int = 100000
    @objc dynamic var online = false
    var derPaths = List<CoinDerPaths>()
    
    convenience init(coinStruct: CoinStruct) {
        self.init()
        self.index = coinStruct.index
        self.name = coinStruct.name
        self.fullName = coinStruct.fullName
        self.shortName = coinStruct.shortName
        self.logo = coinStruct.logo
        self.price = 0
        self.balance = 0
        self.unBalance = 0
        self.fiatPrice = 0
        self.isSelected = false
        self.host = coinStruct.addr.host
        self.port = coinStruct.addr.port
        self.currentAddrE = ""
        self.currentAddrI = ""
        self.fee = 100000
        self.online = true
    }
}
