//
//  RecoveryPhraseViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class RecoveryPhraseViewController: UIViewController {
    
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var qrImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        let phrase = KitManager.shared.getWords()
        if let image = QRCodeGenerate.shared.generateQRCode(from: phrase) {
            qrImage.image = image
        }
        phraseLabel.text = phrase
    }
}
