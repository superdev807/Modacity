//
//  PremiumDataManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 26/7/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PremiumDataManager: NSObject {
    
    static let manager = PremiumDataManager()
    
    let refUser = Database.database().reference().child("users")
    var premiumObserver: DatabaseHandle?
    
    var listenerPaused = false
    
    func fetchPremiumUpgradeStatus() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.premiumObserver = self.refUser.child(userId).child("premium").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let data = snapshot.value as? [String:Any] {
                        if let premium = PremiumData(JSON: data) {
                            self.processPremium(premium)
                        }
                    }
                }
            }
        }
    }
    
    func processPremium(_ premium: PremiumData) {
        UserDefaults.standard.set(premium.toJSON(), forKey: "premium")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
        
        self.checkPremium()
    }
    
    func isPremiumUnlocked() -> Bool {
        //if (Bundle.main.appStoreReceiptURL?.path.contains("CoreSimulator"))
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            if ((appStoreReceiptURL.lastPathComponent == "sandboxReceipt") || (appStoreReceiptURL.path.contains("CoreSimulator"))) {
                return true
            }
        }
        
        if let data = UserDefaults.standard.object(forKey: "premium") as? [String:Any] {
            if let premium = PremiumData(JSON: data) {
                return premium.unlocked()
            }
        }
        return false
    }
    
    func checkPremium() {
        if let prem = UserDefaults.standard.object(forKey: "premium") as? [String:Any] {
            if let premium = PremiumData(JSON: prem) {
                if let key = premium.receiptData {
                    if let until = premium.validUntil {
                        if (until - (Date().timeIntervalSince1970)) < 10 * 3600 {
                            self.checkReceipt(key: key)
                        }
                    }
                }
            }
        }
    }
    
    func checkReceipt(key: String) {
        IAPHelper.helper.receiptValidation(receiptString: key) { (error, renewed, until) in
            if error == nil && renewed && until != nil {
                if let prem = UserDefaults.standard.object(forKey: "premium") as? [String:Any] {
                    if let premium = PremiumData(JSON: prem) {
                        if let oldUntil = premium.validUntil {
                            if until!.timeIntervalSince1970 > oldUntil + 100 {
                                ModacityDebugger.debug("Subscription UPDATED!!!")
                                self.registerSubscription(key: key, until: until!, completion: { (error) in
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func upgrade() {
        IAPHelper.helper.subscribe()
    }
    
    func registerSubscription(key: String, until: Date, checked: Bool = true, completion: @escaping (String?)->()) {
        let premium = PremiumData()
        premium.receiptData = key
        premium.validUntil = until.timeIntervalSince1970
        premium.appleReceiptChecked = checked
        UserDefaults.standard.set(premium.toJSON(), forKey: "premium")
        UserDefaults.standard.synchronize()
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("premium").updateChildValues(premium.toJSON()) { (error, _) in
                if let error = error {
                    completion(error.localizedDescription)
                } else {
                    NotificationCenter.default.post(name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
                    completion(nil)
                }
            }
        }
    }
    
    func processOffline() {
        if let observer = self.premiumObserver,
            let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("premium").removeObserver(withHandle: observer)
            self.premiumObserver = nil
            listenerPaused = true
        }
    }
    
    func processResumeOnline() {
        if listenerPaused {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.premiumObserver = self.refUser.child(userId).child("premium").observe(.value) { (snapshot) in
                    if snapshot.exists() {
                        if let data = snapshot.value as? [String:Any] {
                            if let premium = PremiumData(JSON: data) {
                                self.processPremium(premium)
                            }
                        }
                    }
                }
            }
            listenerPaused = false
        }
    }
    
    func signout() {
        UserDefaults.standard.removeObject(forKey: "premium")
        UserDefaults.standard.synchronize()
        if let observer = self.premiumObserver {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.refUser.child(userId).child("premium").removeObserver(withHandle: observer)
                self.premiumObserver = nil
                listenerPaused = false
            }
        }
    }
}
