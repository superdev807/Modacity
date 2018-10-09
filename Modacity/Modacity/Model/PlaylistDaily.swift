//
//  PracticeItem.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/1/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//`

import UIKit
import ObjectMapper

class PlaylistDaily: Mappable {
    
    var entryDateString: String!        // yy-MM-dd
    var entryId: String!
    var playlistId: String!
    var fromTime: String!               // HH:mm
    var started: TimeInterval!
    var practiceTimeInSeconds: Int! = 0
    var practices: [String]!            // practice daily data ids
    var realPracticeTimeInSeconds: Int! = -1
    
    init() {
        self.entryId = UUID().uuidString
        self.practices = [String]()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        entryDateString             <- map["date"]
        entryId                     <- map["id"]
        playlistId                  <- map["item_id"]
        fromTime                    <- map["from_time"]
        practiceTimeInSeconds       <- map["time"]
        practices                   <- map["practices"]
        started                     <- map["started"]
        realPracticeTimeInSeconds   <- map["realPractice"]
    }
    
    func playlistItem() -> Playlist? {
        return PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistId)
    }
    
    func practicesArray() -> [PracticeDaily]? {
        if practices != nil {
            var result = [PracticeDaily]()
            for practiceId in practices {
                if let practicing = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceId) {
                    result.append(practicing)
                }
            }
            
            if result.count == 0 {
                return nil
            }
            
            return result
        }
        
        return nil
    }
}
