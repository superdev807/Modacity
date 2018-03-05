//
//  Playlist.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/3/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Playlist: Mappable {
    
    var id: String!
    var name: String!
    var createdAt: String!
    var practiceItems: [String]?
    
    init() {
        name = ""
        createdAt = "\(Date().timeIntervalSince1970)"
        practiceItems = [String]()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        createdAt       <- map["created_at"]
        name            <- map["name"]
        practiceItems   <- map["practice_items"]
    }
}
