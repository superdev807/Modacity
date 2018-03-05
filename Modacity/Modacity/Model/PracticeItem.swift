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
    var createdAt: String!
    var rate: Double!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        createdAt   <- map["created_at"]
        name        <- map["name"]
        rate        <- map["rate"]
    }
    
}
