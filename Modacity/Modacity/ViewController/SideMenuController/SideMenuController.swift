//
//  SideMenuController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import LGSideMenuController

class SideMenuController: LGSideMenuController {
    
    @IBOutlet weak var imageViewPremiumBadge: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ModacityAnalytics.LogStringEvent("Opened Side Menu")
        self.swipeGestureArea = .full
        self.leftViewSwipeGestureRange = LGSideMenuSwipeGestureRangeMake(44, 88)
        self.leftViewWidth = 250
        self.leftViewBackgroundColor = Color.clear
        self.leftViewCoverColor = Color.clear
        self.leftViewPresentationStyle = .scaleFromBig
        self.isLeftViewSwipeGestureEnabled = false
        
        let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController")
        self.rootViewController = tabBarViewController
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumBadge), name: AppConfig.appNotificationPremiumUpgraded, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePremiumBadge()
    }
    
    @objc func updatePremiumBadge() {
        self.imageViewPremiumBadge.isHidden = !(PremiumUpgradeManager.manager.isPremiumUnlocked())
    }
}
