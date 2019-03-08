//
//  SetCoinsTableViewController.swift
//  MFCoin
//
//  Created by Admin on 07.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class SetCoinsTableViewController: UITableViewController {
    
    var coins: Results<CoinModel>?
    let realm = RealmHelper.shared
    let kit = KitManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        coins = realm.getCoins()
        tableView.allowsMultipleSelection = true
        let readyCoins = UIBarButtonItem.init(title: "Ready", style: .done, target: self , action: #selector(readyButtonPressed))
        self.navigationItem.rightBarButtonItem = readyCoins
    }

    @objc func readyButtonPressed() {
        
        kit.initSelectedWallets()
        
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! CoinsTabBarController
        show(vc, sender: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let coinsUnw = coins else { return 0 }
        return coinsUnw.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "createCoinsCell", for: indexPath) as! CoinsTableViewCell
        if let coinsUnw = coins {
            let coin = coinsUnw[indexPath.row]
            cell.coin = coin
            cell.coinsName.text = coin.name
            cell.coinsPrice.text = "\(coin.price)"
            cell.coinsLogo.image = UIImage(named:coin.logo)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CoinsTableViewCell {
            guard let coin = cell.coin else { return }
            if cell.accessoryType == .checkmark {
                realm.coinIsSelected(coin: coin, selected: false)
                cell.accessoryType = .none
            } else {
                realm.coinIsSelected(coin: coin, selected: true)
                cell.accessoryType = .checkmark
            }
        }
    }


}
