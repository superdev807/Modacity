//
//  MetrodroneBaseViewController.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/14/18.
//  Copyright © 2018 crossover. All rights reserved.
//


import UIKit
import AVFoundation

protocol DroneFrameDelegate : class {
    func selectedIndexChanged(newIndex: Int)
    func toneWheelNoteDown()
    func toneWheelNoteUp()
    var UIDelegate: MetrodroneUIDelegate? {get set}
}


class MetrodroneBaseViewController: UIViewController, DroneFrameDelegate {
    
    var _viewDroneFrame: ViewDroneFrame!
    var _labelTempo: UILabel!
    var _buttonPlayPause: UIButton!
    var _sliderDuration: UISlider!
    var _buttonSustain: UIButton!
    
    var UIDelegate: MetrodroneUIDelegate?
    
    var timerBPMAdjust: Timer!
    var durationRatio: Float = 0.5
    var currNote : String = "X"
    
    var sustain  : Bool = false
    var isMetrodronePlaying : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    var clickSound : Bool = false
    var tempo: Int = 120
    var subdivisions: Int = 1
    
    let highClick: URL = {
     return Bundle.main.url(forResource: "High", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    let lowClick: URL = {
        Bundle.main.url(forResource: "Low", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    var metrodrone : Metrodrone = {
        let highUrl = Bundle.main.url(forResource: "monodrone_A", withExtension: "wav", subdirectory: "waveforms")!
        return Metrodrone(mainClickFile: highUrl)
    }()
    
    func initializeOutlets(lblTempo: UILabel!, droneFrame: ViewDroneFrame!, playButton: UIButton!, durationSlider: UISlider!, sustainButton: UIButton!) {
        self._viewDroneFrame = droneFrame // maybe a better way to do this?
        self._labelTempo = lblTempo
        self._buttonPlayPause = playButton
        self._sliderDuration = durationSlider
        self._buttonSustain = sustainButton
        
        _viewDroneFrame.setDelegate(self) // establish bi-directional relationships
        updateMetrodroneOutlets()
    }
    
    func updateMetrodroneOutlets() {
        // updates labels, sliders, etc.
        _labelTempo.text = String(tempo)
        _sliderDuration.value = durationRatio
        _buttonSustain.alpha = (sustain) ? 1.0 : 0.5
    }
    
    func changeDuration(newValue: Float) {
        durationRatio = newValue
        goMetronome()
    }
    
    func toggleSustain() -> Bool {
        sustain = !sustain
        if (!sustain && !isMetrodronePlaying) {
            stopMetrodrone()
        }
        return sustain
    }
    
    func setSubdivision(_ divisions:Int) {
        if (self.subdivisions != divisions) {
            self.subdivisions = divisions
            goMetronome()
        }
        
    }
    
    func stopBPMChangeTimer() {
        timerBPMAdjust.invalidate()
    }
    
    func increaseBPMTouch() {
        singleFire(+1)
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireUp), userInfo: nil, repeats: true)
    }
    
    
    func decreaseBPMTouch() {
        singleFire(-1)
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireDown), userInfo: nil, repeats: true)
    }
    
    func singleFire(_ change: Int) {
        setNewTempo(self.tempo + change)
    }
    
    @objc func rapidFireDown() {
        singleFire(-10)
    }
    
    @objc func rapidFireUp() {
        singleFire(+10)
    }
    
    func setNewTempo(_ bpm: Int) {
        stopMetrodrone()
        tempo = bpm
        _labelTempo.text = String(tempo)
        goMetronome()
    }
    
    func selectedIndexChanged(newIndex: Int) {
        //newIndex = -1 means none selected
        //else ranges from 0 to 11

        
        if (newIndex < 0) {
            currNote = "X"
        } else {
            currNote = _viewDroneFrame.droneLetters[newIndex]
        }
        //updateMetrodroneNote()
        toneWheelNoteDown()
    }
    
    func toneWheelNoteDown() {
        clickSound = isMetrodronePlaying
        
        if (UIDelegate!.getSelectedIndex() < 0) {
            metrodrone.stop()
            return
        }
        
        updateMetrodroneNote()
        if (!isMetrodronePlaying) {
            metrodrone.playUntimed()
        } else {
            goMetronome()
        }
    }
    
    func toneWheelNoteUp() {
        //updateMetrodroneNote()
        if (!isMetrodronePlaying && !sustain) {
            metrodrone.stop()
            UIDelegate?.setSelectedIndex(-1)
        }
        
    }
    
    func goMetronome() {
        clickSound = true
        updateMetrodroneNote()
        metrodrone.play(bpm: Double(tempo), ratio: durationRatio, subdivision: subdivisions)
        isMetrodronePlaying = true
        setPauseImage()
        _buttonSustain.isEnabled = false
        _buttonSustain.alpha = 0.50
    }
    
    func stopMetrodrone() {
        metrodrone.stop()
        isMetrodronePlaying = false
        setPlayImage()
        _buttonSustain.isEnabled = true
    }
    
    func setPlayImage() {
        _buttonPlayPause.setImage(#imageLiteral(resourceName: "btn_drone_play_large"), for: .normal)
    }
    
    func setPauseImage() {
        _buttonPlayPause.setImage(#imageLiteral(resourceName: "icon_pause_white"), for: .normal)
    }
    
    func tapDown() {
        if let bpm = tempoDetective.addTap() {
            // if BPM is detected (after ~3 taps)
            print("bpm = \(bpm) detected")
            setNewTempo(Int(bpm))
            clickSound = true
            goMetronome()
        } else {
            // if we are still pre-detection
            stopMetrodrone()
            clickSound = false
            updateMetrodroneNote()
            metrodrone.playUntimed()
        }
    }
    
    func tapUp() {
        if (!clickSound) { // if we haven't found BPM, clickSound will be false
            stopMetrodrone()
        }
    }
    
    func updateMetrodroneNote() {
        var fileMain = "monodrone_" + currNote
        var fileSub = fileMain
        
        if (currNote == "X") {
            // no tone
            metrodrone.loadDrone(droneMain: highClick,
                                 droneSub: lowClick)
            return
        }
        
        if (clickSound) {
            fileMain = "high-" + fileMain
            fileSub = "low-" + fileSub
        }
        
        
        metrodrone.loadDrone(droneMain: waveformURL(wavename: fileMain)!,
                             droneSub: waveformURL(wavename: fileSub)!)
        
    }
    
    
    func waveformURL(wavename: String) -> URL? {
        return Bundle.main.url(forResource: wavename, withExtension: "wav", subdirectory: "waveforms")
    }
    
    
    
}
