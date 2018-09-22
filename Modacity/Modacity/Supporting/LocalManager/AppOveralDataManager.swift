//
//  AppDataLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Intercom

class AppOveralDataManager {
    static let manager = AppOveralDataManager()
    
    
    func beenTutorialRead() -> Bool {
        return UserDefaults.standard.bool(forKey: "tutorial_read")
    }
    
    func didReadTutorial() {
        UserDefaults.standard.set(true, forKey: "tutorial_read")
        UserDefaults.standard.synchronize()
    }
    
//    func calculateDaysStreakBasedOnPracticeItems() -> Int {
//        var data = [String:[PlaylistDaily]]()
//        data = PlaylistDailyLocalManager.manager.overallPracticeData()
//
//        var practicedData = [String:Bool]()
//
//        for date in data.keys {
//            practicedData[date] = true
//        }
//
//        var dateString = Date().ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
//        var streakDays = 1
//        while practicedData[dateString] != nil  && practicedData[dateString]! == true {
//            streakDays = streakDays + 1
//            dateString = dateString.date(format: "yy-MM-dd")!.ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
//        }
//
//        return streakDays
//    }
    
    func calculateStreakDays() -> Int {
        if let streakFrom = UserDefaults.standard.string(forKey: "streak_from") {
            if let streakTo = UserDefaults.standard.string(forKey: "streak_to") {
                let from = (streakFrom.count == 10) ? (streakFrom.date(format: "yyyy-MM-dd") ?? Date()) : (streakFrom.date(format: "yyyy-MM-ddHH:mm:ssZ") ?? Date())
                let to = (streakTo.count == 10) ? (streakTo.date(format: "yyyy-MM-dd") ?? Date()) : (streakTo.date(format: "yyyy-MM-ddHH:mm:ssZ") ?? Date())
                return from.differenceInDays(with: to)
            }
        }
        return 1
    }
    
    func saveStreak() {
        let streakFrom = UserDefaults.standard.string(forKey: "streak_from")
        let streakTo = UserDefaults.standard.string(forKey: "streak_to")
        let today = Date().toString(format: "yyyy-MM-dd")
        let todayFullFormat = Date().toString(format: "yyyy-MM-ddHH:mm:ssZ")
        
        if let _ = streakFrom {
            if let to = streakTo {
                if to.count == 10 {
                    if to != today {
                        let toDate = to.date(format: "yyyy-MM-dd") ?? Date()
                        
                        if Date().differenceInDays(with: toDate) > 2 {
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_from")
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_to")
                            UserDefaults.standard.synchronize()
                            ModacityDebugger.debug("Update streak values from, to both!")
                            OverallDataRemoteManager.manager.updateStreakValues(from: todayFullFormat, to: todayFullFormat)
                        } else {
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_to")
                            UserDefaults.standard.synchronize()
                            OverallDataRemoteManager.manager.updateStreakValues(to: todayFullFormat)
                        }
                    }
                } else {
                    if to != todayFullFormat {
                        let toDate = to.date(format: "yyyy-MM-ddHH:mm:ssZ") ?? Date()
                        
                        if Date().differenceInDays(with: toDate) > 2 {
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_from")
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_to")
                            UserDefaults.standard.synchronize()
                            ModacityDebugger.debug("Update streak values from, to both!")
                            OverallDataRemoteManager.manager.updateStreakValues(from: todayFullFormat, to: todayFullFormat)
                        } else {
                            UserDefaults.standard.set(todayFullFormat, forKey: "streak_to")
                            UserDefaults.standard.synchronize()
                            OverallDataRemoteManager.manager.updateStreakValues(to: todayFullFormat)
                        }
                    }
                }
            }
        } else {
            UserDefaults.standard.set(todayFullFormat, forKey: "streak_from")
            UserDefaults.standard.set(todayFullFormat, forKey: "streak_to")
            UserDefaults.standard.synchronize()
            OverallDataRemoteManager.manager.updateStreakValues(from: todayFullFormat, to: todayFullFormat)
        }
        
    }
    
