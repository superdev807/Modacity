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
                        if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for dataSnapshot in  dataSnapshots {
                                if let snapshotsPerDate = dataSnapshot.children.allObjects as? [DataSnapshot] {
                                    for snapshotPerDate in snapshotsPerDate {
                                        if let practicingDataSnapshots = snapshotPerDate.children.allObjects as? [DataSnapshot] {
                                            for practicingDataSnapshot in practicingDataSnapshots {
                                                let practicingDataId = practicingDataSnapshot.key
                                                if PracticingDailyLocalManager.manager.practicingData(forDataId: practicingDataId) == nil {
                                                    if let json = practicingDataSnapshot.value as? [String:Any] {
                                                        if let practicingData = PlaylistDaily(JSON: json) {
                                                            PlaylistDailyLocalManager.manager.storePlaylistPracitingDataToLocal(practicingData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
                        if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            for dataSnapshot in  dataSnapshots {
                                if let snapshotsPerDate = dataSnapshot.children.allObjects as? [DataSnapshot] {
                                    for snapshotPerDate in snapshotsPerDate {
                                        if let practicingDataSnapshots = snapshotPerDate.children.allObjects as? [DataSnapshot] {
                                            for practicingDataSnapshot in practicingDataSnapshots {
                                                let practicingDataId = practicingDataSnapshot.key
                                                if PracticingDailyLocalManager.manager.practicingData(forDataId: practicingDataId) == nil {
                                                    if let json = practicingDataSnapshot.value as? [String:Any] {
                                                        if let practicingData = PracticeDaily(JSON: json) {
                                                            PracticingDailyLocalManager.manager.storePracitingDataToLocal(practicingData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
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
        ModacityDebugger.debug("fetching...")
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlist_data").keepSynced(true)
            self.refUser.child(userId).child("playlist_data").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    if snapshot.exists() {
                        if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            PlaylistDailyLocalManager.manager.cleanData()
                            for dataSnapshot in  dataSnapshots {
                                if let snapshotsPerDate = dataSnapshot.children.allObjects as? [DataSnapshot] {
                                    for snapshotPerDate in snapshotsPerDate {
                                        if let practicingDataSnapshots = snapshotPerDate.children.allObjects as? [DataSnapshot] {
                                            for practicingDataSnapshot in practicingDataSnapshots {
                                                let practicingDataId = practicingDataSnapshot.key
                                                if PracticingDailyLocalManager.manager.practicingData(forDataId: practicingDataId) == nil {
                                                    if let json = practicingDataSnapshot.value as? [String:Any] {
                                                        if let practicingData = PlaylistDaily(JSON: json) {
                                                            PlaylistDailyLocalManager.manager.storePlaylistPracitingDataToLocal(practicingData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
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
    
    func fetchPracticingDataFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").keepSynced(true)
            self.refUser.child(userId).child("practice_data").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    if snapshot.exists() {
                        if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                            PracticingDailyLocalManager.manager.cleanData()
                            for dataSnapshot in  dataSnapshots {
                                if let snapshotsPerDate = dataSnapshot.children.allObjects as? [DataSnapshot] {
                                    for snapshotPerDate in snapshotsPerDate {
                                        if let practicingDataSnapshots = snapshotPerDate.children.allObjects as? [DataSnapshot] {
                                            for practicingDataSnapshot in practicingDataSnapshots {
                                                let practicingDataId = practicingDataSnapshot.key
                                                if PracticingDailyLocalManager.manager.practicingData(forDataId: practicingDataId) == nil {
                                                    if let json = practicingDataSnapshot.value as? [String:Any] {
                                                        if let practicingData = PracticeDaily(JSON: json) {
                                                            PracticingDailyLocalManager.manager.storePracitingDataToLocal(practicingData)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
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
}
