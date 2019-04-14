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
    var timerFlag = false
    var timer: Timer? = nil
    var loyautFlag = false
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.BLUECOLOR
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.refreshControl?.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        timer?.invalidate()
        loyautFlag = false
    }
    
    override func viewWillLayoutSubviews() {
        if !loyautFlag {
            loyautFlag = true
            tableView.refreshControl?.beginRefreshing()
            guard let coinUnw = coin else { return }
            setInfo(coinUnw)
            time()
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
        guard let coinUnw = coin else { return }
        kitManager.updateHistory()
        kitManager.getTransactions(coinUnw)
    }
    
    private func setInfo(_ coin: CoinModel) {
        histories = realm.getTxHistories(coin: coin)
        kitManager.getTransactions(coin)
        kitManager.getListunspent(coin)
    }
    
    @objc func refresh() {
        tableDict.removeAll()
        guard let coinUnw = coin else { return }
        DispatchQueue.main.async {
            self.tableView.refreshControl?.beginRefreshing()
        }
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
        if let historiesUnw = histories {
            let history = historiesUnw[indexPath.row]
            print("nowDate \(history.nowDate)")
            tableDict.updateValue(history, forKey: indexPath.row)
            if history.received {
                cell.fillImageView.image = fillImage(conf: history.confirmation)
                cell.coinImage.image = UIImage(named: "Received")
                if history.confirmation < 4 {
                    cell.coinImage.image = UIImage(named: "Received0")
                    cell.statusLabel.textColor = .gray
                    cell.coinCountLabel.textColor = .gray
                } else {
                    cell.statusLabel.textColor = Constants.GREENCOLOR
                    cell.coinCountLabel.textColor = Constants.GREENCOLOR
                }
                cell.statusLabel.text = "Received"
                cell.coinCountLabel.text = "+\(history.value)"
            } else {
                cell.fillImageView.image = fillImage(conf: history.confirmation)
                cell.coinImage.image = UIImage(named: "Sended")
                if history.confirmation < 4 {
                    cell.coinImage.image = UIImage(named: "Sended0")
                    cell.statusLabel.textColor = .gray
                    cell.coinCountLabel.textColor = .gray
                } else {
                    cell.statusLabel.textColor = .red
                    cell.coinCountLabel.textColor = .red
                }
                cell.statusLabel.text = "Send to"
                cell.coinCountLabel.text = "-\(history.value)"
            }
            cell.addressLabel.text = history.address
            cell.dateLabel.text = dateFormat(milliseconds: history.date)
        }
        return cell
    }
    
    private func fillImage(conf: Int) -> UIImage {
        switch conf {
        case 0:
            guard let image = UIImage(named:"fill0.png") else { return UIImage() }
            return image
        case 1:
            guard let image = UIImage(named:"fill1.png") else { return UIImage() }
            return image
        case 2:
            guard let image = UIImage(named:"fill2.png") else { return UIImage() }
            return image
        case 3:
            guard let image = UIImage(named:"fill3.png") else { return UIImage() }
            return image
        default: return UIImage()
        }
        
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
        if milliseconds == 0 { return "" }
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
