//
//  ModacityAudio.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftMessages

class ModacityAudioEngine {
    static var engine : ModacityAudio = ModacityAudio()
}

class ModacityAudio {
    
    var audioEngine:AVAudioEngine!

    func initEngine() {
//        printAudioOutputs()
        NotificationCenter.default.addObserver(self, selector: #selector(processRouteChange), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        audioEngine = AVAudioEngine()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            } else {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .allowBluetooth])
            }
            try audioSession.setActive(true)
        } catch let error {
            ModacityDebugger.debug("audio session error \(error)")
        }
    }
    
    func attachAudio(node: AVAudioNode) {
        ModacityDebugger.debug("Audio node attached to engine.")
        audioEngine.attach(node)
    }
    
    func connectAudio(node: AVAudioNode, format: AVAudioFormat) {
        ModacityDebugger.debug("Audio node connected to engine.")
        audioEngine.connect(node, to: audioEngine.mainMixerNode, format: format)
        
    }
    
    func connectMultipleNodes(node1: AVAudioNode, node2: AVAudioNode, format: AVAudioFormat) {
        ModacityDebugger.debug("Audio node connecting to other node.")
        audioEngine.connect(node1, to: node2, format: format)
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
    
    @objc func processRouteChange() {
//        self.printAudioOutputs()
        ModacityDebugger.debug("audio session route changed.")
    }
}
