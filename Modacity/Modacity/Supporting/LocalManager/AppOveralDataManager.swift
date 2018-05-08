//
//  AppDataLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class AppOveralDataManager {
    static let manager = AppOveralDataManager()
    
    func beenTutorialRead() -> Bool {
        return UserDefaults.standard.bool(forKey: "tutorial_read")
    }
    
    func didReadTutorial() {
        UserDefaults.standard.set(true, forKey: "tutorial_read")
        UserDefaults.standard.synchronize()
    }
    
    func calculateStreakDays() -> Int {
        if let streakFrom = UserDefaults.standard.string(forKey: "streak_from") {
            if let streakTo = UserDefaults.standard.string(forKey: "streak_to") {
                let from = streakFrom.date(format: "yyyy-MM-dd") ?? Date()
                let to = streakTo.date(format: "yyyy-MM-dd") ?? Date()
                return Int((to.timeIntervalSince1970 - from.timeIntervalSince1970) / 24 / 3600) + 1
            }
        }
        return 1
    }
    
    func saveStreak() {
        let streakFrom = UserDefaults.standard.string(forKey: "streak_from")
        let streakTo = UserDefaults.standard.string(forKey: "streak_to")
        let today = Date().toString(format: "yyyy-MM-dd")
        
        if let _ = streakFrom {
            if let to = streakTo {
                if to != today {
                    let toDate = to.date(format: "yyyy-MM-dd") ?? Date()
                    let todayDate = today.date(format: "yyyy-MM-dd") ?? Date()
                    if todayDate.timeIntervalSince1970 - toDate.timeIntervalSince1970 > 24 * 3600 {
                        UserDefaults.standard.set(today, forKey: "streak_from")
                        UserDefaults.standard.set(today, forKey: "streak_to")
                        UserDefaults.standard.synchronize()
                        OverallDataRemoteManager.manager.updateStreakValues(from: today, to: today)
                    } else {
                        UserDefaults.standard.set(today, forKey: "streak_to")
                        UserDefaults.standard.synchronize()
                        OverallDataRemoteManager.manager.updateStreakValues(to: today)
                    }
                }
            }
        } else {
            UserDefaults.standard.set(today, forKey: "streak_from")
            UserDefaults.standard.set(today, forKey: "streak_to")
            UserDefaults.standard.synchronize()
            OverallDataRemoteManager.manager.updateStreakValues(from: today, to: today)
        }
        
    }
    
    func signout() {
        
        self.removeValues()
        PracticeItemLocalManager.manager.signout()
        RecordingsLocalManager.manager.signout()
        PlaylistLocalManager.manager.signout()
        
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        MyProfileRemoteManager.manager.signout()
        MyProfileLocalManager.manager.signout()
        Authorizer.authorizer.signout()
    }
    
    func removeValues() {
        UserDefaults.standard.removeObject(forKey: "total_practice_seconds")
        UserDefaults.standard.removeObject(forKey: "total_improvements")
        UserDefaults.standard.removeObject(forKey: "not_prevent_phone_sleep")
        UserDefaults.standard.removeObject(forKey: "disable_auto_playback")
        UserDefaults.standard.removeObject(forKey: "streak_from")
        UserDefaults.standard.removeObject(forKey: "streak_to")
        UserDefaults.standard.synchronize()
    }
    
    func forcelySetValues(totalPracticeSeconds: Int, totalImprovements: Int, notPreventPhoneSleep: Bool, disableAutoPlayback: Bool, streakFrom: String, streakTo: String) {
        UserDefaults.standard.set(totalPracticeSeconds, forKey: "total_practice_seconds")
        UserDefaults.standard.set(totalImprovements, forKey: "total_improvements")
        UserDefaults.standard.set(notPreventPhoneSleep, forKey: "not_prevent_phone_sleep")
        UserDefaults.standard.set(disableAutoPlayback, forKey: "disable_auto_playback")
        UserDefaults.standard.set(streakFrom, forKey: "streak_from")
        UserDefaults.standard.set(streakTo, forKey: "streak_to")
        UserDefaults.standard.synchronize()
    }
    
    func totalPracticeSeconds() -> Int {
        return UserDefaults.standard.integer(forKey: "total_practice_seconds")
    }
    
    func addPracticeTime(inSec seconds:Int) {
        var secondsSofar = self.totalPracticeSeconds()
        secondsSofar = secondsSofar + seconds
        UserDefaults.standard.set(secondsSofar, forKey: "total_practice_seconds")
        UserDefaults.standard.synchronize()
        
        OverallDataRemoteManager.manager.updateTotalPracticeSeconds(secondsSofar)
    }
    
    func totalImprovements() -> Int {
        return UserDefaults.standard.integer(forKey: "total_improvements")
    }
    
    func addImprovementsCount() {
        let improvements = self.totalImprovements()
        UserDefaults.standard.set(improvements + 1, forKey: "total_improvements")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.updateTotalImprovements(improvements + 1)
    }
    
    func settingsPhoneSleepPrevent() -> Bool {
        return !UserDefaults.standard.bool(forKey: "not_prevent_phone_sleep")
    }
    
    func changePhoneSleepPrevent() {
        UserDefaults.standard.set(settingsPhoneSleepPrevent(), forKey: "not_prevent_phone_sleep")
        UserDefaults.standard.synchronize()
    }
    
    func settingsDisableAutoPlayback() -> Bool {
        return UserDefaults.standard.bool(forKey: "disable_auto_playback")
    }
    
    func changeDisableAutoPlayback() {
        UserDefaults.standard.set(!settingsDisableAutoPlayback(), forKey: "disable_auto_playback")
        UserDefaults.standard.synchronize()
    }
    
    func fileNameAutoIncrementedNumber() -> Int {
        let key = "\(Date().toString(format: "yyyyMMdd"))-autoincrement"
        if UserDefaults.standard.object(forKey: key) == nil {
            return 1
        } else {
            return UserDefaults.standard.integer(forKey: key)
        }
    }
    
    func increaseAutoIncrementedNumber() {
        let key = "\(Date().toString(format: "yyyyMMdd"))-autoincrement"
        let value = self.fileNameAutoIncrementedNumber()
        UserDefaults.standard.set(value + 1, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