    func signout() {
        self.removeValues()
        PracticeItemLocalManager.manager.signout()
        RecordingsLocalManager.manager.signout()
        PlaylistLocalManager.manager.signout()
        PracticingDailyLocalManager.manager.signout()
        PlaylistDailyLocalManager.manager.signout()
        PremiumDataManager.manager.signout()
        
        WalkthroughRemoteManager.manager.synchronized = false
        
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        MyProfileRemoteManager.manager.signout()
        MyProfileLocalManager.manager.signout()
        Authorizer.authorizer.signout()
        Intercom.logout()
    }
    
    func removeValues() {

        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
            if key != "tutorial_read" {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "total_practice_seconds")
        UserDefaults.standard.removeObject(forKey: "total_improvements")
        UserDefaults.standard.removeObject(forKey: "not_prevent_phone_sleep")
        UserDefaults.standard.removeObject(forKey: "disable_auto_playback")
        UserDefaults.standard.removeObject(forKey: "streak_from")
        UserDefaults.standard.removeObject(forKey: "streak_to")
        UserDefaults.standard.removeObject(forKey: "default_data_shiped")
        UserDefaults.standard.removeObject(forKey: "first_playlist_generated")
        UserDefaults.standard.removeObject(forKey: "settings_timer_pause_during_note")
        UserDefaults.standard.removeObject(forKey: "settings_timer_pause_during_improve")
        UserDefaults.standard.removeObject(forKey: "practice_break_time")
        UserDefaults.standard.removeObject(forKey: "go_after_rating")
        
        UserDefaults.standard.synchronize()
    }
    
    func forcelySetValues(totalPracticeSeconds: Int,
                          totalImprovements: Int,
                          notPreventPhoneSleep: Bool,
                          disableAutoPlayback: Bool,
                          goAfterRating: Bool,
                          streakFrom: String,
                          streakTo: String,
                          defaultDataShiped: Bool,
                          firstPlaylistGenerated: Bool,
                          timerPauseDuringNote: Bool,
                          timerPauseDuringImprove: Bool,
                          practiceBreakTime: Int,
                          tuningStandard: Double,
                          firstPlaylistStored: Bool) {
        
        UserDefaults.standard.set(totalPracticeSeconds, forKey: "total_practice_seconds")
        UserDefaults.standard.set(totalImprovements, forKey: "total_improvements")
        UserDefaults.standard.set(notPreventPhoneSleep, forKey: "not_prevent_phone_sleep")
        UserDefaults.standard.set(disableAutoPlayback, forKey: "disable_auto_playback")
        UserDefaults.standard.set(goAfterRating, forKey: "go_after_rating")
        UserDefaults.standard.set(streakFrom, forKey: "streak_from")
        UserDefaults.standard.set(streakTo, forKey: "streak_to")
        UserDefaults.standard.set(defaultDataShiped, forKey: "default_data_shiped")
        UserDefaults.standard.set(firstPlaylistGenerated, forKey: "first_playlist_generated")
        UserDefaults.standard.set(timerPauseDuringNote, forKey: "settings_timer_pause_during_note")
        UserDefaults.standard.set(timerPauseDuringImprove, forKey: "settings_timer_pause_during_improve")
        UserDefaults.standard.set(practiceBreakTime, forKey: "practice_break_time")
        UserDefaults.standard.set(tuningStandard, forKey: "tuning_standard")
        UserDefaults.standard.set(firstPlaylistStored, forKey: "first_playlist_stored")
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
        OverallDataRemoteManager.manager.postSettingsValueToServer(key: "not_prevent_phone_sleep", value: !settingsPhoneSleepPrevent())
    }
    
    func settingsDisableAutoPlayback() -> Bool {
        return UserDefaults.standard.bool(forKey: "disable_auto_playback")
    }
    
    func changeDisableAutoPlayback() {
        UserDefaults.standard.set(!settingsDisableAutoPlayback(), forKey: "disable_auto_playback")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.postSettingsValueToServer(key: "disable_auto_playback", value: settingsDisableAutoPlayback())
    }
    
    func settingsGotoNextItemAfterRating() -> Bool {
        return !(UserDefaults.standard.bool(forKey: "go_after_rating"))
    }
    
    func changeGotoNextItemAfterRating() {
        UserDefaults.standard.set(settingsGotoNextItemAfterRating(), forKey: "go_after_rating")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.postSettingsValueToServer(key: "go_after_rating", value: !settingsGotoNextItemAfterRating())
    }
    
