//
//  CoinsTableViewCell.swift
//  MFCoin
//
//  Created by Admin on 22.12.2018.
//  Copyright © 2018 Egor Vdovin. All rights reserved.
//

import UIKit

class CoinsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var coinsLogo: UIImageView!
    
    @IBOutlet weak var coinsName: UILabel!
    
    @IBOutlet weak var coinsPrice: UILabel!
    
    var coin: CoinModel?
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        self.accessoryType = selected ? .checkmark : .none
//    }

}
