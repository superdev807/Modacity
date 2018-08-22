//
//  PracticeItem.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/1/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//`

import UIKit
import ObjectMapper

class PracticeDaily: Mappable {
    
    var entryDateString: String!    // yy-MM-dd
    var entryId: String!
    var practiceItemId: String!
    var playlistPracticeEntryId: String?
    var playlistId: String!
    var fromTime: String!       // HH:mm:ss
    var practiceTimeInSeconds: Int!
    var rating: Double!
    var improvements: [ImprovedRecord]?
    var startedTime: TimeInterval!
    
    var isManual = false
    var isEdited = false
    var isDeleted = false
    
    init() {
        self.entryId = UUID().uuidString
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        entryDateString             <- map["date"]
        entryId                     <- map["id"]
        practiceItemId              <- map["item_id"]
        fromTime                    <- map["from_time"]
        practiceTimeInSeconds       <- map["time"]
        rating                      <- map["rating"]
        playlistPracticeEntryId     <- map["practice_entry_id"]
        playlistId                  <- map["playlist_id"]
        improvements                <- map["improvements"]
        startedTime                 <- map["started_time"]
        isManual                    <- map["is_manual"]
        isEdited                    <- map["is_edited"]
        isDeleted                   <- map["is_deleted"]
    }
    
    func practiceItem() -> PracticeItem? {
        return PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId)
    }
}
