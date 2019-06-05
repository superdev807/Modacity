//
//  ModacityAudioSessionManager.swift
//  Modacity
//
//  Created by Dream Realizer on 21/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftMessages

class ModacityAudioSessionManager: NSObject {
    
    static let manager = ModacityAudioSessionManager()
    
    var audioRecordingEnabled = false
    
    func initAudioSession() {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        var sessionCategoryDidSet = false
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.defaultToSpeaker, .allowBluetooth, /*.allowAirPlay, .allowBluetoothA2DP,*/ .mixWithOthers])
            } else {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
            }
            sessionCategoryDidSet = true
        } catch let error {
            ModacityDebugger.debug("audio session first step init error in init audio setCategory \(error)")
        }
        
        if !sessionCategoryDidSet {
            do {
                if #available(iOS 10.0, *) {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
                }
                sessionCategoryDidSet = true
            } catch let error {
                ModacityDebugger.debug("audio session second step initerror in init audio setCategory \(error)")
            }
        }
        
        do {
            try audioSession.setActive(true)
            audioRecordingEnabled = false
        } catch let error {
            ModacityDebugger.debug("audio session error in init audio setActive(true) \(error)")
        }
        
        if !sessionCategoryDidSet {
            do {
                try audioSession.overrideOutputAudioPort(.speaker)
            } catch let error {
                ModacityDebugger.debug("audio session error in init audio overrideOutputAudioPort(true) \(error)")
            }
        }
        
    }
    
    func openRecording() {
        
        ModacityDebugger.debug("OPENING AUDIO SESSION FOR RECORDING")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .mixWithOthers])
            } else {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
            }
            audioRecordingEnabled = true
            try audioSession.setActive(true)
        } catch let error {
            ModacityDebugger.debug("audio session error in open recording \(error)")
        }
    }
    
    func closeRecording() {
        ModacityDebugger.debug("CLOSING AUDIO SESSION FOR RECORDING")
        initAudioSession()
    }
    
    func checkRecordingIsAvailable() -> Bool {
        if !audioRecordingEnabled {
            return false
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category != AVAudioSessionCategoryPlayAndRecord {
            return false
        }
        
        return true
    }
    
    func activeSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let err {
            ModacityDebugger.debug("audio session activation error \(err)")
        }
    }
    
    func deactiveSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let err {
            ModacityDebugger.debug("audio session activation error \(err)")
        }
    }
    
    func printAudioOutputs() {
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        
        var body = ""
        for output in currentRoute.outputs {
            body = body + output.portName + " : " + output.portType + "\n"
        }
        
        var title = "Inputs: "
        
        if let availableInputs = AVAudioSession.sharedInstance().availableInputs {
            for input in availableInputs {
                title = title + input.portName + " : " + input.portType + "\n"
            }
        }
        
        ModacityDebugger.debug("audio outputs \(body)")
        ModacityDebugger.debug("available inputs \(title)")
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .seconds(seconds: 10)
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = true
        view.titleLabel?.numberOfLines = 0
        view.bodyLabel?.numberOfLines = 0
        view.configureTheme(.warning)
        view.configureDropShadow()
        view.backgroundView.backgroundColor = Color(hexString:"#5756E6")
        view.button?.setTitle("Close", for: .normal)
        view.button?.setTitleColor(Color.white, for: .normal)
        view.button?.backgroundColor = Color(hexString:"#51BE38")
        view.buttonTapHandler = { _ in
            SwiftMessages.hide()
        }
        view.configureContent(title: title, body: body)
        SwiftMessages.show(config: config, view: view)
    }
}
