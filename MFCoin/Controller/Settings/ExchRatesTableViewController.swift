//
//  ExchRatesTableViewController.swift
//  MFCoin
//
//  Created by Admin on 22.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift


class ExchRatesTableViewController: UITableViewController {
    
    var results: Results<FiatModel>?
    let realm = RealmHelper.shared
    var fiatDict = [Int: String]()
    
    override func viewDidLoad() {
        results = realm.getFiatsPrices()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(update), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func update() {
        results = realm.getFiatsPrices()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let resultCount = results else { return 0 }
        return resultCount.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exchRatesCell", for: indexPath) as! ExchRatesTableViewCell
        if let resultUnw = results {
            let fiat = resultUnw[indexPath.row]
            cell.exchLabel.text = fiat.name
            cell.infoLabel.text = "1 BTC = \(fiat.value)"
            if fiat.head { cell.accessoryType = .checkmark
            } else { cell.accessoryType = .none }
            fiatDict.updateValue(fiat.name, forKey: indexPath.row)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let name = fiatDict[indexPath.row] {
            setHead(name: name)
        }
        tableView.reloadData()
    }
    
    private func setHead(name: String) {
        guard let resultUnw = results else {return}
        let realm = try! Realm()
        try! realm.write {
            for result in resultUnw {
                result.head = false
                if result.name == name {
                    result.head = true
                }
            }
        }
        FiatTicker().setPrice()
    }
}
