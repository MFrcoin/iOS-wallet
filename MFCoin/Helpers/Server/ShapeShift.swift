//
//  ShapeShift.swift
//  MFCoin
//
//  Created by Admin on 24.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation

class ShapeShift {
    static let shared = ShapeShift()
    let feeUrl = "https://shapeshift.io/getcoins"
    
 
    
    //get MINERFEE
    //Current Coins List  GET shapeshift.io/getcoins 
    //{"BTC":{"symbol":"BTC","name":"Bitcoin","image":"https://shapeshift.io/images/coins/bitcoin.png","imageSmall":"https://shapeshift.io/images/coins-sm/bitcoin.png","status":"available","minerFee":0.0002},
    //"BCH":{"symbol":"BCH","name":"BitcoinCash","image":"https://shapeshift.io/images/coins/bitcoincash.png","imageSmall":"https://shapeshift.io/images/coins-sm/bitcoincash.png","status":"available","minerFee":0.0001}}
    
    //GET Validate an address, given a currency symbol and address shapeshift.io/validateAddress/[address]/[symbol]
    //{ "isvalid": true }
    
//    func getFees() {
//        guard let url = URL(string: feeUrl) else {return}
//        
//        let session = URLSession.shared
//        session.dataTask(with: url) { (data, _, error) in
//            guard let data = data else { return }
//            do {
//                let json = try JSONDecoder().decode(MinerFee.self, from: data)
//                //RealmHelper.shared.saveFee(json)
//            } catch {
//                print(error)
//            }
//            }.resume()
//    }
//    
//
//}
//
//struct MinerFee: Codable {
//    var coin: [String]
//    struct Result: Codable {
//        var minerFee: Double
//        private enum ResultKeys: String, CodingKey {
//            case minerFee = "minerFee"
//            
//        }
//    }
//    let result: [Result]
}

