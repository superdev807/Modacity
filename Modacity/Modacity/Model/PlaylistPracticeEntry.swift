//
//  PracticeItem.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/1/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PlaylistPracticeEntry: Mappable {
    
    var entryId: String!
    var name: String!
    var countDownDuration: Int?
    var practiceItemId: String!
    
    init() {
        self.entryId = UUID().uuidString
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        entryId             <- map["id"]
        name                <- map["name"]
        countDownDuration   <- map["count_down_duration"]
        practiceItemId      <- map["item_id"]
    }
    
    func practiceItem() -> PracticeItem? {
        return PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId)
    }
    
}
