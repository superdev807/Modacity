//
//  DailyPracticingRemoteManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 19/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DailyPracticingRemoteManager: NSObject {
    
    static let manager = DailyPracticingRemoteManager()
    let refUser = Database.database().reference().child("users")
    
    func createPracticing(_ data: PracticeDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if data.practiceItemId != nil && data.practiceItemId != "" {
                self.refUser.child(userId).child("practice_data").child(data.practiceItemId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
            }
        }
    }
    
    func deletePracticing(_ data: PracticeDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if data.practiceItemId != nil && data.practiceItemId != "" {
                self.refUser.child(userId).child("practice_data").child(data.practiceItemId).child(data.entryDateString).child(data.entryId).removeValue()
            }
        }
    }
    
    func updatePracticing(_ data: PracticeDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if data.practiceItemId != nil && data.practiceItemId != "" {
                self.refUser.child(userId).child("practice_data").child(data.practiceItemId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
            }
        }
    }
    
    func createPlaylistPracticing(_ data: PlaylistDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if data.playlistId != nil && data.playlistId != "" {
                self.refUser.child(userId).child("playlist_data").child(data.playlistId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
            }
        }
    }
    
    func practicingDataFetched() -> Bool {
        return UserDefaults.standard.bool(forKey: "fetched_practicing") && UserDefaults.standard.bool(forKey: "fetched_practicing_playlist")
            && UserDefaults.standard.object(forKey: "total_practice_data") != nil && UserDefaults.standard.object(forKey: "total_playlist_practice_data") != nil
    }
    
    func setPracticingDataLoaded() {
        UserDefaults.standard.set(true, forKey: "fetched_practicing")
        UserDefaults.standard.synchronize()
    }
    
    func setPlaylistPracticingDataLoaded() {
        UserDefaults.standard.set(true, forKey: "fetched_practicing_playlist")
        UserDefaults.standard.synchronize()
    }
    
    func syncPlaylistPracticingData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlist_data").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    if snapshot.exists() {
                        if let data = snapshot.value as? [String:Any] {
                            PlaylistDailyLocalManager.manager.cleanData()
                            PlaylistDailyLocalManager.manager.storeTotalData(data)
                        }
                    }
                    
                    completion()
                }
            }
        }
    }
    
    func syncPracticeData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    if snapshot.exists() {
                        if let data = snapshot.value as? [String:Any] {
                            PracticingDailyLocalManager.manager.cleanData()
                            PracticingDailyLocalManager.manager.storeTotalData(data)
                        }
                    }
                    completion()
                }
            }
        }
    }
    
    func erasePlaylistPraciticingData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlist_data").removeValue { (_, _) in
                completion()
            }
        }
        PlaylistDailyLocalManager.manager.cleanData()
    }
    
    func fetchPlaylistPracticingDataFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            var started = Date().timeIntervalSince1970
            self.refUser.child(userId).child("playlist_data").keepSynced(true)
            self.refUser.child(userId).child("playlist_data").observeSingleEvent(of: .value) { (snapshot) in
                ModacityDebugger.debug("Firebase playlist data loading time = \(Date().timeIntervalSince1970 - started)s")
                DispatchQueue.global(qos: .background).async {
                    started = Date().timeIntervalSince1970
                    if snapshot.exists() {
                        if let data = snapshot.value as? [String:Any] {
                            PlaylistDailyLocalManager.manager.cleanData()
                            PlaylistDailyLocalManager.manager.storeTotalData(data)
                        }
                    }
                    
                    ModacityDebugger.debug("Firebase playlist data local storing time = \(Date().timeIntervalSince1970 - started)s")
                    self.setPlaylistPracticingDataLoaded()
                    NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPracticeDataFetched))
                }
            }
        }
    }
    
    func erasePracticingData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").removeValue { (_, _) in
                completion()
            }
        }
        PracticingDailyLocalManager.manager.cleanData()
    }
    
    func entryContained(_ entries:[PracticeDaily], _ data: PracticeDaily) -> PracticeDaily? {
        for entry in entries {
            if entry.startedTime == data.startedTime {
                return entry
            }
        }
        
        return nil
    }
    
    func fetchPracticingDataFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            var started = Date().timeIntervalSince1970
            self.refUser.child(userId).child("practice_data").keepSynced(true)
            self.refUser.child(userId).child("practice_data").observeSingleEvent(of: .value) { (snapshot) in
                ModacityDebugger.debug("Firebase practice data loading time = \(Date().timeIntervalSince1970 - started)s")
                started = Date().timeIntervalSince1970
                DispatchQueue.global(qos: .background).async {
                    if snapshot.exists() {
                        if let data = snapshot.value as? [String:Any] {
                            
//                            print("PRE CALCULATION TOTAL TIME - \(totalPracticeTimeInSecond)")
                            
                            PracticingDailyLocalManager.manager.cleanData()
                            PracticingDailyLocalManager.manager.storeTotalData(data)
                        }
                    }
                    ModacityDebugger.debug("Firebase practice data local storing time = \(Date().timeIntervalSince1970 - started)s")
                    
                    self.setPracticingDataLoaded()
                    NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPracticeDataFetched))
                }
            }
        }
    }
    
    func removePracticingDataOnServer(for data: PracticeDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").child(data.practiceItemId).child(data.entryDateString).child(data.entryId).removeValue()
        }
    }
    
    func removePracticeSessionPracticingDataOnServer(for data: PlaylistDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlist_data").child(data.playlistId).child(data.entryDateString).child(data.entryId).removeValue()
        }
    }
}
