//
//  MetrodroneParameters.swift
//  Modacity
//
//  Created by BC Engineer on 6/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class MetrodroneParameters {
    static let instance = MetrodroneParameters()
    
    var durationRatio: Float = 0.5
    var currNote : String = "X"
    
    var lastUpIndex: Int = -1
    var sustain  : Bool = false
    var isSustaining : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    
    var tempo: Int = 120
    var subdivisions: Int = 1
    var currOctave: Int = 4
    
}
