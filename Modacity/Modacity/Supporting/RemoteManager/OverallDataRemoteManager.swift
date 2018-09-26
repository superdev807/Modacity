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
                        AppOveralDataManager.manager.forcelySetValues(totalImprovements: overallData["total_improvements"] as? Int ?? 0,
                                                                      notPreventPhoneSleep: overallData["not_prevent_phone_sleep"] as? Bool ?? false,
                                                                      disableAutoPlayback: overallData["disable_auto_playback"] as? Bool ?? false,
                                                                      goAfterRating: overallData["go_after_rating"] as? Bool ?? false,
                                                                      defaultDataShiped: overallData["default_data_ship"] as? Bool ?? false,
                                                                      firstPlaylistGenerated: overallData["first_playlist_generated"] as? Bool ?? false,
                                                                      timerPauseDuringNote: overallData["settings_timer_pause_during_note"] as? Bool ?? false,
                                                                      timerPauseDuringImprove: overallData["settings_timer_pause_during_improve"] as? Bool ?? false,
                                                                      practiceBreakTime: overallData["practice_break_time"] as? Int ?? 0,
                                                                      tuningStandard: overallData["tuning_standard"] as? Double ?? 440,
                                                                      firstPlaylistStored: overallData["first_playlist_stored"] as? Bool ?? false)
                        SyncStatusKeeper.keeper.statusOverallData = .succeeded
                    } else {
                        SyncStatusKeeper.keeper.statusOverallData = .failed
                    }
                }
                
                self.setOverallDataSynchronized()
                NotificationCenter.default.post(Notification(name: AppConfig.appNotificationOverallAppDataLoadedFromServer))
            }
        }
    }
    
    func overallDataSynchronized() -> Bool {
        return UserDefaults.standard.bool(forKey: "overall_data_synchronized")
    }
    
    func setOverallDataSynchronized() {
        UserDefaults.standard.set(true, forKey: "overall_data_synchronized")
        UserDefaults.standard.synchronize()
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
            self.refUser.child(userId).child("overall").updateChildValues(["total_improvements": AppOveralDataManager.manager.totalImprovements() ?? 0,
                                                                           "not_prevent_phone_sleep": !AppOveralDataManager.manager.settingsPhoneSleepPrevent(),
                                                                           "disable_auto_playback": AppOveralDataManager.manager.settingsDisableAutoPlayback(),
                                                                           "go_after_rating": AppOveralDataManager.manager.settingsGotoNextItemAfterRating(),
                                                                           "default_data_shiped": AppOveralDataManager.manager.defaultDataShiped(),
                                                                           "first_playlist_generated": AppOveralDataManager.manager.firstPlaylistGenerated(),
                                                                           "settings_timer_pause_during_note": AppOveralDataManager.manager.settingsTimerPauseDuringNote(),
                                                                           "settings_timer_pause_during_improve": AppOveralDataManager.manager.settingsTimerPauseDuringImprove(),
                                                                           "practice_break_time": AppOveralDataManager.manager.practiceBreakTime(),
                                                                           "tuning_standard": AppOveralDataManager.manager.tuningStandard(),
                                                                           "first_playlist_stored": AppOveralDataManager.manager.firstPlaylistStored()])
            SyncStatusKeeper.keeper.statusOverallData = .succeeded
        } else {
            SyncStatusKeeper.keeper.statusOverallData = .failed
        }
    }
    
    func postSettingsValueToServer(key: String, value: Any) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").updateChildValues([key:value])
        }
    }

    func updateStreakValues(from: String, to: String) {
        self.postSettingsValueToServer(key: "streak_from", value: from)
        self.postSettingsValueToServer(key: "streak_to", value: to)
    }

    func updateStreakValues(to: String) {
        self.postSettingsValueToServer(key: "streak_to", value: to)
    }

    func updateTotalPracticeSeconds(_ seconds: Int) {
        self.postSettingsValueToServer(key: "total_practice_seconds", value: seconds)
    }

    func updateTotalImprovements(_ improvements: Int) {
        self.postSettingsValueToServer(key: "total_improvements", value: improvements)
    }

    func updateFirstplaylistGenerated(_ generated: Bool) {
        self.postSettingsValueToServer(key: "first_playlist_generated", value: generated)
    }

    func updatePracticeBreakTime(_ time:Int) {
        self.postSettingsValueToServer(key: "practice_break_time", value: time)
    }

    func updateTuningStandard( _ value: Double) {
        self.postSettingsValueToServer(key: "tuning_standard", value: value)
    }
}
