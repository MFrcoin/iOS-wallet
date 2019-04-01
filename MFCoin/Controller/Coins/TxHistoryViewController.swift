//
//  TxHistoryViewController.swift
//  MFCoin
//
//  Created by Admin on 31.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class TxHistoryViewController: UIViewController {
    
    var coin: CoinModel?
    var txHistory: TxHistory?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sentOrReceivedLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var txIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInfo()
    }
    
    private func setInfo() {
        guard let coinUnw = coin else {return}
        guard let txUnw = txHistory else {return}
        dateLabel.text = dateFormat(milliseconds: txUnw.date)
        statusLabel.text = "\(txUnw.status) confirmations"
        sentOrReceivedLabel.textColor = Constants.BLUECOLOR
        if txUnw.received {
            sentOrReceivedLabel.text = "Received"
        } else {
            sentOrReceivedLabel.text = "Sent"
        }
        coinsLabel.text = "\(txUnw.value) \(coinUnw.shortName)"
        addressLabel.text = "\(txUnw.address)"
        txIdLabel.text = "\(txUnw.txid)"
    }
    
    @IBAction func viewBlockButtonPressed(_ sender: UIButton) {
        guard let coinUnw = coin else {return}
        guard let txUnw = txHistory else {return}
        let url = CoinsList().getBlockchainUrl(coin: coinUnw)
        if let link = URL(string: "\(url)\(txUnw.txid)") {
            UIApplication.shared.open(link)
        }
    }
    
    private func dateFormat(milliseconds: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter.string(from: date)
    }
}
