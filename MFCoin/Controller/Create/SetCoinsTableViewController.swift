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
        self.navigationItem.largeTitleDisplayMode = .never
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
    }

    @objc func readyButtonPressed() {
        kit.initSelectedWallets()
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! CoinsTabBarController
        self.present(vc, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
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
            cell.coinsPrice.text = "\(Float(coin.fiatPrice))"
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

extension SetCoinsTableViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            kit.getOnline()
            FiatTicker().setPrice()
        default:
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            self.present(alert, animated: true)
        }
    }
}
