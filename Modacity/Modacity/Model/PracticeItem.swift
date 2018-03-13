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
    
    var name: String!
    var rate: Double!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        rate       <- map["rate"]
        name       <- map["name"]
    }
    
}
