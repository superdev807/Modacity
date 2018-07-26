//
//  PremiumUpgradeRemoteManager.swift
//  Modacity
//
//  Created by BC Engineer on 25/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseDatabase



class PremiumUpgradeRemoteManager: NSObject {
    
    static let manager = PremiumUpgradeRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    var premiumObserver: DatabaseHandle?
    
    func fetchPremiumUpgradeStatus() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.premiumObserver = self.refUser.child(userId).child("premium").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let data = snapshot.value as? [String:Any] {
                        if let premium = PremiumUpgradeData(JSON: data) {
                            self.processPremium(premium)
                        }
                    }
                }
            }
        }
    }
    
    func startFreeTrial(completion: @escaping (String?)->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            let now = Date()
            let validUntil = now.advanced(years: 0, months: 0, weeks: 0, days: AppConfig.appFreeTrialDays, hours: 0, minutes: 0, seconds: 0)
            let value = ["trial_started": now.timeIntervalSince1970, "valid_until":validUntil.timeIntervalSince1970]
            self.refUser.child(userId).child("premium").updateChildValues(value) { (error, _) in
                if let error = error {
                    completion(error.localizedDescription)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func processPremium(_ premium: PremiumUpgradeData) {
        UserDefaults.standard.set(premium.toJSON(), forKey: "premium_data")
        UserDefaults.standard.synchronize()
        
//        IAPHelper.helper.loadReceiptData()
        NotificationCenter.default.post(name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
    }
    
    func signout() {
        if let observer = self.premiumObserver {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.refUser.child(userId).child(userId).removeObserver(withHandle: observer)
            }
        }
    }

}
