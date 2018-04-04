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
        audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            if let inputs = audioSession.availableInputs {
                if inputs.count == 1 {
                    try audioSession.overrideOutputAudioPort(.speaker)
                }
            }
            
        } catch let error  {
            print("audio session error \(error)")
        }
    }
    
    func attachAudio(node: AVAudioPlayerNode) {
        print("Audio node attached to engine.")
        audioEngine.attach(node)
    }
    
    func connectAudio(node: AVAudioPlayerNode, format: AVAudioFormat) {
        print("Audio node connected to engine.")
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
    }
    
    func startEngine() {
        print("Audio engine started.")
        try! audioEngine.start()
    }
}
