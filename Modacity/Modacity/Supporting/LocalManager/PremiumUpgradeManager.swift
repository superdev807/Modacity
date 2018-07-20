//
//  PremiumUpgradeManager.swift
//  Modacity
//
//  Created by BC Engineer on 20/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PremiumUpgradeManager: NSObject {
    
    static let manager = PremiumUpgradeManager()
    
    func startFreeTrial() {
        UserDefaults.standard.set(true, forKey: "premium_unlocked")
        UserDefaults.standard.synchronize()
    }
    
    func isPremiumUnlocked() -> Bool {
        return UserDefaults.standard.bool(forKey: "premium_unlocked")
    }
    
    func cancelUpgrade() {
        UserDefaults.standard.set(false, forKey: "premium_unlocked")
        UserDefaults.standard.synchronize()
    }
}
