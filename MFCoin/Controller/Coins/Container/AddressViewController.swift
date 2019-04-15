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
    var startFlag = false
    
    override func viewDidLoad() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.BLUECOLOR
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.UPDATE , object: nil)
        guard let coinUnw = coin else { return }
        histories = realm.getTxHistories(coin: coinUnw)
    }
    
    override func viewDidLayoutSubviews() {
        if !startFlag {
            startFlag = true
            self.tableView.refreshControl?.beginRefreshing()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.refreshControl?.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Constants.UPDATE, object: nil)
    }

    @objc func refresh() {
        tableView.refreshControl?.beginRefreshing()
        update()
    }
    
    @objc func update() {
        tableDict.removeAll()
        guard let coinUnw = coin else { return }
        histories = realm.getTxHistories(coin: coinUnw)
        tableView.refreshControl?.endRefreshing()
        DispatchQueue.main.async {
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


