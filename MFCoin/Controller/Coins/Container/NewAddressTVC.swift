//
//  NewAddressTVC.swift
//  MFCoin
//
//  Created by Admin on 02.04.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit
import RealmSwift

class NewAddressTVC: UITableViewController {
    var coin: CoinModel?
    var addressDict = [Int: CoinDerPaths]()
    let kitManager = KitManager.shared
    let coinList = CoinsList.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAddress))
        self.navigationItem.setRightBarButton(barButton, animated: false)
    }
    
    @objc func addAddress() {
        guard let coinUnw = coin else {return}
        let mnemonic = kitManager.getWords()
        let phrase = kitManager.getPhrase()
        let index = coinUnw.derPaths.filter("change = 0").count
        
        let hdWallet = HDWallet.init(mnemonic: mnemonic, passphrase: phrase)
        let purpose = 44
        
        let derPathExt = DerivationPath.init(purpose: purpose, coinType: coinUnw.index, account: 0, change: 0, address: index)
        let derPathInt = DerivationPath.init(purpose: purpose, coinType: coinUnw.index, account: 0, change: 1, address: index)
        
        guard let prefixPrivate = coinList.getPrivateKeyPrefix(coin: coinUnw) else { return }
        let privKeyExtWif = hdWallet.getKey(at: derPathExt).toWIF(prefix: [prefixPrivate])
        let privKeyIntWif = hdWallet.getKey(at: derPathInt).toWIF(prefix: [prefixPrivate])
        
        let privKeyExt = hdWallet.getKey(at: derPathExt)
        let privKeyInt = hdWallet.getKey(at: derPathInt)
        
        guard let prefixP2PKH = coinList.getP2PKHPrefix(coin: coinUnw) else {return}
        let addrLegExt = privKeyExt.publicKey(compressed: true).legacyBitcoinAddress(prefix: prefixP2PKH).base58String
        let addrLegInt = privKeyInt.publicKey(compressed: true).legacyBitcoinAddress(prefix: prefixP2PKH).base58String
        save(coinUnw, derPathExt.description, addrLegExt, 0, index, privKeyExtWif)
        save(coinUnw, derPathInt.description, addrLegInt, 1, index, privKeyIntWif)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let coinUnw = coin else {return 0}
        return coinUnw.derPaths.filter("change = 0").count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressesTVC", for: indexPath) as! AddressesTableViewCell
        if let coinUnw = coin {
            let info = coinUnw.derPaths.filter("change = 0")[indexPath.row]
            addressDict.updateValue(info, forKey: indexPath.row)
            cell.addressLabel.text = info.address
            cell.logoImage.image = UIImage(named: coinUnw.logo)
            if coinUnw.currentAddrE == info.address {
                cell.accessoryType = .checkmark
            } else { cell.accessoryType = .none }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let coinderPath = addressDict[indexPath.row] {
            guard let coinUnw = coin else {return}
            try! Realm().write {
                coinUnw.currentAddrE = coinderPath.address
            }
        }
        tableView.reloadData()
    }

    private func save(_ coin: CoinModel, _ derPath: String,
                      _ address: String, _ change: Int,
                      _ index: Int, _ wif: String) {
        let realm = try! Realm()
        try! realm.write {
            let path = coin.derPaths.filter("path = %@", derPath)
            if path.count == 0 {
                let dPath = CoinDerPaths.init(path: derPath, address: address, change: change, index: index, wif: wif)
                coin.derPaths.append(dPath)
            }
        }
    }
}
