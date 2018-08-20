//
//  SubscriptionTermsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 7/24/18.
//  Copyright © 2018 Modacity. All rights reserved.
//

import UIKit

class SubscriptionTermsViewController: UIViewController {
   
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.appConfigPrivacyUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.appConfigPrivacyUrlLink)!)
        }
    }
    
    @IBAction func onTerms(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.appConfigTermsUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.appConfigTermsUrlLink)!)
        }
    }
    
}
