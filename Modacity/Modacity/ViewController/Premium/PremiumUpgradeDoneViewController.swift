//
//  PremiumUpgradeViewController.swift
//  Modacity
//
//  Created by BC Engineer on 19/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PremiumUpgradeDoneViewController: UIViewController {
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonFreeTrialStart: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.buttonFreeTrialStart.layer.borderColor = Color(hexString: "#908FE6").cgColor
        self.buttonFreeTrialStart.layer.borderWidth = 1
     
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderViewHeight.constant = 84
        } else {
            self.constraintForHeaderViewHeight.constant = 64
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
