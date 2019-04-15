//
//  WalletsViewController.swift
//  MFCoin
//
//  Created by Admin on 16.04.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class WalletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realmManager = RealmHelper.shared
    let kitManager = KitManager.shared
    var walletsCoins: Results<CoinModel>?
    let convert = ConvertValue.shared
    var head = RealmHelper.shared.getHeadFiat()
    var timerFlag = false
    var timer: Timer? = nil
    var startFlag = false
    
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshBalances), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        walletsCoins = realmManager.selCoins
        head = RealmHelper.shared.getHeadFiat()
        self.navigationItem.title = "\(UserDefaults.standard.double(forKey: Constants.MYBALANCE)) \(head.name)"
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
        animateLoading(true)
        time()
    }
    
    private func animateLoading(_ status: Bool) {
        if status {
            loaderView.isHidden = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            loaderView.isHidden = true
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
            tableView.setContentOffset(CGPoint(x: 0, y: -0.3), animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        animateLoading(false)
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        timerFlag = false
        timer?.invalidate()
    }
    
    private func time() {
        if !timerFlag {
            timerFlag = true
            timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            if let timerUnw = timer {
                RunLoop.current.add(timerUnw, forMode: .common)
            }
            self.timer?.fire()
        }
    }
    
    @objc func timerFired() {
        DispatchQueue.global().async {
            self.kitManager.updateHistory()
            self.kitManager.getOnline()
            self.realmManager.updateTitleBalance()
        }
        if let coins = self.walletsCoins {
            for coin in coins {
                kitManager.getBalances(coin)
                realmManager.updateBalance(coin: coin)
                update()
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData ()
        }
        
    }
    
    @objc func refreshBalances() {
        time()
        guard let walletsCoinsUnw = walletsCoins else { return  }
        if walletsCoinsUnw.count > 0 {
            animateLoading(true)
        }
    }
    
    @objc func update() {
        head = realmManager.getHeadFiat()
        walletsCoins = realmManager.selCoins
        DispatchQueue.main.async {
            self.tableView.reloadData ()
            self.animateLoading(false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walletsCoinsUnw = walletsCoins else { return 0 }
        return walletsCoinsUnw.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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


extension WalletsViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            refreshBalances()
        default:
            timerFlag = false
            timer?.invalidate()
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            present(alert, animated: true)
        }
    }
}
