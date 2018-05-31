//
//  PlaylistRemoteManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 4/9/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PlaylistRemoteManager {
    
    static let manager = PlaylistRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("playlists").observeSingleEvent(of: .value) { (snapshot) in
                if (!snapshot.exists()) {
                    self.startUploadAllPlaylists()      // sync from local
                } else {
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let playlistData = data.value as? [String:Any] {
                            if let item = Playlist(JSON: playlistData) {
                                if PlaylistLocalManager.manager.loadPlaylist(forId: item.id) == nil {
                                    PlaylistLocalManager.manager.storePlaylist(item)
                                }
                            }
                        }
                    }
                    NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPlaylistLoadedFromServer))
                }
            }
        }
    }
    
    func startUploadAllPlaylists() {
        if let userId = MyProfileLocalManager.manager.userId() {
            print("Uploading all local playlists to backend.")
            if let playlists = PlaylistLocalManager.manager.loadPlaylists() {
                for playlist in playlists {
                    refUser.child(userId).child("playlists").child(playlist.id).setValue(playlist.toJSON())
                }
            }
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
    
    func removePlaylist(for itemId:String) {
        if let db = self.dbReference(for: itemId) {
            db.removeValue()
        }
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
