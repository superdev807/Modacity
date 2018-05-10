//
//  PracticeItem.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/1/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PracticeItem: Mappable {
    
    var id: String!
    var name: String!
    var notes: [Note]?
    
    init() {
        name = ""
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        notes       <- map["notes"]
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
        PracticeItemLocalManager.manager.updatePracticeItem(self)
        PracticeItemRemoteManager.manager.update(item: self)
    }
    
}
