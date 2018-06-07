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
    //func selectedIndexChanged(newIndex: Int)
    func toneWheelNoteDown(noteIndex: Int, currMode: TouchDownMode)
    func toneWheelNoteUp()
    var UIDelegate: MetrodroneUIDelegate? {get set}
}

class MetrodronePlayer: DroneFrameDelegate {
    
    static let minDurationValue: Float = 0.01
    static let maxDurationValue: Float = 0.99
    static let minBPM: Int = 30
    static let maxBPM: Int = 300
    static let maxOctave: Int = 6
    static let minOctave: Int = 2
    
    var isMetrodronePlaying : Bool = false
    
    var _viewDroneFrame: ViewDroneFrame!
    var _labelTempo: UILabel!
    var _buttonPlayPause: UIButton!
    var _sliderDuration: UISlider!
    var _buttonSustain: UIButton!
    var _playButtonImage: UIImage!
    var _pauseButtonImage: UIImage!
    var _labelOctaveNumber: UILabel!
    var _buttonOctaveDown: UIButton!
    var _buttonOctaveUp: UIButton!
    var _imageViewSubdivisionCircleStatus: UIImageView!
    var _imageViewSubdivisionNote: UIImageView!
    var _viewDurationSliderMinTrack: UIView!
    var _imageviewDurationSliderMaxTrack: UIImageView!
    
    var UIDelegate: MetrodroneUIDelegate?
    var wheelSelected: Int = -1
    
    var timerBPMAdjust: Timer!
    
    let highClick: URL = {
        return Bundle.main.url(forResource: "High", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    let lowClick: URL = {
        Bundle.main.url(forResource: "Low", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    var metrodrone : MetroDroneAudio!
    
    init() {
        metrodrone = MetroDroneAudio(mainClickFile: highClick, subClickFile: lowClick)
    }
    
    func stopPlayer() {
        
        if (self.isMetrodronePlaying) {
            stopMetrodrone()
        }
    }
    
    func initializeOutlets(lblTempo: UILabel!,
                           droneFrame: ViewDroneFrame!,
                           playButton: UIButton!,
                           durationSlider: UISlider!,
                           sustainButton: UIButton!,
                           buttonOctaveUp: UIButton!,
                           buttonOctaveDown: UIButton!,
                           labelOctaveNum: UILabel!,
                           imageViewSubdivisionCircleStatus: UIImageView!,
                           viewSliderMinTrack: UIView!,
                           imageViewSliderMaxTrack: UIImageView!,
                           imageViewSubdivisionNote: UIImageView! = nil,
                           playButtonImage: UIImage! = UIImage(named:"btn_drone_play"),
                           pauseButtonImage: UIImage! = UIImage(named:"btn_drone_pause")
                           
        ) {
        
        self._viewDroneFrame = droneFrame // maybe a better way to do this?
        self._labelTempo = lblTempo
        self._buttonPlayPause = playButton
        self._sliderDuration = durationSlider
        self._buttonSustain = sustainButton
        self._buttonOctaveUp = buttonOctaveUp
        self._buttonOctaveDown = buttonOctaveDown
        self._labelOctaveNumber = labelOctaveNum
        self._imageViewSubdivisionCircleStatus = imageViewSubdivisionCircleStatus
        self._imageViewSubdivisionNote = imageViewSubdivisionNote
        self._viewDurationSliderMinTrack = viewSliderMinTrack
        self._imageviewDurationSliderMaxTrack = imageViewSliderMaxTrack
        
        DispatchQueue.main.async {
            // Make sure the duration slider has the right range, and set it in the middle.
            self._sliderDuration.maximumValue = MetrodronePlayer.maxDurationValue
            self._sliderDuration.minimumValue = MetrodronePlayer.minDurationValue
            self._sliderDuration.value = 0.5 * (MetrodronePlayer.minDurationValue + MetrodronePlayer.maxDurationValue)
            self.updateSubdivisionIcons()
        }
        
        self._playButtonImage = playButtonImage
        self._pauseButtonImage = pauseButtonImage
        
        _viewDroneFrame.setDelegate(self) // establish bi-directional relationships
        self.disableDurationSlider()
        updateMetrodroneOutlets()
    }
    
    func updateMetrodroneOutlets() {
        // updates labels, sliders, etc.
        DispatchQueue.main.async {
            self._labelTempo.text = String(MetrodroneParameters.instance.tempo)
            self._sliderDuration.value = MetrodroneParameters.instance.durationRatio
            self._buttonSustain.isSelected = MetrodroneParameters.instance.sustain
            self._viewDroneFrame.setSelectedNote(MetrodroneParameters.instance.currNote)
            
            self._labelOctaveNumber.text = String(MetrodroneParameters.instance.currOctave - MetrodronePlayer.minOctave + 1)
            
            self._buttonOctaveDown.isEnabled = true
            self._buttonOctaveUp.isEnabled = true
            
            if (MetrodroneParameters.instance.currOctave == MetrodronePlayer.minOctave) {
                self._buttonOctaveDown.isEnabled = false
            }
            if (MetrodroneParameters.instance.currOctave == MetrodronePlayer.maxOctave) {
                self._buttonOctaveUp.isEnabled = false
            }
            
            /*
             The Duration slider should only be enabled when a note is selected, and metronome
             portion is on. Otherwise it should be disabled.
             Right now this code is commented out because of the complication of the slider graphics.
            
             if (self.currNote != "X") {
                self._sliderDuration.isEnabled = false
            } else {
                self._sliderDuration.isEnabled = true
            }
            */
        }
    }
    
    func changeDuration(newValue: Float) {
        MetrodroneParameters.instance.durationRatio = newValue
        //ModacityAnalytics.LogStringEvent("Changed Metrodrone Duration", extraParamName: "duration", extraParamValue: newValue)
        
        startMetronome()
    }
    
    func toggleSustain() -> Bool {
        MetrodroneParameters.instance.sustain = !MetrodroneParameters.instance.sustain
        ModacityAnalytics.LogStringEvent("Toggled Sustain")
        if (!isMetrodronePlaying) {
            if (MetrodroneParameters.instance.sustain) {
                updateMetrodroneNote()
                if (MetrodroneParameters.instance.currNote != "X") {
                    MetrodroneParameters.instance.isSustaining = true
                    metrodrone.playUntimed()
                }
            } else {
                stopMetrodrone() //
                MetrodroneParameters.instance.isSustaining = false
            }
        }
        
        return MetrodroneParameters.instance.sustain
    }
    
    func setSubdivision(_ divisions:Int) {
        ModacityAnalytics.LogStringEvent("Set subdivision", extraParamName: "subdivision", extraParamValue: divisions)
        
        if (MetrodroneParameters.instance.subdivisions != divisions) {
            MetrodroneParameters.instance.subdivisions = divisions
            
            updateSubdivisionIcons()
            
            if self.isMetrodronePlaying {
                startMetronome()
            }
        }
        
    }
    
    func updateSubdivisionIcons() {
        if _imageViewSubdivisionNote != nil {
            switch MetrodroneParameters.instance.subdivisions {
            case 0:
                fallthrough
            case 1:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_1")
            case 2:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_2")
            case 3:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_3")
            case 4:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_4")
            default:
                return
            }
        }
    }
    
    func stopBPMChangeTimer() {
        timerBPMAdjust.invalidate()
    }
    
    func increaseBPMTouch() {
        singleFire(+1)
        if (timerBPMAdjust != nil) {
            timerBPMAdjust.invalidate()
        }
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireUp), userInfo: nil, repeats: true)
    }
    
    
    func decreaseBPMTouch() {
        singleFire(-1)
        if (timerBPMAdjust != nil) {
            timerBPMAdjust.invalidate()
        }
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireDown), userInfo: nil, repeats: true)
    }
    
