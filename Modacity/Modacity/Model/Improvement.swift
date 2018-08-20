//
//  Improvement.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class Improvement: Mappable {
    
    var id: String!
    var playlistId: String!
    var createdAt: String!
    var practiceName: String!
    var practiceEntryId: String!
    var suggestion: String!
    var hypothesis: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        createdAt       <- map["created_at"]
        playlistId      <- map["playlist_id"]
        practiceName    <- map["practice_name"]
        practiceEntryId <- map["practice_entry_id"]
        suggestion      <- map["suggestion"]
        hypothesis      <- map["hypothesis"]
    }
}
