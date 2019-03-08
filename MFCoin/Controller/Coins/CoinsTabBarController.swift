//
//  CoinsTabBarController.swift
//  MFCoin
//
//  Created by Admin on 08.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import UIKit

class CoinsTabBarController: UITabBarController {
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    //@IBOutlet weak var walletsSum: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:false)
        //navigationController?.navigationBar.largeTitleTextAttributes = ["432234.44"]
        
        //walletsSum.title = "432234.44"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "setCoins") as! SetCoinsTableViewController
        self.show(vc, sender: sender)
    }
    
  
    @IBAction func scanBarButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
}
