//
//  PracticeItem.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/1/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class PracticeItem: Mappable {
    
    var id: String!
    var name: String! {
        didSet {
            self.lastPracticedSortKey = self.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + (self.name ?? "")
        }
    }
    var notes: [Note]?
    var lastPracticed: String? {
        didSet {
            self.lastPracticedSortKey = self.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + (self.name ?? "")
            self.lastPracticedDateKeyString = self.lastPracticedDateString()
        }
    }
    var lastPracticedDurationInSecond: Int?
    var rating: Double = 0
    var isFavorite: Int = 0
    var lastPracticedSortKey: String?
    var lastPracticedDateKeyString: String?
    
    var droneSettings: DroneSettings? = nil
    
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
        droneSettings <- map["drone_settings"]
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
    
    func changeNoteTitle(for noteId:String, title: String) {
        let note = self.notes?.first { $0.id == noteId }
        note?.note = title
        self.updateMe()
    }
    
    func updateMe() {
        PracticeItemLocalManager.manager.updatePracticeItem(self)
    }
    
    func firstCharacter() -> String {
        let name = self.name
        var firstCharacter = ""
        if name == nil || name?.first == nil || (name!.lowercased().first! < "a" || name!.lowercased().first! > "z") {
            firstCharacter = "#"
        } else {
            firstCharacter = "\(name!.uppercased().first!)"
        }
        return firstCharacter
    }
    
    func ratingString() -> String {
        return "\(Int(rating)) STARS"
    }
    
    func lastPracticeTime() -> Date {
        if let lastPracticed = lastPracticed {
            let timeInterval = Double(lastPracticed) ?? 0
            if timeInterval != 0 {
                return Date(timeIntervalSince1970: timeInterval)
            }
        }
        
        return Date(timeIntervalSince1970: 0)
    }
    
    func lastPracticedDateString() -> String {
        var sectionString = "#"
        if let lastPracticed = lastPracticed {
            let timeInterval = Double(lastPracticed) ?? 0
            if timeInterval != 0 {
                sectionString = AppUtils.stringFromDateLocale(from: Date(timeIntervalSince1970: timeInterval))
            }
        }
        
        return sectionString
    }
    
    func lastPracticedTimeString() -> String {
        if let lastPracticed = self.lastPracticed {
            let timeInterval = Double(lastPracticed) ?? 0
            if timeInterval == 0 {
                return ""
            } else {
                let last = AppUtils.stringFromDateLocale(from: Date(timeIntervalSince1970: timeInterval))
                let seconds = self.lastPracticedDurationInSecond ?? 0
                var timeString = "\(seconds)"
                var unit = "seconds"
                
                if seconds == 0 || (seconds > 60 && seconds < 3600) {
                    timeString = "\(seconds / 60)"
                    unit = "minutes"
                } else if seconds >= 3600 {
                    timeString = String(format: "%.1f", Double(seconds) / 3600.0)
                    unit = "hours"
                }
                
                return "Last practiced \(last) for \(timeString) \(unit)"
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
    
    func updateDroneSettings(_ settings:DroneSettings) {
        self.droneSettings = settings
        self.updateMe()
    }
}
