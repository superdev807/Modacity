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
    static let minDurationValue: Float = 0.01
    static let maxDurationValue: Float = 0.99
    static let minBPM: Int = 30
    static let maxBPM: Int = 300
    
    var _viewDroneFrame: ViewDroneFrame!
    var _labelTempo: UILabel!
    var _buttonPlayPause: UIButton!
    var _sliderDuration: UISlider!
    var _buttonSustain: UIButton!
    
    var UIDelegate: MetrodroneUIDelegate?
    
    var timerBPMAdjust: Timer!
    var durationRatio: Float = 0.5
    var currNote : String = "X"
    
    var lastUpIndex: Int = -1
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
    
    var metrodrone : MetroDroneAudio = {
        let highUrl = Bundle.main.url(forResource: "monodrone_A", withExtension: "wav", subdirectory: "waveforms")!
        return MetroDroneAudio(mainClickFile: highUrl)
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMetrodronePlaying) {
            metrodrone.stop()
        }
    }
    
    func initializeOutlets(lblTempo: UILabel!, droneFrame: ViewDroneFrame!, playButton: UIButton!, durationSlider: UISlider!, sustainButton: UIButton!) {
        self._viewDroneFrame = droneFrame // maybe a better way to do this?
        self._labelTempo = lblTempo
        self._buttonPlayPause = playButton
        self._sliderDuration = durationSlider
        self._buttonSustain = sustainButton
        
        // Make sure the duration slider has the right range, and set it in the middle.
        self._sliderDuration.maximumValue = MetrodroneBaseViewController.maxDurationValue
        self._sliderDuration.minimumValue = MetrodroneBaseViewController.minDurationValue
        self._sliderDuration.value = 0.5 * (MetrodroneBaseViewController.minDurationValue + MetrodroneBaseViewController.maxDurationValue)
        
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
        if (!isMetrodronePlaying) {
            if (sustain) {
                updateMetrodroneNote()
                metrodrone.playUntimed()
            } else {
                stopMetrodrone() //
            }
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
        tempo = bpm
        
        if (bpm < MetrodroneBaseViewController.minBPM) {
            tempo = MetrodroneBaseViewController.minBPM
        }
        if (bpm > MetrodroneBaseViewController.maxBPM) {
            tempo = MetrodroneBaseViewController.maxBPM
        }
        
        
        _labelTempo.text = String(tempo)
        if (isMetrodronePlaying) {
            goMetronome()
        }
    }
    
    func selectedIndexChanged(newIndex: Int) {
        //newIndex = -1 means none selected
        //else ranges from 0 to 11
        
        updateCurrNote(newIndex)
        if ((newIndex < 0) && !isMetrodronePlaying) {
            metrodrone.stop()
        }
        //updateMetrodroneNote()
        toneWheelNoteDown()
    }
    
    func updateCurrNote(_ newIndex:Int) {
        if (newIndex < 0) {
            currNote = "X"
        } else {
            currNote = _viewDroneFrame.droneLetters[newIndex]
        }
    }
    
    func toneWheelNoteDown() {
        clickSound = isMetrodronePlaying
        
        if (UIDelegate!.getSelectedIndex() < 0) {
            //metrodrone.stop()
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
        updateMetrodroneNote()
        if (lastUpIndex == UIDelegate!.getSelectedIndex()) {
            // deselect this item
            UIDelegate?.setSelectedIndex(-1)
            currNote = "X"
            updateMetrodroneNote()
            if (isMetrodronePlaying) {
                goMetronome()
            }
            
        }
        else {
            // it's selected and we're touching up
            if (!isMetrodronePlaying && !sustain) {
                // stop playing if not in sustain or metrodrone mode
                metrodrone.stop()
            }
        }
        
        lastUpIndex = UIDelegate!.getSelectedIndex()
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
        _buttonPlayPause.setImage(UIImage(named:"btn_drone_play"), for: .normal)
    }
    
    func setPauseImage() {
        _buttonPlayPause.setImage(UIImage(named:"btn_drone_pause"), for: .normal)
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
        updateCurrNote(UIDelegate!.getSelectedIndex())
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
    
    func audioSessionOutputSetting() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error  {
            print("audio session error \(error)")
        }
    }
    
    func audioSessionInputSetting() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
        } catch let error  {
            print("audio session error \(error)")
        }
    }
    
}
