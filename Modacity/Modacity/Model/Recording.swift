//
//  Recording.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/12/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Recording: Mappable {
    var id: String!
    var fileName: String!
    var createdAt: String!
    var playlistId: String!
    var practiceName: String!
    var practiceEntryId: String!
    var practiceItemId: String!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        createdAt       <- map["created_at"]
        fileName        <- map["file_name"]
        playlistId      <- map["playlist_id"]
        practiceName    <- map["practice_name"]
        practiceEntryId <- map["practice_entry_id"]
        practiceItemId  <- map["practice_item_id"]
    }
    
    static func currentRecordingURL() -> URL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let soundFilePath = dirPath[0] + "/recording.wav"
        let url = URL(fileURLWithPath: soundFilePath)
        
        return url
    }
}
