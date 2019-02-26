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
            self.refUser.child(userId).child("playlists").keepSynced(true)
            self.refUser.child(userId).child("playlists").observeSingleEvent(of: .value) { (snapshot) in
                
                if (!snapshot.exists()) {
                    self.startUploadAllPlaylists()      // sync from local
                } else {
                    if snapshot.children.allObjects.count == 0 {
                        self.processDefaultDataship()
                        self.setPlaylistItemsSynchronized()
                        NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPlaylistLoadedFromServer))
                        return
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
                
                self.setPlaylistItemsSynchronized()
                NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPlaylistLoadedFromServer))
            }
            
            self.refUser.child(userId).child("recent_sessions").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let value = snapshot.value as? [String:String] {
                        PlaylistLocalManager.manager.saveRecentSessions(sessions: value)
                    }
                }
                
                self.setRecentSessionsSynchronized()
                NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationRecentSessionsLoadedFromServer))
            }
        }
    }
    
    func eraseData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlists").removeValue { (_, _) in
                completion()
            }
        }
        PlaylistLocalManager.manager.cleanPlaylists()
    }
    
    func fullSync(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlists").observeSingleEvent(of: .value) { (snapshot) in
                PlaylistLocalManager.manager.cleanPlaylists()
                for data in snapshot.children.allObjects as! [DataSnapshot] {
                    if let playlistData = data.value as? [String:Any] {
                        if let item = Playlist(JSON: playlistData) {
                            if PlaylistLocalManager.manager.loadPlaylist(forId: item.id) == nil {
                                PlaylistLocalManager.manager.storePlaylist(item)
                            }
                        }
                    }
                }
                completion()
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
    
    func recentSessionsSynchronized() -> Bool {
        return UserDefaults.standard.bool(forKey: "recent_session_synchronized")
    }
    
    func setRecentSessionsSynchronized() {
        UserDefaults.standard.set(true, forKey: "recent_session_synchronized")
        UserDefaults.standard.synchronize()
    }
    
    func startUploadAllPlaylists() {
        if let userId = MyProfileLocalManager.manager.userId() {
            if let playlists = PlaylistLocalManager.manager.loadPlaylists() {
                if playlists.count == 0 {
                    self.processDefaultDataship()
                    return
                }
                for playlist in playlists {
                    refUser.child(userId).child("playlists").child(playlist.id).setValue(playlist.toJSON())
                }
            } else {
                self.processDefaultDataship()
                return
            }
        }
        
        NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPlaylistLoadedFromServer))
    }
    
    func processDefaultDataship() {
        if !AppOveralDataManager.manager.defaultDataShiped() {
            OverallDataRemoteManager.manager.shipDefaultData()
        }
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
    
    
    
    func storeRecentSession(sessionId: String, value: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("recent_sessions").child(sessionId).setValue(value)
        }
    }
    
    func removeRecentSession(sessionId: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("recent_sessions").child(sessionId).removeValue()
        }
    }
    
    func storeFavoriteSession(sessionId: String, value: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("favorite_sessions").child(sessionId).setValue(value)
        }
    }
    
    func removeFavoriteSession(sessionId: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("favorite_sessions").child(sessionId).removeValue()
        }
    }
}
