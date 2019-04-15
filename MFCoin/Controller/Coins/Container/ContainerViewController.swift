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
    let kitManager = KitManager.shared
    let realm = RealmHelper.shared
    var titleObservation: NSKeyValueObservation?
    var timerFlag = false
    var timer: Timer? = nil
    
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
        self.navigationItem.title = "\(UserDefaults.standard.double(forKey: Constants.MYBALANCE)) \(head.name)"
        titleObservation = UserDefaults.standard.observe(\.myBalance, options: [.new]) { (vc, change) in
            guard let newValue = change.newValue else { return }
            self.head = RealmHelper.shared.getHeadFiat()
            self.navigationItem.title = "\(newValue) \(self.head.name)"
        }
        segmentedControl.addTarget(self, action: #selector(selectedDidChange(sender:)), for: .valueChanged)
        updateView()
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
        guard let coinUnw = coin else { return }
        kitManager.updateHistory()
        kitManager.getTransactions(coinUnw)
        kitManager.getListunspent(coinUnw)
        kitManager.getBalances(coinUnw)
        realm.updateBalance(coin: coinUnw)
        realm.updateTitleBalance()
        NotificationCenter.default.post(name: Constants.UPDATE, object: nil)
    }
    
    @objc func selectedDidChange(sender: UISegmentedControl) {
        updateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        time()
        NotificationCenter.default.addObserver(self, selector: #selector(internetReactions), name: .flagsChanged, object: Network.reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Constants.SUCCESS, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timerFlag = false
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: Constants.SUCCESS, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }
    
    @objc private func update() {
        print("container update")
        segmentedControl.selectedSegmentIndex = 1
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

extension ContainerViewController {
    
    @objc func internetReactions() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .wifi, .wwan:
            time()
        default:
            timer?.invalidate()
            timerFlag = false
            let alert = UIAlertController.init(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
            let alertActionCancel = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(alertActionCancel)
            self.present(alert, animated: true)
        }
    }
}
