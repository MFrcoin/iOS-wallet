//
//  WalletTableViewController.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class WalletTableViewController: UITableViewController {
    
    let realmManager = RealmHelper.shared
    let kitManager = KitManager.shared
    var walletsCoins: Results<CoinModel>?
    let convert = ConvertValue.shared
    var head = RealmHelper.shared.getHeadFiat()
    
    override func viewDidLoad() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl
        walletsCoins = realmManager.selCoins
        self.tabBarController?.navigationItem.title = realmManager.getTotalAmount()
        self.tableView.refreshControl?.beginRefreshing()
        kitManager.getBalances()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
        try! Realm().refresh()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
    }
    
    @objc func update() {
        head = RealmHelper.shared.getHeadFiat()
        walletsCoins = realmManager.selCoins
        guard let walletsUnw = walletsCoins else {return}
        for coin in walletsUnw {
            realmManager.updateBalance(coin: coin)
        }
        try! Realm().refresh()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.tabBarController?.navigationItem.title = self.realmManager.getTotalAmount()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walletsCoinsUnw = walletsCoins else { return 0 }
        return walletsCoinsUnw.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletsCoinsCell", for: indexPath) as! WalletTableViewCell
        if let walletsCoinsUnw = walletsCoins {
            let coin = walletsCoinsUnw[indexPath.row]
            cell.coin = coin
            cell.coinsNameLabel.text = coin.fullName
            cell.coinsPriceLabel.text = "= \(coin.price) \(head.name)"
            cell.coinsLogo.image = UIImage(named: coin.logo)
            cell.coinsFiatValueLabel.text = "\(Float(coin.fiatPrice))"
            let convertBalance = convert.convertValue(value: coin.balance)
            if coin.unBalance > 0 {
                cell.coinsValueLabel.text = "!\(convertBalance) \(coin.shortName)"
            } else {
                cell.coinsValueLabel.text = "\(convertBalance) \(coin.shortName)"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let walletsCoinsUnw = walletsCoins {
                let coin = walletsCoinsUnw[indexPath.row]
                realmManager.coinIsSelected(coin: coin, selected: false)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WalletTableViewCell
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "containerVC") as! ContainerViewController
        vc.coin = cell.coin
        show(vc, sender: nil)
    }    
}

extension WalletTableViewController {
    func subscribe() {
        //        let bag = DisposeBag()
        //        var publishSubject = PublishSubject<CoinModel>()
        //        publishSubject.
    }
}