    func singleFire(_ change: Int) {
        setNewTempo(MetrodroneParameters.instance.tempo + change)
    }
    
    @objc func rapidFireDown() {
        singleFire(-10)
    }
    
 
    
    @objc func rapidFireUp() {
        singleFire(+10)
    }
    
    func setNewTempo(_ bpm: Int) {
        MetrodroneParameters.instance.tempo = bpm
        
        if (bpm < MetrodronePlayer.minBPM) {
            MetrodroneParameters.instance.tempo = MetrodronePlayer.minBPM
        }
        if (bpm > MetrodronePlayer.maxBPM) {
            MetrodroneParameters.instance.tempo = MetrodronePlayer.maxBPM
        }
        
        
        _labelTempo.text = String(MetrodroneParameters.instance.tempo)
        if (isMetrodronePlaying) {
            startMetronome()
        }
    }
    

    func updateCurrNote(_ newIndex:Int) {
        if (newIndex < 0) {
            MetrodroneParameters.instance.currNote = "X"
        } else {
            MetrodroneParameters.instance.currNote = _viewDroneFrame.droneLetters[newIndex]
        }
        updateMetrodroneOutlets()
    }
    
    func toneWheelDeselectNote(noteIndex: Int) {
        // deselect the current note
        // if metrodrone is going, turn it into click only
        // if sustain is going, stop it and deselect any note
        UIDelegate?.setSelectedIndex(-1)
        wheelSelected = -1
        MetrodroneParameters.instance.currNote = "X"
        self.disableDurationSlider()
        
        if (isMetrodronePlaying) {
            startMetronome()
        }
        
        if (MetrodroneParameters.instance.isSustaining) {
            metrodrone.stop()
            MetrodroneParameters.instance.isSustaining = false
        }
        
        
    }
    
    func toneWheelSelectNote(noteIndex: Int) {
        // select the current note
        // if metrodrone is going, make sure it starts using this note
        // start playing this note. on toneWheelUp event, stop playing (unless sustain is on)
        
        UIDelegate?.setSelectedIndex(noteIndex)
        wheelSelected = noteIndex
        self.enableDurationSlider()
        
        if (isMetrodronePlaying) {
            startMetronome() // starts it playing again with correct note
        } else {
            // it's not playing so start doing untime play
            updateMetrodroneNote() // required for untimed play
            metrodrone.playUntimed(withLooping: true)
            MetrodroneParameters.instance.isSustaining = true
        }
    }
    
