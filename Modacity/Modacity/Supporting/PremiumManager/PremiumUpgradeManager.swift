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
    
    func startFreeTrial(completion: @escaping (String?)->()) {
        PremiumUpgradeRemoteManager.manager.startFreeTrial(completion: completion)
    }
    
    func accountType() -> PremiumUpgradeStatus {
        if let data = UserDefaults.standard.object(forKey: "premium_data") as? [String:Any] {
            if let premium = PremiumUpgradeData(JSON: data) {
                return premium.status()
            }
        }
        return .none
    }
    
    func isPremiumUnlocked() -> Bool {
        if let data = UserDefaults.standard.object(forKey: "premium_data") as? [String:Any] {
            if let premium = PremiumUpgradeData(JSON: data) {
                return premium.unlocked()
            }
        }
        return false
    }
    
    func premiumData() -> PremiumUpgradeData? {
        if let data = UserDefaults.standard.object(forKey: "premium_data") as? [String:Any] {
            if let premium = PremiumUpgradeData(JSON: data) {
                return premium
            }
        }
        return nil
    }
    
    func cancelUpgrade() {
        
    }
    
    func signout() {
        UserDefaults.standard.removeObject(forKey: "premium_data")
        UserDefaults.standard.synchronize()
        
        PremiumUpgradeRemoteManager.manager.signout()
    }
}
