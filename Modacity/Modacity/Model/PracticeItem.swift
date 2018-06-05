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
    var lastPracticed: String?
    var lastPracticedDurationInSecond: Int?
    var rating: Double = 0
    var isFavorite: Int = 0
    
    init() {
        name = ""
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        notes       <- map["notes"]
        rating      <- map["rating"]
        isFavorite  <- map["is_favorite"]
        lastPracticed <- map["last_practiced"]
        lastPracticedDurationInSecond <- map["last_practiced_duration"]
    }
    
    func updateRating(rating: Double) {
        self.rating = rating
        self.updateMe()
    }
    
    func updateFavorite(favorite: Bool) {
        self.isFavorite = favorite ? 1 : 0
        self.updateMe()
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
    
    func changeNoteTitle(for noteId: String, to: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.note = to
        self.updateMe()
    }
    
    func changeNoteSubTitle(for noteId:String, subTitle: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.subTitle = subTitle
        self.updateMe()
    }
    
    func updateMe() {
        PracticeItemLocalManager.manager.updatePracticeItem(self)
    }
    
    func lastPracticedTimeString() -> String {
        if let lastPracticed = self.lastPracticed {
            let timeInterval = Double(lastPracticed) ?? 0
            if timeInterval == 0 {
                return ""
            } else {
                let last = Date(timeIntervalSince1970: timeInterval).toString(format: "M/d/yy")
                return "Last practiced \(last) for \(self.lastPracticedDurationInSecond ?? 0) seconds"
            }
        } else {
            return ""
        }
    }
    
    func updateLastPracticedTime(to: Date) {
        self.lastPracticed = "\(to.timeIntervalSince1970)"
        self.updateMe()
    }
    
    func updateLastPracticedDuration(duration : Int) {
        self.lastPracticedDurationInSecond = duration
        self.updateMe()
    }
}
