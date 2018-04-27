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
    
//    static var instance : MetrodronePlayer = MetrodronePlayer()
    
    static let minDurationValue: Float = 0.01
    static let maxDurationValue: Float = 0.99
    static let minBPM: Int = 30
    static let maxBPM: Int = 300
    static let maxOctave: Int = 6
    static let minOctave: Int = 2
    
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
    
    var UIDelegate: MetrodroneUIDelegate?
    
    var timerBPMAdjust: Timer!
    var durationRatio: Float = 0.5
    var currNote : String = "X"
    
    var lastUpIndex: Int = -1
    var sustain  : Bool = false
    var isMetrodronePlaying : Bool = false
    var isSustaining : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)

    var tempo: Int = 120
    var subdivisions: Int = 1
    var currOctave: Int = 4
    
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
        
        // Make sure the duration slider has the right range, and set it in the middle.
        self._sliderDuration.maximumValue = MetrodronePlayer.maxDurationValue
        self._sliderDuration.minimumValue = MetrodronePlayer.minDurationValue
        self._sliderDuration.value = 0.5 * (MetrodronePlayer.minDurationValue + MetrodronePlayer.maxDurationValue)
        
        self._playButtonImage = playButtonImage
        self._pauseButtonImage = pauseButtonImage
        
        _viewDroneFrame.setDelegate(self) // establish bi-directional relationships
        updateMetrodroneOutlets()
    }
    
    func updateMetrodroneOutlets() {
        // updates labels, sliders, etc.
        DispatchQueue.main.async {
            self._labelTempo.text = String(self.tempo)
            self._sliderDuration.value = self.durationRatio
            self._buttonSustain.isSelected = self.sustain
            self._viewDroneFrame.setSelectedNote(self.currNote)
            
            self._labelOctaveNumber.text = String(self.currOctave - MetrodronePlayer.minOctave + 1)
            
            self._buttonOctaveDown.isEnabled = true
            self._buttonOctaveUp.isEnabled = true
            
            if (self.currOctave == MetrodronePlayer.minOctave) {
                self._buttonOctaveDown.isEnabled = false
            }
            if (self.currOctave == MetrodronePlayer.maxOctave) {
                self._buttonOctaveUp.isEnabled = false
            }
        }
    }
    
    func changeDuration(newValue: Float) {
        durationRatio = newValue
        //ModacityAnalytics.LogStringEvent("Changed Metrodrone Duration", extraParamName: "duration", extraParamValue: newValue)
        
        startMetronome()
    }
    
    func toggleSustain() -> Bool {
        sustain = !sustain
        ModacityAnalytics.LogStringEvent("Toggled Sustain")
        if (!isMetrodronePlaying) {
            if (sustain) {
                updateMetrodroneNote()
                if (currNote != "X") {
                    isSustaining = true
                    metrodrone.playUntimed()
                }
            } else {
                stopMetrodrone() //
                isSustaining = false
            }
        }
        
        return sustain
    }
    
    func setSubdivision(_ divisions:Int) {
        ModacityAnalytics.LogStringEvent("Set subdivision", extraParamName: "subdivision", extraParamValue: divisions)
        
        if (self.subdivisions != divisions) {
            self.subdivisions = divisions
            
            if _imageViewSubdivisionNote != nil {
                switch self.subdivisions {
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
            
            startMetronome()
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
        
        if (bpm < MetrodronePlayer.minBPM) {
            tempo = MetrodronePlayer.minBPM
        }
        if (bpm > MetrodronePlayer.maxBPM) {
            tempo = MetrodronePlayer.maxBPM
        }
        
        
        _labelTempo.text = String(tempo)
        if (isMetrodronePlaying) {
            startMetronome()
        }
    }
    

    func updateCurrNote(_ newIndex:Int) {
        if (newIndex < 0) {
            currNote = "X"
        } else {
            currNote = _viewDroneFrame.droneLetters[newIndex]
        }
    }
    
    func toneWheelDeselectNote(noteIndex: Int) {
        // deselect the current note
        // if metrodrone is going, turn it into click only
        // if sustain is going, stop it and deselect any note
        UIDelegate?.setSelectedIndex(-1)
        currNote = "X"
        
        if (sustain) {
            metrodrone.stop()
            isSustaining = false
        }
        
        if (isMetrodronePlaying) {
            startMetronome()
        }
        
    }
    
    func toneWheelSelectNote(noteIndex: Int) {
        // select the current note
        // if metrodrone is going, make sure it starts using this note
        // start playing this note. on toneWheelUp event, stop playing (unless sustain is on)
        
        UIDelegate?.setSelectedIndex(noteIndex)
        
        
        if (isMetrodronePlaying) {
            startMetronome() // starts it playing again with correct note
        } else {
            // it's not playing so start doing untime play
            updateMetrodroneNote() // required for untimed play
            metrodrone.playUntimed(withLooping: true)
            isSustaining = true
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
        
            if (!isMetrodronePlaying && !sustain) {
                // stop playing if not in sustain or metrodrone mode
                metrodrone.stop()
                isSustaining = false
            }
  
        
//        lastUpIndex = UIDelegate!.getSelectedIndex()
    }
    
    func startMetronome() { // will restart it if already going.
        
        
       
        if (isSustaining) {
            print("Stopping met because of sustain")
            metrodrone.stop()
        }
        disableSustain()
        
        updateMetrodroneNote()
        
        metrodrone.play(bpm: Double(tempo), ratio: durationRatio, subdivision: subdivisions)
        isMetrodronePlaying = true
        setPauseImage()
        
        
    }
    
    
    func disableSustain() {
        sustain = false
        _buttonSustain.isSelected = false
        _buttonSustain.isEnabled = false
        _buttonSustain.alpha = 0.50
    }

    
    func stopMetrodrone() {
        metrodrone.stop()
        isMetrodronePlaying = false
        isSustaining = false
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
        self.currOctave -= direction
        updateMetrodroneOutlets()
        updateMetrodroneNote()
        
        if (isSustaining) {
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
        
        if let bpm = tempoDetective.addTap() {
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
        
        var fileDrone = "440-" + currNote + String(currOctave)
        if (currNote == "X") {
            fileDrone = "silence"
        }
        
        metrodrone.loadDrone(droneAudio: waveformURL(wavename: fileDrone)!)
        
    }
    
    
    func waveformURL(wavename: String) -> URL? {
        return Bundle.main.url(forResource: wavename, withExtension: "m4a", subdirectory: "_Comp")
    }
    

    
}
