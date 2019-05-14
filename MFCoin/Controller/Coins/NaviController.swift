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
        self.navigationBar.topItem?.title = "\(UserDefaults.standard.double(forKey: Constants.MYBALANCE)) \(head.name)"
        titleObservation = UserDefaults.standard.observe(\.myBalance, options: [.new]) { (vc, change) in
            guard let newValue = change.newValue else { return }
            self.head = RealmHelper.shared.getHeadFiat()
            let titleText = "\(newValue) \(self.head.name)"
            DispatchQueue.main.async {
                self.navigationBar.topItem?.title = titleText
            }
        }
    }
}
