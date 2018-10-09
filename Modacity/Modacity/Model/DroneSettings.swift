//
//  DroneSettings.swift
//  Modacity
//
//  Created by BC Engineer on 28/9/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class DroneSettings: Mappable {

    var durationRatio: Float = 0.5
    var currNote : String = "X"
    var lastUpIndex: Int = -1
    var sustain  : Bool = false
    var tempo: Int = 120
    var subdivisions: Int = 1
    var currOctave: Int = 3
    var ratioDroneToClick: Float = 0.5
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        durationRatio <- map["duration_ratio"]
        currNote <- map["curr_note"]
        lastUpIndex <- map["last_up_index"]
        sustain <- map["sustain"]
        tempo <- map["tempo"]
        subdivisions <- map["subdivisions"]
        currOctave <- map["curr_octave"]
        ratioDroneToClick <- map["ratio_click"]
    }
    
}
