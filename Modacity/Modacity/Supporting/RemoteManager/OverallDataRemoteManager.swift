//
//  OverallDataRemoveManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 9/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class OverallDataRemoteManager {
    
    static let manager = OverallDataRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").observeSingleEvent(of: .value) { (snapshot) in
                if (!snapshot.exists()) {
                    self.startUpdatingOverallData()      // sync from local
                } else {
                    if let overallData = snapshot.value as? [String:Any] {
                        AppOveralDataManager.manager.forcelySetValues(totalPracticeSeconds: overallData["total_practice_seconds"] as? Int ?? 0,
                                                                      totalImprovements: overallData["total_improvements"] as? Int ?? 0,
                                                                      notPreventPhoneSleep: overallData["not_prevent_phone_sleep"] as? Bool ?? false,
                                                                      disableAutoPlayback: overallData["disable_auto_playback"] as? Bool ?? false,
                                                                      goAfterRating: overallData["go_after_rating"] as? Bool ?? false,
                                                                      streakFrom: overallData["streak_from"] as? String ?? Date().toString(format: "yyyy-MM-dd"),
                                                                      streakTo: overallData["streak_to"] as? String ?? Date().toString(format: "yyyy-MM-dd"),
                                                                      defaultDataShiped: overallData["default_data_ship"] as? Bool ?? false,
                                                                      firstPlaylistGenerated: overallData["first_playlist_generated"] as? Bool ?? false,
                                                                      timerPauseDuringNote: overallData["settings_timer_pause_during_note"] as? Bool ?? false,
                                                                      timerPauseDuringImprove: overallData["settings_timer_pause_during_improve"] as? Bool ?? false,
                                                                      practiceBreakTime: overallData["practice_break_time"] as? Int ?? 0)
                    }
                }
            }
        }
    }
    
    func shipDefaultData() {
        ModacityDebugger.debug("shipping default data")
        AppOveralDataManager.manager.setDefaultDataShiped(shiped: true)
        DefaultDataShipManager.manager.produceDefaultData()
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["default_data_ship": AppOveralDataManager.manager.defaultDataShiped()])
        }
        NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPlaylistLoadedFromServer))
        NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPlaylistUpdated))
        NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPracticeLoadedFromServer))
    }
    
    func startUpdatingOverallData() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["total_practice_seconds": AppOveralDataManager.manager.totalPracticeSeconds(),
                                                                           "total_improvements": AppOveralDataManager.manager.totalImprovements(),
                                                                           "not_prevent_phone_sleep": !AppOveralDataManager.manager.settingsPhoneSleepPrevent(),
                                                                           "disable_auto_playback": AppOveralDataManager.manager.settingsDisableAutoPlayback(),
                                                                           "go_after_rating": AppOveralDataManager.manager.settingsGotoNextItemAfterRating(),
                                                                           "streak_from": UserDefaults.standard.string(forKey: "streak_from") ?? Date().toString(format: "yyyy-MM-dd"),
                                                                           "streak_to": UserDefaults.standard.string(forKey: "streak_to") ?? Date().toString(format: "yyyy-MM-dd"),
                                                                           "default_data_shiped": AppOveralDataManager.manager.defaultDataShiped(),
                                                                           "first_playlist_generated": AppOveralDataManager.manager.firstPlaylistGenerated(),
                                                                           "settings_timer_pause_during_note": AppOveralDataManager.manager.settingsTimerPauseDuringNote(),
                                                                           "settings_timer_pause_during_improve": AppOveralDataManager.manager.settingsTimerPauseDuringImprove(),
                                                                           "practice_break_time": AppOveralDataManager.manager.practiceBreakTime()])
        }
    }

    func updateStreakValues(from: String, to: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["streak_from": from, "streak_to": to])
        }
    }
    
    func updateStreakValues(to: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["streak_to": to])
        }
    }
    
    func updateTotalPracticeSeconds(_ seconds: Int) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["total_practice_seconds": seconds])
        }
    }
    
    func updateTotalImprovements(_ improvements: Int) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["total_improvements": improvements])
        }
    }
    
    func updateFirstplaylistGenerated(_ generated: Bool) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["first_playlist_generated": generated])
        }
    }
    
    func updatePracticeBreakTime(_ time:Int) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues(["practice_break_time": time])
        }
    }
}
