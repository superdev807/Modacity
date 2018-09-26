//
//  MetrodroneParameters.swift
//  Modacity
//
//  Created by Benjamin Chris on 6/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class MetrodroneParameters {
    static let instance = MetrodroneParameters()
    
    var durationRatio: Float = 0.5
    var currNote : String = "X"
    
    var lastUpIndex: Int = -1
    var sustain  : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    
    var tempo: Int = 120
    var subdivisions: Int = 1
    var currOctave: Int = 3
    
    var ratioDroneToClick: Float = 0.5 // balance between drone and click when mixed. 0= no drone, 1 = all drone
    
    //--------
    // Adding this here just for convenient singleton access. This code should be moved to user profile/defaults/settings file.
    var tuningStandardA: Float = 440.0 // this needs to be a setting on the settings screen, acceptable values range from 220 to 880
    
    
    func setTuningStandardA(_ newStandard: Float) {
        tuningStandardA = newStandard
    }
    
    func isNoteSelected() -> Bool {
        return (currNote != "X")
    }
    //--------
}
