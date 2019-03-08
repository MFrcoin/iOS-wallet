//
//  ConvertValue.swift
//  MFCoin
//
//  Created by Admin on 20.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import RealmSwift

public class ConvertValue {
    static let shared = ConvertValue()
    let realm = RealmHelper.shared
    
    func convertSatoshToFiat(satoshi : Int, rate: Double) -> Float {
        let bitcoins : Double = Double(satoshi) / 100000000
        let localRate = Float(bitcoins * rate)
        return round(localRate * 1000) / 1000
    }
    
    func convertFiatToSatoshi(fiat : Float , rate : Double) -> Int {
        let bitcoins : Double = Double(fiat) / rate
        return Int(bitcoins * 100000000)
    }
    
    public func convertValue(value: Int) -> Float {
        if value >= 2 {
            return Float(value/100000000)
        }
        return Float(value)
    }
    
    public func convertValueToSatoshi(value: Double) -> Int {
        return Int(value*100000000)
    }
    

    
}