    func enableDurationSlider() {
        print("Enable duration slider")
        DispatchQueue.main.async {
            self._viewDurationSliderMinTrack.alpha = 1
            self._imageviewDurationSliderMaxTrack.alpha = 1
            self._sliderDuration.isEnabled = true
        }
    }
    
    func disableDurationSlider() {
        print("Disable duration slider")
        DispatchQueue.main.async {
            self._viewDurationSliderMinTrack.alpha = 0
            self._imageviewDurationSliderMaxTrack.alpha = 0.5
            self._sliderDuration.isEnabled = false
        }
    }
    
    func toneWheelNoteDown(noteIndex: Int, currMode: TouchDownMode) {
        print("Tone wheel down at \(noteIndex) with mode \(currMode)")
        if (currMode == .Select) {
            toneWheelSelectNote(noteIndex: noteIndex)
        } else {
            toneWheelDeselectNote(noteIndex: noteIndex)
        }
    }
    
    func toneWheelNoteUp() {
        // only triggered when we were in "select mode", meaning:
        // we were selecting (playing) a note
        // if the metronome is going, don't worry, keep that note selected (no need to do anything)
        // if the metronome isn't going, check if sustain is off - if so, stop playing the current untimed drone
        // if sustain is on, also no need to do anything.
        
            if (!isMetrodronePlaying && !MetrodroneParameters.instance.sustain) {
                // stop playing if not in sustain or metrodrone mode
                metrodrone.stop()
                MetrodroneParameters.instance.isSustaining = false
            }
  
        
//        lastUpIndex = UIDelegate!.getSelectedIndex()
    }
    
    func startMetronome() { // will restart it if already going.
        if (MetrodroneParameters.instance.isSustaining) {
            print("Stopping met because of sustain")
            metrodrone.stop()
        }
        disableSustain()
        
        updateMetrodroneNote()
        
        metrodrone.play(bpm: Double(MetrodroneParameters.instance.tempo), ratio: MetrodroneParameters.instance.durationRatio, subdivision: MetrodroneParameters.instance.subdivisions)
        isMetrodronePlaying = true
        setPauseImage()
        
        
    }
    
    
    func disableSustain() {
        MetrodroneParameters.instance.sustain = false
        MetrodroneParameters.instance.isSustaining = false // must be so!
        _buttonSustain.isSelected = false
        _buttonSustain.isEnabled = false
        _buttonSustain.alpha = 0.50
    }

    
    func stopMetrodrone() {
        metrodrone.stop()
        isMetrodronePlaying = false
        MetrodroneParameters.instance.isSustaining = false
        setPlayImage()
        _buttonSustain.isEnabled = true
        _buttonSustain.alpha = 1
    }
    
    func setPlayImage() {
        DispatchQueue.main.async {
            self._buttonPlayPause.setImage(self._playButtonImage, for: .normal)
            if self._imageViewSubdivisionCircleStatus != nil {
                self._imageViewSubdivisionCircleStatus.image = UIImage(named:"subdiv_circle_gray")
            }
        }
    }
    
    func setPauseImage() {
        DispatchQueue.main.async {
            self._buttonPlayPause.setImage(self._pauseButtonImage, for: .normal)
            if self._imageViewSubdivisionCircleStatus != nil {
                self._imageViewSubdivisionCircleStatus.image = UIImage(named:"subdiv_circle_active")
            }
        }
    }
    
    
    func changeOctave(direction: Int) {
        MetrodroneParameters.instance.currOctave -= direction
        updateMetrodroneOutlets()
        updateMetrodroneNote()
        
        if (MetrodroneParameters.instance.isSustaining) {
            metrodrone.playUntimed()
        }
        if (isMetrodronePlaying) {
            startMetronome()
        }
    }
    
    func onOctaveDown() {
        changeOctave(direction: 1)
    }
    
    func onOctaveUp() {
        changeOctave(direction: -1)
    }
    
    func tapDown() {
        
        stopMetrodrone()
        updateMetrodroneNote()
        metrodrone.playClick()
        
        if let bpm = MetrodroneParameters.instance.tempoDetective.addTap() {
            // if BPM is detected (after ~3 taps)
            print("bpm = \(bpm) detected")
            setNewTempo(Int(bpm))

            startMetronome()
        }
        
    }
    
    func tapUp() {
        
    }
    
    func updateMetrodroneNote() {
        updateCurrNote(UIDelegate!.getSelectedIndex())
        
        var fileDrone = "440-" + MetrodroneParameters.instance.currNote + String(MetrodroneParameters.instance.currOctave)
        if (MetrodroneParameters.instance.currNote == "X") {
            fileDrone = "silence"
        }
        
        metrodrone.loadDrone(droneAudio: waveformURL(wavename: fileDrone)!)
        
    }
    
    func waveformURL(wavename: String) -> URL? {
        return Bundle.main.url(forResource: wavename, withExtension: "m4a", subdirectory: "_Comp")
    }
    

    
}
