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
    
    var durationRatio: Float = 0.5 {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "duration_ratio", "value":durationRatio, "from": oldValue])
        }
    }
    var currNote : String = "X" {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "curr_note", "value":currNote, "from": oldValue])
        }
    }
    
    var lastUpIndex: Int = -1 {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "last_up_index", "value":lastUpIndex, "from": oldValue])
        }
    }
    
    var sustain  : Bool = false {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "sustain", "value":sustain, "from": oldValue])
        }
    }
    
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    
    var tempo: Int = 120 {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "tempo", "value":tempo, "from": oldValue])
        }
    }
    
    var subdivisions: Int = 1 {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "subdivisions", "value":subdivisions, "from": subdivisions])
        }
    }
    
    var currOctave: Int = 3 {
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "curr_octave", "value":currOctave, "from": oldValue])
        }
    }
    
    var ratioDroneToClick: Float = 0.5 {// balance between drone and click when mixed. 0= no drone, 1 = all drone
        didSet {
            NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationMetrodroneParametersUpdated, object: nil, userInfo: ["key": "ratio_click", "value":ratioDroneToClick, "from": oldValue])
        }
    }
    
    //--------
    // Adding this here just for convenient singleton access. This code should be moved to user profile/defaults/settings file.
    var tuningStandardA: Float = 440.0 // this needs to be a setting on the settings screen, acceptable values range from 220 to 880
    
    func setTuningStandardA(_ newStandard: Float) {
        tuningStandardA = newStandard
    }
    
    func isNoteSelected() -> Bool {
        return (currNote != "X")
    }
    
    func setFromSettings(_ settings: DroneSettings) {
        self.durationRatio = settings.durationRatio
        self.currNote = settings.currNote
        self.currOctave = settings.currOctave
        self.lastUpIndex = settings.lastUpIndex
        self.ratioDroneToClick = settings.ratioDroneToClick
        self.sustain = settings.sustain
        self.tempo = settings.tempo
        self.subdivisions = settings.subdivisions
    }
    
    func extractDroneSettings() -> DroneSettings {
        let settings = DroneSettings()
        settings.durationRatio = self.durationRatio
        settings.currOctave = self.currOctave
        settings.currNote = self.currNote
        settings.lastUpIndex = self.lastUpIndex
        settings.ratioDroneToClick = self.ratioDroneToClick
        settings.sustain = self.sustain
        settings.tempo = self.tempo
        settings.subdivisions = self.subdivisions
        return settings
    }
}
