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
    var startFlag = false
    var timerFlag = false
    var timer: Timer? = nil
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        startVC()
    }
    
    private func startVC() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.BLUECOLOR
        refreshControl.addTarget(self, action: #selector(refreshBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl
        walletsCoins = realmManager.selCoins
        kitManager.updateHistory()
        if let coins = walletsCoins {
            for coin in coins {
                kitManager.getBalances(coin)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let walletsCoinsUnw = walletsCoins else { return  }
        if walletsCoinsUnw.count > 0 {
            tableView.refreshControl?.beginRefreshing()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if tableView.refreshControl?.isRefreshing ?? false {
            tableView.refreshControl?.endRefreshing()
        }
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        startFlag = false
        timer?.invalidate()
    }
    
    override func viewWillLayoutSubviews() {
        head = RealmHelper.shared.getHeadFiat()
        self.navigationItem.title = "\(UserDefaults.standard.double(forKey: Constants.MYBALANCE)) \(head.name)"
        if !startFlag {
            startFlag = true
            time()
            NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
            NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
            tableView.reloadData()
        }
    }
    
    private func time() {
        if !timerFlag {
            timerFlag = true
            timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            if let timerUnw = timer {
                RunLoop.current.add(timerUnw, forMode: .common)
            }
            self.timer?.fire()
        }
    }
    
    @objc func timerFired() {
        if let coins = walletsCoins {
            for coin in coins {
                kitManager.getBalances(coin)
            }
        }
    }
    
    @objc func refreshBalances() {
        if tableView.refreshControl?.isRefreshing ?? false {
            tableView.refreshControl?.endRefreshing()
        }
        guard let walletsCoinsUnw = walletsCoins else { return  }
        if walletsCoinsUnw.count > 0 {
            self.tableView.refreshControl?.beginRefreshing()
            kitManager.getOnline()
            if let coins = walletsCoins {
                for coin in coins {
                    kitManager.getBalances(coin)
                }
            }
        }
    }
    
    @objc func update() {
        head = realmManager.getHeadFiat()
        walletsCoins = realmManager.selCoins
        guard let walletsCoinsUnw = walletsCoins else { return  }
        if walletsCoinsUnw.count > 0 {
            realmManager.updateTitleBalance()
            kitManager.updateHistory()
            tableView.refreshControl?.endRefreshing()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
            let convertBalance = convert.convert(value: coin.balance)
            if coin.online {
                cell.coinsValueLabel.textColor = .black
                cell.coinsValueLabel.text = "\(convertBalance) \(coin.shortName)"
            } else {
                cell.coinsValueLabel.textColor = .red
                cell.coinsValueLabel.text = "Offline"
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
            walletsCoins = realmManager.selCoins
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "setCoins") as! SetCoinsTableViewController
        show(vc, sender: sender)
    }
}


extension WalletTableViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            kitManager.getOnline()
            refreshBalances()
        default:
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            present(alert, animated: true)
        }
    }
}
