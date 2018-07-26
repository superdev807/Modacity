//
//  PremiumUtils.swift
//  Modacity
//
//  Created by BC Engineer on 25/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PremiumData: Mappable {
    
    var validUntil: TimeInterval?
    var receiptData: String?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        validUntil        <- map["until"]
        receiptData      <- map["key"]
    }
    
    func unlocked() -> Bool {
        if let validUntil = validUntil {
            let now = Date()
            if now.timeIntervalSince1970 < validUntil {
                return true
            }
        }
        return false
    }
}

enum PremiumUpgradeStatus: String {
    case none = "Free"
    case trial = "Free Trial"
    case trial_expired = "Trial Expired"
    case upgraded = "Premium"
    case need_upgrade = "Premium Expired"
}

class PremiumUpgradeData: Mappable {
    
    var trialStarted: TimeInterval?
    var lastSubscribed: TimeInterval?
    var validUntil: TimeInterval?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        trialStarted        <- map["trial_started"]
        lastSubscribed      <- map["last_subscribed"]
        validUntil          <- map["valid_until"]
    }
    
    func status() -> PremiumUpgradeStatus {
        let now = Date()
        if let validUntil = validUntil {
            if now.timeIntervalSince1970 < validUntil {
                if let _ = lastSubscribed {
                    return .upgraded
                } else {
                    return .trial
                }
            } else {
                if let _ = lastSubscribed {
                    return .need_upgrade
                } else {
                    return .trial_expired
                }
            }
        }
        
        return .none
    }
    
    func unlocked() -> Bool {
        let status = self.status()
        switch status {
        case .none:
            return false
        case .trial:
            return true
        case .trial_expired:
            return false
        case .upgraded:
            return true
        case .need_upgrade:
            return false
        }
    }
    
    func freeTrialStatus() -> String {
        let now = Date()
        if let trialStarted = trialStarted {
            if now.timeIntervalSince1970 > trialStarted {
                if now.timeIntervalSince1970 < trialStarted + TimeInterval(AppConfig.appFreeTrialDays * 24 * 3600) {
                    let diffInSec = trialStarted + TimeInterval(AppConfig.appFreeTrialDays * 24 * 3600) - now.timeIntervalSince1970
                    if diffInSec < 60 {
                        return "Your free trial ends soon!"
                    } else if diffInSec < 3600 {
                        return "Your free trial ends in an hour!"
                    } else if diffInSec < 24 * 3600 {
                        return "Your free trial ends in one day!"
                    } else {
                        return "Your free trial remains \(Int(diffInSec / 24 / 3600)) days."
                    }
                    
                } else {
                    return "Your free trial expired!"
                }
            }
        }
        
        return ""
    }
}

class PremiumUtils: NSObject {

}
