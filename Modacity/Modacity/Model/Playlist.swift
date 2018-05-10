//
//  Playlist.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/3/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Playlist: Mappable {
    
    var id: String!
    var name: String!
    var createdAt: String!
    var playlistPracticeEntries: [PlaylistPracticeEntry]!
    var notes: [Note]?
    
    init() {
        id = ""
        name = ""
        createdAt = "\(Date().timeIntervalSince1970)"
        playlistPracticeEntries = [PlaylistPracticeEntry]()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        createdAt       <- map["created_at"]
        name            <- map["name"]
        playlistPracticeEntries   <- map["practice_items"]
        notes           <- map["notes"]
    }
    
    func addNote(text: String) {
        if self.notes == nil {
            self.notes = [Note]()
        }
        
        let note = Note()
        note.id = UUID().uuidString
        note.note = text
        note.createdAt = "\(Date().timeIntervalSince1970)"
        self.notes!.append(note)
        
        self.updateMe()
    }
    
    func deleteNote(for noteId:String) {
        
        self.notes = self.notes?.filter { $0.id != noteId }
        self.updateMe()
        
    }
    
    func archiveNote(for noteId:String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.archived = !(note?.archived ?? false)
        self.updateMe()
    }
    
    func updateMe() {
        PlaylistLocalManager.manager.storePlaylist(self)
        PlaylistRemoteManager.manager.update(item: self)
    }
}
