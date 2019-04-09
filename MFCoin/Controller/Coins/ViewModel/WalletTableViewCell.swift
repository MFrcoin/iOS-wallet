//
//  WalletTableViewCell.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinsLogo: UIImageView!
    @IBOutlet weak var coinsNameLabel: UILabel!
    @IBOutlet weak var coinsPriceLabel: UILabel!
    @IBOutlet weak var coinsFiatValueLabel: UILabel!
    @IBOutlet weak var coinsValueLabel: UILabel!
    
    var coin: CoinModel?
}
