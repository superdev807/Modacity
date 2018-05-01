//
//  Note.swift
//  Modacity
//
//  Created by BC Engineer on 1/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Note: Mappable {
    var id: String!
    var createdAt: String!
    var note: String! = ""
    var archived: Bool! = false
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        createdAt       <- map["created_at"]
        note            <- map["note"]
        archived        <- map["archived"]
    }
}
