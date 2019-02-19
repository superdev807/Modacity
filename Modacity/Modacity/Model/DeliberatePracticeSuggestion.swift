//
//  DeliberatePracticeSuggestion.swift
//  Modacity Inc
//
//  Created by Benjamin Chris on 12/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class DeliberatePracticeSuggestion: Mappable {
    
    var id = ""
    var suggestion = ""
    var hypos = [String]()
    var isStandard = true
    var createdAt = Date().timeIntervalSince1970
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        suggestion  <- map["suggestion"]
        hypos       <- map["hypos"]
        createdAt   <- map["created"]
    }
}
