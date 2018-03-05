//
//  Me.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Me: Mappable {
    
    var uid: String!
    var email: String!
    var createdAt: TimeInterval!
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid         <- map["uid"]
        email       <- map["email"]
        createdAt   <- map["created_at"]
        name        <- map["name"]
    }
    
    func displayName() -> String {
        if name == nil || name == "" {
            return email.components(separatedBy: "@")[0]
        } else {
            return name!
        }
    }
}
