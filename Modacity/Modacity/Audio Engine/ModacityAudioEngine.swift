//
//  ModacityAudio.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/13/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import Foundation
import AVFoundation

class ModacityAudioEngine {
    static var engine : ModacityAudio = ModacityAudio()
}

class ModacityAudio {
    
    var audioEngine:AVAudioEngine!
    
    func initEngine() {
        NotificationCenter.default.addObserver(self, selector: #selector(processRouteChange), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            if let inputs = audioSession.availableInputs {
                if inputs.count == 1 {
                    try audioSession.overrideOutputAudioPort(.speaker)
                }
            }
        } catch let error {
            ModacityDebugger.debug("audio session error \(error)")
        }
    }
    
    func attachAudio(node: AVAudioPlayerNode) {
        ModacityDebugger.debug("Audio node attached to engine.")
        audioEngine.attach(node)
    }
    
    func connectAudio(node: AVAudioPlayerNode, format: AVAudioFormat) {
        ModacityDebugger.debug("Audio node connected to engine.")
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
    }
    
    func checkEngineStatus() {
        
    }
    
    func startEngine() {
        ModacityDebugger.debug("Audio engine started.")
        do {
            try audioEngine.start()
        } catch let err {
            ModacityDebugger.debug("start audio engine error - \(err)")
        }
    }
    
    func restartEngine() {
        audioEngine.stop()
    }
    
    @objc func processRouteChange() {
        ModacityDebugger.debug("audio session route changed.")
        let audioSession = AVAudioSession.sharedInstance()
        if let inputs = audioSession.availableInputs {
            if inputs.count == 1 {
                do {
                    try audioSession.overrideOutputAudioPort(.speaker)
                } catch let err {
                    ModacityDebugger.debug("error in route change process with override speaker \(err)")
                }
            }
        }
    }
}
