//
//  MetrodroneBaseViewController.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/14/18.
//  Copyright © 2018 crossover. All rights reserved.
//


import UIKit
import AVFoundation


class MetrodroneBaseViewController: UIViewController, DroneFrameDelegate {
    
    var _viewDroneFrame: ViewDroneFrame!
    var _labelTempo: UILabel!
    var _buttonPlayPause: UIButton!
    var _sliderDuration: UISlider!
    
    var timerBPMAdjust: Timer!
    var durationRatio: Float = 0.5
    var currNote : String = "C"
    var isMetrodronePlaying : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    var clickSound : Bool = false
    var tempo: Int = 120
    
    var metrodrone : Metrodrone = {
        let highUrl = Bundle.main.url(forResource: "monodrone_A", withExtension: "wav", subdirectory: "waveforms")!
        return Metrodrone(mainClickFile: highUrl)
    }()
    
    func initializeOutlets(lblTempo: UILabel!, droneFrame: ViewDroneFrame!, playButton: UIButton!, durationSlider: UISlider!) {
        self._viewDroneFrame = droneFrame // maybe a better way to do this?
        self._labelTempo = lblTempo
        self._buttonPlayPause = playButton
        self._sliderDuration = durationSlider
        _viewDroneFrame.delegate = self
        
        updateMetrodroneOutlets()
    }
    
    func updateMetrodroneOutlets() {
        // updates labels, sliders, etc.
        _labelTempo.text = String(tempo)
        _sliderDuration.value = durationRatio
        
    }
    
    func changeDuration(newValue: Float) {
        durationRatio = newValue
        goMetronome()
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
            print("negative drone idnex")
            currNote = "C"
            return
        }
        currNote = _viewDroneFrame.droneLetters[newIndex]
        updateMetrodroneNote()
    }
    
    func toneWheelNoteDown() {
        clickSound = isMetrodronePlaying
        updateMetrodroneNote()
        if (!isMetrodronePlaying) {
            metrodrone.playUntimed()
        } else {
            goMetronome()
        }
    }
    
    func toneWheelNoteUp() {
        //updateMetrodroneNote()
        if (!isMetrodronePlaying){
            metrodrone.stop()
        }
        
    }
    
    func goMetronome() {
        var sub = 1 // segmentSubdivision.selectedSegmentIndex + 1 // start at 1= quarter, 2=eighth,etc.
        clickSound = true
        updateMetrodroneNote()
        metrodrone.play(bpm: Double(tempo), ratio: durationRatio, subdivision: sub)
        isMetrodronePlaying = true
        setPauseImage()
    }
    
    func stopMetrodrone() {
        metrodrone.stop()
        isMetrodronePlaying = false
        setPlayImage()
    }
    
    func setPlayImage() {
        _buttonPlayPause.setImage(#imageLiteral(resourceName: "btn_drone_play_large"), for: .normal)
    }
    
    func setPauseImage() {
        _buttonPlayPause.setImage(#imageLiteral(resourceName: "icon_pause_white"), for: .normal)
    }
    
    func tapDown() {
        if let bpm = tempoDetective.addTap() {
            print("bpm = \(bpm) detected")
            setNewTempo(Int(bpm))
            clickSound = true
            goMetronome()
        } else {
            stopMetrodrone()
            clickSound = false
            updateMetrodroneNote()
            metrodrone.playUntimed()
        }
    }
    
    func tapUp() {
        if (!clickSound) { // stand in for if we haven't found BPM
            stopMetrodrone()
        }
    }
    
    func updateMetrodroneNote() {
        var fileMain = "monodrone_" + currNote
        var fileSub = fileMain
        
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
