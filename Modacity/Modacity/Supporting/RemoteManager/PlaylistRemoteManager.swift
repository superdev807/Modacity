//
//  PlaylistRemoteManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/9/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlaylistRemoteManager {
    
    static let manager = PlaylistRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlists").observeSingleEvent(of: .value) { (snapshot) in
                self.setPlaylistItemsSynchronized()
                if (!snapshot.exists()) {
                    self.startUploadAllPlaylists()      // sync from local
                } else {
                    if snapshot.children.allObjects.count == 0 {
                        self.processDefaultDataship()
                    }
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let playlistData = data.value as? [String:Any] {
                            if let item = Playlist(JSON: playlistData) {
                                if PlaylistLocalManager.manager.loadPlaylist(forId: item.id) == nil {
                                    PlaylistLocalManager.manager.storePlaylist(item)
                                }
                            }
                        }
                    }
                }
                NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPlaylistLoadedFromServer))
            }
        }
    }
    
    func playlistItemsSynchronized() -> Bool {
        return UserDefaults.standard.bool(forKey: "playlist_items_synchronized")
    }
    
    func setPlaylistItemsSynchronized() {
        UserDefaults.standard.set(true, forKey: "playlist_items_synchronized")
        UserDefaults.standard.synchronize()
    }
    
    func startUploadAllPlaylists() {
        if let userId = MyProfileLocalManager.manager.userId() {
            if let playlists = PlaylistLocalManager.manager.loadPlaylists() {
                if playlists.count == 0 {
                    self.processDefaultDataship()
                }
                for playlist in playlists {
                    refUser.child(userId).child("playlists").child(playlist.id).setValue(playlist.toJSON())
                }
            } else {
                self.processDefaultDataship()
            }
        }
    }
    
    func processDefaultDataship() {
        if !AppOveralDataManager.manager.defaultDataShiped() {
            OverallDataRemoteManager.manager.shipDefaultData()
        }
//        PlaylistLocalManager.manager.setPlaylistLoadedFlags()
    }
    
    func dbReferenceForPlaylists() -> DatabaseReference? {
        if let userId = MyProfileLocalManager.manager.userId() {
            return refUser.child(userId).child("playlists")
        }
        
        return nil
    }
    
    func dbReference(for itemId:String) -> DatabaseReference? {
        if let userId = MyProfileLocalManager.manager.userId() {
            return refUser.child(userId).child("playlists").child(itemId)
        }
        
        return nil
    }
    
    func update(item: Playlist) {
        if let db = self.dbReference(for: item.id) {
            db.updateChildValues(item.toJSON())
        }
    }
    
    func add(item: Playlist) {
        if let db = self.dbReference(for: item.id) {
            db.setValue(item.toJSON())
        }
    }
}
