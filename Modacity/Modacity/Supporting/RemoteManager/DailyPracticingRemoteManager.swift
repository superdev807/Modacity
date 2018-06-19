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
        if let userId = MyProfileLocalManager.manager.me?.uid {
            self.refUser.child(userId).child("practice_data").child(data.practiceItemId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
        }
    }
    
    func createPlaylistPracticing(_ data: PlaylistDaily) {
        if let userId = MyProfileLocalManager.manager.me?.uid {
            self.refUser.child(userId).child("playlist_data").child(data.playlistId).child(data.entryDateString).child(data.entryId).setValue(data.toJSON())
        }
    }
}
