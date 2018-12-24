//
//  DefaultDataShipManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 25/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DefaultDataShipManager {
    
    static let manager = DefaultDataShipManager()
    
    func produceDefaultData(completed: @escaping (Bool) -> ()) {

        Database.database().reference().child("default_data").keepSynced(true)

        Database.database().reference().child("default_data").observeSingleEvent(of:.value, with: { (snapshot) in
            if snapshot.exists() {
                ModacityDebugger.debug("Produced default data from online")
                if let rootValue = snapshot.value as? [String:Any] {
                    if let practices = rootValue["practices"] as? [String:Any] {
                        for practiceName in practices.keys {
                            if let json = practices[practiceName] as? [String:Any] {
                                if let practiceItem = PracticeItem(JSON: json) {
                                    PracticeItemLocalManager.manager.addPracticeItem(practiceItem, isDefault: true)
                                }
                            }
                        }
                    }

                    if let playlists = rootValue["playlists"] as? [String:Any] {
                        for playlistId in playlists.keys {
                            if let json = playlists[playlistId] as? [String:Any] {
                                if let playlist = Playlist(JSON: json) {
                                    PlaylistLocalManager.manager.addPlaylist(playlist: playlist, isDefault: true)
                                }
                            }
                        }
                    }

                    completed(true)
                    return
                }
            } else {
                self.produceFromLocal(completed: completed)
            }
        }) { (error) in
            self.produceFromLocal(completed: completed)
        }
    }
    
    func produceFromLocal(completed: @escaping (Bool) -> ()) {
        ModacityDebugger.debug("Produced default data from local")
        if let plistURL = Bundle.main.url(forResource: "defaultdata", withExtension: "plist") {
            if let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] {
                if let practices = plist["practices"] as? [String:Any] {
                    for practiceId in practices.keys {
                        if let practiceJSON = practices[practiceId] as? [String:Any] {
                            if let practice = PracticeItem(JSON: practiceJSON) {
                                PracticeItemLocalManager.manager.addPracticeItem(practice, isDefault: true)
                            }
                        }
                    }
                }
                
                if let playlists = plist["playlists"] as? [String:Any] {
                    for playlistId in playlists.keys {
                        if let json = playlists[playlistId] as? [String:Any] {
                            if let playlist = Playlist(JSON: json) {
                                PlaylistLocalManager.manager.addPlaylist(playlist: playlist, isDefault: true)
                            }
                        }
                    }
                }
                
                completed(true)
                return
            }
        }
        completed(false)
    }
    
    func AddNewPracticeItem(_ itemName: String, notes: [String] = []) -> PracticeItem {
        let practiceItem = PracticeItem()
        practiceItem.name = itemName
        practiceItem.id = UUID().uuidString
       
       
        if (notes.count > 0) {
            for note in notes {
                practiceItem.addNote(text: note)
            }
        }
        PracticeItemLocalManager.manager.addPracticeItem(practiceItem, isDefault: true)
        
        return practiceItem
    }
    
    func AddNewPlaylist(_ playlistName: String) -> Playlist {
        let playlist = Playlist()
        playlist.id = UUID().uuidString
        playlist.name = playlistName
        playlist.playlistPracticeEntries = [PlaylistPracticeEntry]()
        
        return playlist
    }
    
    func CreatePlaylistPracticeEntry(fromItem: PracticeItem, timerDuration: Int = 0) -> PlaylistPracticeEntry {
        
        let playlistPractice = PlaylistPracticeEntry()
        playlistPractice.practiceItemId = fromItem.id
        playlistPractice.countDownDuration = timerDuration
        
        return playlistPractice
    }
}
