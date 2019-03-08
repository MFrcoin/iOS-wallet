//
//  QRCodeGenerate.swift
//  MFCoin
//
//  Created by Admin on 12.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class QRCodeGenerate {
    static let shared = QRCodeGenerate()
    
    func generateQRCode(from coin: CoinModel) -> UIImage? {
        let string = "\(coin.fullName):\(coin.currentAddrE)"
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    func generateQRCode(from words: String) -> UIImage? {
        let data = words.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
