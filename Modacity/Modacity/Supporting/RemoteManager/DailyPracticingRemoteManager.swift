//
//  DailyPracticingRemoteManager.swift
//  Modacity
//
//  Created by BC Engineer on 19/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
    
    func createPlaylistPracticing(_ data: PlaylistDaily) {
        if let userId = MyProfileLocalManager.manager.userId() {
            if data.playlistId != nil && data.playlistId != "" {
                self.refUser.child(userId).child("playlist_data").child(data.playlistId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
            }
        }
    }
    
    func fetchPlaylistPracticingDataFromServer() {
        ModacityDebugger.debug("fetching...")
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlist_data").observeSingleEvent(of: .value) { (snapshot) in
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
            }
        }
    }
    
    func fetchPracticingDataFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").observeSingleEvent(of: .value) { (snapshot) in
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
            }
        }
    }
    
    func removePracticingDataOnServer(for practiceItemId: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practice_data").child(practiceItemId).removeValue()
        }
    }
}
