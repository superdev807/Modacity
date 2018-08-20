//
//  SideMenuController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import LGSideMenuController

class SideMenuController: LGSideMenuController {
    
    @IBOutlet weak var imageViewPremiumBadge: UIImageView!
    @IBOutlet weak var constraintBadgeBottomSpace: NSLayoutConstraint!
    
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
        self.rootViewShouldAutorotate = true
        
        let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController")
        self.rootViewController = tabBarViewController
        
        if AppUtils.iphoneIsXModel() {
            self.constraintBadgeBottomSpace.constant = -40
        } else {
            self.constraintBadgeBottomSpace.constant = 0
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumBadge), name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePremiumBadge()
    }
    
    
    
    @objc func updatePremiumBadge() {
        self.imageViewPremiumBadge.isHidden = !(PremiumDataManager.manager.isPremiumUnlocked())
    }
}
