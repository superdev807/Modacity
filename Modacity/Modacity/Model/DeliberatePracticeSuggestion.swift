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
    
    var suggestion = ""
    var hypos = [String]()
    var isStandard = true
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        suggestion  <- map["suggestion"]
        hypos       <- map["hypos"]
    }
}
