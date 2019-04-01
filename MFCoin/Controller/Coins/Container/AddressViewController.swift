//
//  AddressViewController.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class AddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var coin: CoinModel?
    var histories: Results<TxHistory>?
    let kitManager = KitManager.shared
    let realm = RealmHelper.shared
    var tableDict = [Int: TxHistory]()
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading")
        refreshControl.tintColor = Constants.BLUECOLOR
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.refreshControl?.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }
    
    private func setInfo(_ coin: CoinModel) {
        histories = realm.getTxHistories(coin: coin)
        kitManager.getTransactions(coin)
        kitManager.getListunspent(coin)
    }
    
    @objc func refresh() {
        guard let coinUnw = coin else { return }
        tableView.refreshControl?.beginRefreshing()
        setInfo(coinUnw)
    }
    
    @objc func update() {
        tableDict.removeAll()
        guard let coinUnw = coin else { return }
        histories = realm.getTxHistories(coin: coinUnw)
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let historiesUnw = histories else { return 0 }
        return historiesUnw.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell
        if let coinUnw = coin {
            if let histories = histories {
                let history = histories[indexPath.row]
                tableDict.updateValue(history, forKey: indexPath.row)
                if history.received {
                    cell.statusLabel.textColor = Constants.GREENCOLOR
                    cell.statusLabel.text = "Received"
                    cell.coinCountLabel.textColor = Constants.GREENCOLOR
                    cell.coinCountLabel.text = "+\(history.value)"
                } else {
                    cell.statusLabel.textColor = .red
                    cell.statusLabel.text = "Send to"
                    cell.coinCountLabel.textColor = .red
                    cell.coinCountLabel.text = "-\(history.value)"
                }
                cell.addressLabel.text = history.address
                cell.coinImage.image = UIImage(named: coinUnw.logo)
                cell.dateLabel.text = dateFormat(milliseconds: history.date)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = tableDict[indexPath.row]
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "txHistoryVC") as! TxHistoryViewController
        vc.txHistory = history
        guard let coinUnw = coin else {return}
        vc.coin = coinUnw
        show(vc, sender: nil)
    }

    private func dateFormat(milliseconds: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy HH:mm"
        return formatter.string(from: date)
    }
}

extension AddressViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            refresh()
        default:
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            self.present(alert, animated: true)
        }
    }
}