    func settingsTimerPauseDuringNote() -> Bool {
        return UserDefaults.standard.bool(forKey: "settings_timer_pause_during_note")
    }
    
    func changeSettingsTimerPauseDuringNote() {
        UserDefaults.standard.set(!settingsTimerPauseDuringNote(), forKey: "settings_timer_pause_during_note")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.postSettingsValueToServer(key: "settings_timer_pause_during_note", value: settingsTimerPauseDuringNote())
    }
    
    func settingsTimerPauseDuringImprove() -> Bool {
        return UserDefaults.standard.bool(forKey: "settings_timer_pause_during_improve")
    }
    
    func changeSettingsTimerPauseDuringImprove() {
        UserDefaults.standard.set(!settingsTimerPauseDuringImprove(), forKey: "settings_timer_pause_during_improve")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.postSettingsValueToServer(key: "settings_timer_pause_during_improve", value: settingsTimerPauseDuringImprove())
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
    
    // Walk through settings
    
    func walkThroughFlagChecking(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func walkthroughSetFlag(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global().async {
            WalkthroughRemoteManager.manager.updateWalkThroughValue(forLocalKey: key, value: value)
        }
    }
    
    func defaultDataShiped() -> Bool {
        return UserDefaults.standard.bool(forKey: "default_data_shiped")
    }
    
    func setDefaultDataShiped(shiped: Bool) {
        UserDefaults.standard.set(shiped, forKey: "default_data_shiped")
        UserDefaults.standard.synchronize()
    }
    
    func firstPlaylistStored() -> Bool {
        return UserDefaults.standard.bool(forKey: "first_playlist_stored")
    }
    
    func storeFirstPlaylist() {
        UserDefaults.standard.set(true, forKey: "first_playlist_stored")
        UserDefaults.standard.synchronize()
    }
    
    func firstPlaylistGenerated() -> Bool {
        return UserDefaults.standard.bool(forKey: "first_playlist_generated")
    }
    
    func generatedFirstPlaylist() {
        UserDefaults.standard.set(true, forKey: "first_playlist_generated")
        UserDefaults.standard.synchronize()
        
        OverallDataRemoteManager.manager.updateFirstplaylistGenerated(true)
    }
    
    func storePracticeBreakTime(_ minutes:Int) {
        UserDefaults.standard.set(minutes, forKey: "practice_break_time")
        UserDefaults.standard.synchronize()
        
        OverallDataRemoteManager.manager.updatePracticeBreakTime(minutes)
    }
    
    func practiceBreakTime() -> Int {
        if PremiumDataManager.manager.isPremiumUnlocked() {
            return UserDefaults.standard.integer(forKey: "practice_break_time")
        } else {
            return 0
        }
    }
    
    func saveSortKey(_ sortKey: SortKeyOption) {
        UserDefaults.standard.set(sortKey.rawValue, forKey: "sort_key")
        UserDefaults.standard.synchronize()
    }
    
    func sortKey() -> SortKeyOption {
        if let sortKey = UserDefaults.standard.string(forKey: "sort_key") {
            return SortKeyOption(rawValue: sortKey) ?? .name
        } else {
            return .name
        }
    }
    
    func saveSortOption(_ sortOption: SortOption) {
        UserDefaults.standard.set(sortOption.rawValue, forKey: "sort_option")
        UserDefaults.standard.synchronize()
    }
    
    func sortOption() -> SortOption {
        if let sortKey = UserDefaults.standard.string(forKey: "sort_option") {
            return SortOption(rawValue: sortKey) ?? .ascending
        } else {
            return .ascending
        }
    }
    
    func saveTuningStandard(_ value:Double) {
        print("Saving tuning standard \(value)")
        UserDefaults.standard.set(value, forKey: "tuning_standard")
        UserDefaults.standard.synchronize()
        OverallDataRemoteManager.manager.updateTuningStandard(value)
        MetrodroneParameters.instance.setTuningStandardA(Float(AppOveralDataManager.manager.tuningStandard()))
    }
    
    func tuningStandard() -> Double {
        if let _ = UserDefaults.standard.object(forKey: "tuning_standard") {
            let standard = UserDefaults.standard.double(forKey: "tuning_standard") 
            print("Retrieved tuning standard \(standard)")
            return standard
        } else {
            return 440.0
        }
    }
}
