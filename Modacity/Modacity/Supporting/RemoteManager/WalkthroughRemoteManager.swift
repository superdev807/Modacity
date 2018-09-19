//
//  OverallDataRemoveManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 9/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WalkthroughRemoteManager {
    
    static let manager = WalkthroughRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").child("walkthroughs").observeSingleEvent(of: .value) { (snapshot) in
                if (!snapshot.exists()) {
                    self.startUpdatingWalkthroughData()      // sync from local
                } else {
                    if let overallData = snapshot.value as? [String:Any] {
//                        AppOveralDataManager.manager.forcelySetValues(totalPracticeSeconds: overallData["total_practice_seconds"] as? Int ?? 0,
//                                                                      totalImprovements: overallData["total_improvements"] as? Int ?? 0,
//                                                                      notPreventPhoneSleep: overallData["not_prevent_phone_sleep"] as? Bool ?? false,
//                                                                      disableAutoPlayback: overallData["disable_auto_playback"] as? Bool ?? false,
//                                                                      goAfterRating: overallData["go_after_rating"] as? Bool ?? false,
//                                                                      streakFrom: overallData["streak_from"] as? String ?? Date().toString(format: "yyyy-MM-ddHH:mm:ssZ"),
//                                                                      streakTo: overallData["streak_to"] as? String ?? Date().toString(format: "yyyy-MM-ddHH:mm:ssZ"),
//                                                                      defaultDataShiped: overallData["default_data_ship"] as? Bool ?? false,
//                                                                      firstPlaylistGenerated: overallData["first_playlist_generated"] as? Bool ?? false,
//                                                                      timerPauseDuringNote: overallData["settings_timer_pause_during_note"] as? Bool ?? false,
//                                                                      timerPauseDuringImprove: overallData["settings_timer_pause_during_improve"] as? Bool ?? false,
//                                                                      practiceBreakTime: overallData["practice_break_time"] as? Int ?? 0,
//                                                                      tuningStandard: overallData["tuning_standard"] as? Double ?? 440,
//                                                                      firstPlaylistStored: overallData["first_playlist_stored"] as? Bool ?? false)
//                        SyncStatusKeeper.keeper.statusOverallData = .succeeded
                    } else {
                        SyncStatusKeeper.keeper.statusOverallData = .failed
                    }
                }
            }
        }
    }
    
    func startUpdatingWalkthroughData() {
        if let userId = MyProfileLocalManager.manager.userId() {
//            self.refUser.child(userId).child("overall").updateChildValues(["total_practice_seconds": AppOveralDataManager.manager.totalPracticeSeconds(),
//                                                                           "total_improvements": AppOveralDataManager.manager.totalImprovements(),
//                                                                           "not_prevent_phone_sleep": !AppOveralDataManager.manager.settingsPhoneSleepPrevent(),
//                                                                           "disable_auto_playback": AppOveralDataManager.manager.settingsDisableAutoPlayback(),
//                                                                           "go_after_rating": AppOveralDataManager.manager.settingsGotoNextItemAfterRating(),
//                                                                           "streak_from": UserDefaults.standard.string(forKey: "streak_from") ?? Date().toString(format: "yyyy-MM-ddHH:mm:ssZ"),
//                                                                           "streak_to": UserDefaults.standard.string(forKey: "streak_to") ?? Date().toString(format: "yyyy-MM-ddHH:mm:ssZ"),
//                                                                           "default_data_shiped": AppOveralDataManager.manager.defaultDataShiped(),
//                                                                           "first_playlist_generated": AppOveralDataManager.manager.firstPlaylistGenerated(),
//                                                                           "settings_timer_pause_during_note": AppOveralDataManager.manager.settingsTimerPauseDuringNote(),
//                                                                           "settings_timer_pause_during_improve": AppOveralDataManager.manager.settingsTimerPauseDuringImprove(),
//                                                                           "practice_break_time": AppOveralDataManager.manager.practiceBreakTime(),
//                                                                           "tuning_standard": AppOveralDataManager.manager.tuningStandard(),
//                                                                           "first_playlist_stored": AppOveralDataManager.manager.firstPlaylistStored()])
            SyncStatusKeeper.keeper.statusOverallData = .succeeded
        } else {
            SyncStatusKeeper.keeper.statusOverallData = .failed
        }
    }
}
