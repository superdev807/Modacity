//
//  PracticeItem.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/1/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PracticeItemEntry: Mappable {
    
    var entryId: String!
    var name: String!
    var countDownDuration: Int?
    
    init(name: String) {
        self.name = name
        self.entryId = UUID().uuidString
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        entryId    <- map["id"]
        name       <- map["name"]
        countDownDuration <- map["count_down_duration"]
    }
    
}
