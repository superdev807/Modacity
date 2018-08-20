//
//  Improvement.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class ImprovedRecord: Mappable {
    
    var suggestion: String!
    var hypothesis: String!
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        suggestion      <- map["suggestion"]
        hypothesis      <- map["hypothesis"]
    }
}
