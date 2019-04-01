//
//  FiatTicker.swift
//  MFCoin
//
//  Created by Admin on 27.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

struct Fiat: Codable {
    var id: String
    var symbol: String
    var current_price: Double
}

class FiatTicker {
    let realm = RealmHelper.shared
    let gecko = "https://api.coingecko.com/api/v3/coins/markets?vs_currency="

    func setPrice() {
        let coins = realm.getAllCoins()
        let fiatHead = realm.getHeadFiat()
        for coin in coins {
            getFiatCourses(coin, fiatHead.name)
        }
        getBTCCurrencies()
    }
    
    private func getFiatCourses(_ coin: CoinModel, _ head: String) {
        let downHead = head.lowercased()
        let geckoUrl = "\(gecko)\(downHead)&ids=\(coin.name)&sparkline=false"
        guard let url = URL(string: geckoUrl) else {return}
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, _, error) in
            guard let data = data else {return}
            do {
                let json = try JSONDecoder().decode([Fiat].self, from: data)
                print(json)
                self.realm.saveFiatInCoin(json: json[0])
            } catch {
                print(error)
            }
        }.resume()
    }
    
    private func getBTCCurrencies() {
        for head in FiatHeads.allCases {
            let geckoUrl = "\(gecko)\(head)&ids=bitcoin&sparkline=false"
            guard let url = URL(string: geckoUrl) else {return}
            
            let session = URLSession.shared
            session.dataTask(with: url) { (data, _, error) in
                guard let data = data else {return}
                do {
                    let json = try JSONDecoder().decode([Fiat].self, from: data)
                    self.realm.saveFiatPrice(name: head.rawValue, value: Float(json[0].current_price))
                } catch {
                    print(error)
                }
                }.resume()
        }
    }
}






//    [
//    {
//    "id": "mfcoin",
//    "symbol": "mfc",
//    "name": "MFCoin",
//    "image": "missing_large.png",
//    "current_price": 0.00797684905573246,
//    "market_cap": 144564.681996993,
//    "market_cap_rank": 1204,
//    "total_volume": 1209.15845307292,
//    "high_24h": 0.00879840353277862,
//    "low_24h": 0.00536268738719014,
//    "price_change_24h": 0.00261215218841151,
//    "price_change_percentage_24h": 48.6915151594759,
//    "market_cap_change_24h": 47285.274328729,
//    "market_cap_change_percentage_24h": 48.6076914550898,
//    "circulating_supply": "18123030.9094421",
//    "total_supply": 50000000,
//    "ath": 0.0123306302973481,
//    "ath_change_percentage": -35.3086674129869,
//    "ath_date": "2018-08-26T20:46:01.663Z",
//    "roi": null,
//    "last_updated": "2019-03-01T06:18:57.795Z"
//    }
//    ]
