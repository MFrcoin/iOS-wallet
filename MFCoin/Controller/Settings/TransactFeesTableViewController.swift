//
//  TransactFeesTableViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class TransactFeesTableViewController: UITableViewController, UITextFieldDelegate {
    
    var walletsCoins: Results<CoinModel>?
    let realm = RealmHelper.shared
    let convert = ConvertValue.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        walletsCoins = realm.selCoins
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walletsCoinsUnw = walletsCoins else { return 0 }
        return walletsCoinsUnw.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transFeesCell", for: indexPath) as! TransactFeesTableViewCell
        if let coins = walletsCoins {
            let coin = coins[indexPath.row]
            cell.logoImage.image = UIImage(named:coin.logo)
            cell.coinNameLabel.text = coin.fullName
            cell.shortCoinNameLabel.text = coin.shortName
            let convertFee = convert.convert(value: coin.fee)
            cell.amountLabel.text = "\(convertFee)"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let coins = walletsCoins {
            let coin = coins[indexPath.row]
            setCoinFeesAlert(coin)
        }
    }
    
    private func setCoinFeesAlert(_ coin: CoinModel) {
        let alert = UIAlertController.init(title: "\(coin.fullName) transaction fees", message: "The fee value is per kilobyte of transaction data.", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            let convertFee = self.convert.convert(value: coin.fee)
            
            textField.text = String(convertFee)
            textField.delegate = self
            textField.keyboardType = .decimalPad
        }
        let alertActionDefault = UIAlertAction.init(title: "Default", style: .default, handler: {
            (def) in
            if let tf = alert.textFields {
                let convertFee = self.convert.convert(value: Constants.DEFAULTFEE)
                tf[0].text = String(convertFee)
                try! Realm().write {
                    coin.fee = Constants.DEFAULTFEE
                }
                self.tableView.reloadData()
            }
        })
        let alertActionCancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let alertActionOk = UIAlertAction.init(title: "Ok", style: .default, handler: { (ok) in
            if let tf = alert.textFields {
                if let fee = tf[0].text {
                    if let dFee = Double(fee) {
                        let convertFee = self.convert.convertValueToSatoshi(value: dFee)
                        try! Realm().write{
                            coin.fee = convertFee
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
        alert.addAction(alertActionDefault)
        alert.addAction(alertActionCancel)
        alert.addAction(alertActionOk)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
