//
//  ContainerViewController.swift
//  MFCoin
//
//  Created by Admin on 16.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var rootView: UIView!
    
    var coin: CoinModel?
    var head = RealmHelper.shared.getHeadFiat()
    
    lazy var receiveViewController: ReceiveViewController = {
        let sb = UIStoryboard.init(name: "Coins", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "receiveVC") as! ReceiveViewController
        vc.coin = coin
        self.addVCasChildVC(childVC: vc)
        return vc
    }()
    
    lazy var addressViewController: AddressViewController = {
        let sb = UIStoryboard.init(name: "Coins", bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: "addressVC") as! AddressViewController
        vc.coin = coin
        self.addVCasChildVC(childVC: vc)
        return vc
    }()
    
    lazy var sendViewController: SendViewController = {
        let sb = UIStoryboard.init(name: "Coins", bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: "sendVC") as! SendViewController
        vc.coin = coin
        self.addVCasChildVC(childVC: vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        segmentedControl.addTarget(self, action: #selector(selectedDidChange(sender:)), for: .valueChanged)
        updateView()
    }
    
    @objc func selectedDidChange(sender: UISegmentedControl) {
        updateView()
    }

    private func updateView() {
        receiveViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 0)
        addressViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 1)
        sendViewController.view.isHidden = !(segmentedControl.selectedSegmentIndex == 2)
    }
    
    private func addVCasChildVC(childVC: UIViewController) {
        addChild(childVC)
        rootView.addSubview(childVC.view)
        childVC.view.frame = rootView.bounds
        childVC.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childVC.didMove(toParent: self)
    }
    
}
