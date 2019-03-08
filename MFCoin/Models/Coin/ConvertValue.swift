//
//  ConvertValue.swift
//  MFCoin
//
//  Created by Admin on 20.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation

public class ConvertValue {
    static let shared = ConvertValue()
    
    func convertSatoshToFiat(satoshi : Int , rate : Double) -> Float{
        let bitcoins : Double = Double(satoshi) / 100000000
        let localRate = Float(bitcoins * rate)
        return round(localRate * 1000) / 1000
    }
    
    func convertFiatToSatoshi(fiat : Float , rate : Double) -> Int {
        let bitcoins : Double = Double(fiat) / rate
        return Int(bitcoins * 100000000)
    }
    
    public func convertValue(value: Int) -> Double {
        if value >= 2 {
            return Double(value/100000000)
        }
        return Double(value)
    }
    
    
    
    
    
//    class func getFiatBalanceString(model : CurrencyPrice?, satoshi : Int , withCode : Bool) -> String{
//        if model != nil {
//            let rate = convertSatoshToFiat(satoshi: satoshi, rate: Double(model!.rate!))
//            return "\(rate)" + (withCode ? " - \(model!.code!)" : "")
//        } else {
//            return ""
//        }
//    }
    
}
