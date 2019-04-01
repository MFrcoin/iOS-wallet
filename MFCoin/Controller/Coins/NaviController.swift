//
//  NaviController.swift
//  MFCoin
//
//  Created by Admin on 31.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class NaviController: UINavigationController {
    var titleObservation: NSKeyValueObservation?
    var head = RealmHelper.shared.getHeadFiat()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.largeTitleDisplayMode = .always
        titleObservation = UserDefaults.standard.observe(\.myBalance, options: [.new]) { (vc, change) in
            guard let newValue = change.newValue else { return }
            self.head = RealmHelper.shared.getHeadFiat()
            self.navigationBar.topItem?.title = "\(newValue) \(self.head.name)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationBar.topItem?.title = "\(UserDefaults.standard.double(forKey: Constants.MYBALANCE)) \(head.name)"
    }
}
