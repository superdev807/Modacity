//
//  Playlist.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/3/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class Playlist: Mappable {
    
    var id: String!
    var name: String!
    var createdAt: String!
    var playlistPracticeEntries: [PlaylistPracticeEntry]!
    var notes: [Note]?
    var archived = false
    var isFavorite: Bool = false
    
    init() {
        id = ""
        name = ""
        createdAt = "\(Date().timeIntervalSince1970)"
        playlistPracticeEntries = [PlaylistPracticeEntry]()
        archived = false
        isFavorite = false
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                          <- map["id"]
        createdAt                   <- map["created_at"]
        name                        <- map["name"]
        playlistPracticeEntries     <- map["practice_items"]
        notes                       <- map["notes"]
        archived                    <- map["archived"]
        isFavorite                  <- map["favorite"]
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
    
    func changeNoteTitle(for noteId: String, to: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.note = to
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
    
    func changeNoteTitle(for noteId:String, title: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.note = title
        self.updateMe()
    }
    
    func changeNoteSubTitle(for noteId:String, subTitle: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.subTitle = subTitle
        self.updateMe()
    }
    
    func setFavorite(_ favorite: Bool) {
        self.isFavorite = favorite
        self.updateMe()
    }
    
    func updateMe() {
        PlaylistLocalManager.manager.storePlaylist(self)
        PlaylistRemoteManager.manager.update(item: self)
    }
    
    func totalSumOfRemainingTimers() -> Int {
        if let entries = self.playlistPracticeEntries {
            var totalSum = 0
            for entry in entries {
                if let duration = entry.countDownDuration {
                    totalSum = totalSum + duration
                }
            }
            
            return totalSum
        }
        
        return 0
    }
}
