//
//  LocalCacheManager.swift
//  Modacity
//
//  Created by BC Engineer on 25/9/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class LocalCacheManager {
    static let manager = LocalCacheManager()
    
    func profileName() -> String? {
        return UserDefaults.standard.string(forKey: "cache_profile_name")
    }
    
    func storeProfileNameToCache(name: String) {
        UserDefaults.standard.set(name, forKey: "cache_profile_name")
        UserDefaults.standard.synchronize()
    }
    
    func totalWorkingSeconds() -> Int? {
        if UserDefaults.standard.object(forKey: "cache_total_seconds") != nil {
            return UserDefaults.standard.integer(forKey: "cache_total_seconds")
        }
        return nil
    }
    
    func storeTotalWorkingSecondsToCache(seconds: Int) {
        UserDefaults.standard.set(seconds, forKey: "cache_total_seconds")
        UserDefaults.standard.synchronize()
    }
    
    func dayStreak() -> Int? {
        if UserDefaults.standard.object(forKey: "cache_day_streak") != nil {
            return UserDefaults.standard.integer(forKey: "cache_day_streak")
        }
        return nil
    }
    
    func storeDayStreaksToCache(days: Int) {
        UserDefaults.standard.set(days, forKey: "cache_day_streak")
        UserDefaults.standard.synchronize()
    }
}
