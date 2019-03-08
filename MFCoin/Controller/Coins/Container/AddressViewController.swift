//
//  AddressViewController.swift
//  MFCoin
//
//  Created by Admin on 13.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var coin: CoinModel?
    let kitManager = KitManager.shared
    
    override func viewDidLoad() {
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let coinUnw = coin else { return }
        setInfo(coinUnw)
    }
    
    private func setInfo(_ coin: CoinModel) {
        kitManager.getListunspent(coin)
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell
        if let coinUnw = coin {
            cell.addressLabel.text = coinUnw.currentAddrE
            cell.coinCountLabel.text = "123456"
            cell.coinImage.image = UIImage(named: coinUnw.logo)
            cell.statusLabel.text = "Sended"
            cell.fiatCountLabel.text = "100"
            cell.dateLabel.text = "01.08.2018"
        }
        return cell
    }

}
