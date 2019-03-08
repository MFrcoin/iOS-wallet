//
//  RealmHelper.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
    
    static let shared = RealmHelper()
    
    func setCoins() {
        print("set Coins")
        clearSelectedCoins()
        let realm = try! Realm()
        for coin in SLIP.CoinType.allCases {
            if let coinStruct = CoinsList.shared.coinInit(coin: coin) {
                let coinModel = CoinModel.init(coinStruct: coinStruct)
                try! realm.write {
                    realm.add(coinModel)
                    print("add \(coinModel.shortName)")
                }
            }
        }
    }
    
    func coinIsSelected(coin: CoinModel, selected: Bool) {
        let realm = try! Realm()
        try! realm.write {
            coin.isSelected = selected
            print("isSelected \(coin.shortName)")
        }
    }
    
    func clearSelectedCoins() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            print("ALL DELETED")
        }
    }
}


//MARK: GETTER
extension RealmHelper {
    
    func getCoins() -> Results<CoinModel> {
        let realm = try! Realm()
        let result = getSelectedCoins()
        if result.count == 0 {
            setCoins()
            return realm.objects(CoinModel.self)
        }
        let coinsCount = getCoinsCount()
        if result.count > 0 && result.count < coinsCount {
            return getUnSelectedCoins()
        }
        return result
    }
    
    var selCoins: Results<CoinModel> {
        return getSelectedCoins()
    }
    
    private func getSelectedCoins() -> Results<CoinModel> {
        let realm = try! Realm()
        let result = realm.objects(CoinModel.self).filter("isSelected == true").sorted(byKeyPath: "name")
        return result
    }
    
    private func getUnSelectedCoins() -> Results<CoinModel> {
        let realm = try! Realm()
        let result = realm.objects(CoinModel.self).filter("isSelected == false").sorted(byKeyPath: "name")
        return result
    }
    
    private func getCoinsCount() -> Int {
        var answer = 0
        for coin in SLIP.CoinType.allCases {
            if CoinsList.shared.coinInit(coin: coin) != nil {
                answer += 1
            }
        }
        return answer
    }
    
    func getHeadFiat() -> FiatModel {
        let realm = try! Realm()
        let fiat = realm.objects(FiatModel.self).filter("head == true")
        if fiat.count == 0 {
            try! realm.write {
                for fiat in FiatHeads.allCases {
                    let fiatNew = FiatModel.init(name: fiat.rawValue.uppercased(), value: 0.0)
                    if fiat.rawValue == FiatHeads.usd.rawValue {
                        fiatNew.head = true
                    }
                    realm.add(fiatNew)
                }
            }
            return getHeadFiat()
        }
        return fiat[0]
    }
    
    func getFiatsPrices() -> Results<FiatModel> {
        let realm = try! Realm()
        let result = realm.objects(FiatModel.self).sorted(byKeyPath: "name")
        if result.count == 0 {
            for fiat in FiatHeads.allCases {
                let exchange = FiatModel.init(name: fiat.rawValue.uppercased(), value: 0.0)
                realm.add(exchange)
                return getFiatsPrices()
            }
        }
        return result
    }
    
    func getTotalAmount() -> String {
        var totalAmount:Float = 0
        let coins = getSelectedCoins()
        for coin in coins {
            totalAmount += coin.price
        }
        return "\(totalAmount)"
    }
    
}


//MARK: SAVE
extension RealmHelper {
    func updateBalance(coin: CoinModel) {
        let realm = try! Realm()
        var balance = 0
        var unBalance = 0
        for path in coin.derPaths {
            balance += path.balance
            unBalance += path.unBalance
        }
        try! realm.write {
            coin.balance = balance
            coin.unBalance = unBalance
            let fiatBalance = ConvertValue().convertSatoshToFiat(satoshi: coin.balance, rate: coin.fiatPrice)
            coin.price = fiatBalance
        }
    }
    
    func saveCurrentAddress(coin: CoinModel, ext: String) {
        let realm = try! Realm()
        try! realm.write {
            coin.currentAddrE = ext
        }
    }
    
    func saveFiatInCoin(json: Fiat) {
        let realm = try! Realm()
        try! realm.write {
            let coin = realm.objects(CoinModel.self).filter("name = %@", json.id)
            if coin.count > 0 {
                coin[0].fiatPrice = json.current_price
                let balance = coin[0].balance
                coin[0].price =  ConvertValue.shared.convertSatoshToFiat(satoshi: balance, rate: json.current_price)
            }
        }
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
        }
    }
    
    func saveFiatPrice(name: String, value: Float) {
        let upName = name.uppercased()
        let realm = try! Realm()
        try! realm.write {
            let result = realm.objects(FiatModel.self).filter("name = %@", upName)
            if result.count > 0 {
                result[0].value = value
            } else {
                let exchange = FiatModel.init(name: upName, value: value)
                realm.add(exchange)
            }
        }
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
        }
    }
    
    func saveFee(_ array: Array<Any>) {
        print("array \(array)")
        let realm = try! Realm()
        try! realm.write {
            let coins = selCoins
            for coin in coins {
                
            }
        }
    }
}
