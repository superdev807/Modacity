//
//  WalkthroughRemoveManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 9/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WalkthroughRemoteManager {
    
    static let manager = WalkthroughRemoteManager()
    
    let keysDictLocalToServer = ["walkthrough_first_page": "fp",
                                "walkthrough_second_page": "sp",
                                "walkthrough_practice_page": "pp",
                                "walkthrough_practice_timer_up": "ptu",
                                "walkthrough_practice_rate_page": "prp",
                                "walkthrough_first_playlist":"fpl",
                                "walkthrough_playlist_naming":"pn",
                                "walkthrough_playlist_finish":"pf",
                                "walkthrough_practice_item_selection_finish":"pisf",
                                "walkthrough_improvement": "im"]
    
    let keysDictServerToLocal = ["fp":"walkthrough_first_page",
                                 "sp":"walkthrough_second_page",
                                 "pp":"walkthrough_practice_page",
                                 "ptu":"walkthrough_practice_timer_up",
                                 "prp":"walkthrough_practice_rate_page",
                                 "fpl":"walkthrough_first_playlist",
                                 "pn":"walkthrough_playlist_naming",
                                 "pf":"walkthrough_playlist_finish",
                                 "pisf":"walkthrough_practice_item_selection_finish",
                                 "im": "walkthrough_improvement"]
    
    let refUser = Database.database().reference().child("users")
    
    var synchronized = false
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("overall").child("walkthroughs").observeSingleEvent(of: .value) { (snapshot) in
                if (!snapshot.exists()) {
                    self.synchronized = true
                    NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationWalkthroughSynchronized))
                    self.startUpdatingWalkthroughData()      // sync from local
                } else {
                    if let overallData = snapshot.value as? [String:Any] {
                        for key in overallData.keys {
                            AppOveralDataManager.manager.walkthroughSetFlag(key: self.keysDictServerToLocal[key] ?? "walkthrough__", value: overallData[key] as? Bool ?? false)
                        }
                    } else {
                        SyncStatusKeeper.keeper.statusOverallData = .failed
                    }
                    self.synchronized = true
                    NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationWalkthroughSynchronized))
                }
            }
        }
    }
    
    func startUpdatingWalkthroughData() {
        if let userId = MyProfileLocalManager.manager.userId() {
            var values = [String:Bool]()
            for key in self.keysDictLocalToServer.keys {
                values[keysDictLocalToServer[key]!] = AppOveralDataManager.manager.walkThroughFlagChecking(key: key)
            }
            self.refUser.child(userId).child("overall").child("walkthroughs").updateChildValues(values)
            SyncStatusKeeper.keeper.statusOverallData = .succeeded
        } else {
            SyncStatusKeeper.keeper.statusOverallData = .failed
        }
    }
    
    func updateWalkThroughValue(forLocalKey localKey:String, value: Bool) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if let serverKey = self.keysDictLocalToServer[localKey] {
                self.refUser.child(userId).child("overall").child("walkthroughs").updateChildValues([serverKey: value])
            }
        }
    }
}
