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
    var isSustaining : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    
    var tempo: Int = 120
    var subdivisions: Int = 1
    var currOctave: Int = 4
    
    //--------
    // Adding this here just for convenient singleton access. This code should be moved to user profile/defaults/settings file.
    var tuningStandardA: Float = 440.0 // this needs to be a setting on the settings screen, acceptable values range from 220 to 880
    var tuningPitchMultiplier: Float = 0.0 //this will range from -2400 to +2400, usually quite small though like 0.1. This needs to be recalculated whenever tuningStandardA changes.
    
    
    
    func setTuningStandardA(_ newStandard: Float) {
        tuningStandardA = newStandard
        let ratio:Float = (newStandard/440.0)
        let cents:Float = log2(ratio) * 1200.0
        tuningPitchMultiplier = cents
        // after this happens we need to send the new tuningPitchMultiplier to MetrodroneAudio
        // use MetrodroneAudio.updatePitchMultiplier
    }
    //--------
}
