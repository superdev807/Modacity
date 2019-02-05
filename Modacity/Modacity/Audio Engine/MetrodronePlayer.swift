//
//  MetrodroneBaseViewController.swift
//  Modacity
//
//  Created by Marc Gelfo on 3/14/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//


import UIKit
import AVFoundation

protocol DroneFrameDelegate : class {
    //func selectedIndexChanged(newIndex: Int)
    func toneWheelNoteDown(noteIndex: Int, currMode: TouchDownMode)
    func toneWheelNoteUp()
    var UIDelegate: MetrodroneUIDelegate? {get set}
}

protocol MetrodronePlayerDelegate {
    func onDurationSliderEnabled()
}

class MetrodronePlayer: DroneFrameDelegate {
    
    static let minDurationValue: Float = 0.01
    static let maxDurationValue: Float = 0.99
    static let minBPM: Int = 10
    static let maxBPM: Int = 300
    static let maxOctave: Int = 6
    static let minOctave: Int = 0
    
    var isMetrodronePlaying : Bool = false
    var bpmRapidSpeed: Bool = false
    
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
    var metrodronePlayerDelegate: MetrodronePlayerDelegate? = nil
    
    var timerBPMAdjust: Timer!
    
    let highClick: URL = {
        return Bundle.main.url(forResource: "High", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    let lowClick: URL = {
        Bundle.main.url(forResource: "Low", withExtension: "wav", subdirectory: "waveforms")!
    }()
    
    var metrodrone : MetroDroneAudio!
    
    init() {
        self.metrodrone = MetroDroneAudio(mainClickFile: highClick, subClickFile: lowClick)
    }

    func waveformURL(wavename: String) -> URL? {
        return Bundle.main.url(forResource: wavename, withExtension: "m4a", subdirectory: "_Comp")
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
        
        self._playButtonImage = playButtonImage
        self._pauseButtonImage = pauseButtonImage
        
        _viewDroneFrame.setDelegate(self) // establish bi-directional relationships
        self.processDurationSliderEnabledStatus()
        
        DispatchQueue.main.async {
            // Make sure the duration slider has the right range, and set it in the middle.
            self._sliderDuration.setThumbImage(UIImage(named: "img_slider_thumb_normal"), for: .normal)
            self._sliderDuration.setThumbImage(UIImage(named: "img_slider_thumb_normal"), for: .highlighted)
            self._sliderDuration.maximumValue = MetrodronePlayer.maxDurationValue
            self._sliderDuration.minimumValue = MetrodronePlayer.minDurationValue
            self._sliderDuration.value = MetrodroneParameters.instance.durationRatio * (MetrodronePlayer.minDurationValue + MetrodronePlayer.maxDurationValue)
            self.updateSubdivisionIcons()
            self.updateMetrodroneOutlets()
        }
    }
    
    func updateMetrodroneOutlets() {
        // updates labels, sliders, etc.
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
    }
    
    func changeDuration(newValue: Float) {
        MetrodroneParameters.instance.durationRatio = newValue
        //ModacityAnalytics.LogStringEvent("Changed Metrodrone Duration", extraParamName: "duration", extraParamValue: newValue)
        updateMetroClick()
    }
    
    func toggleSustain() -> Bool {
        let isOn = !MetrodroneParameters.instance.sustain
        MetrodroneParameters.instance.sustain = isOn
        
        ModacityAnalytics.LogStringEvent("Toggled Sustain")
        
        updateAllMetrodrone()
        return MetrodroneParameters.instance.sustain
    }
    
    func setSubdivision(_ divisions:Int) {
        ModacityAnalytics.LogStringEvent("Set subdivision", extraParamName: "subdivision", extraParamValue: divisions)
        
        if (MetrodroneParameters.instance.subdivisions != divisions) {
            MetrodroneParameters.instance.subdivisions = divisions
            
            updateSubdivisionIcons()
            updateMetroClick()
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
            case 5:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_5")
            case 7:
                _imageViewSubdivisionNote.image = UIImage(named:"icon_note_7")
            default:
                return
            }
        }
    }
    
    func stopBPMChangeTimer() {
        timerBPMAdjust.invalidate()
    }
    
    func increaseBPMTouchUp() {
        if (!self.bpmRapidSpeed) {
            singleFire(+1)
        }
        
    }
    func decreaseBPMTouchUp() {
        if (!self.bpmRapidSpeed) {
            singleFire(-1)
        }
    }
    
    func increaseBPMTouchDown() {
        self.bpmRapidSpeed = false
        
        if (timerBPMAdjust != nil) {
            timerBPMAdjust.invalidate()
        }
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireUp), userInfo: nil, repeats: true)
    }
    
    
    func decreaseBPMTouchDown() {
        self.bpmRapidSpeed = false
        
        if (timerBPMAdjust != nil) {
            timerBPMAdjust.invalidate()
        }
        timerBPMAdjust = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireDown), userInfo: nil, repeats: true)
    }
    
    func singleFire(_ change: Int) {
        setNewTempo(MetrodroneParameters.instance.tempo + change)
    }
    
    @objc func rapidFireDown() {
        self.bpmRapidSpeed = true
        singleFire(-10)
    }
    
    @objc func rapidFireUp() {
        self.bpmRapidSpeed = true
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
        
        updateMetroClick()
    }
    
    func processDurationSliderEnabledStatus() {
        if (MetrodroneParameters.instance.currNote != "X"
            && isMetrodronePlaying
                && !MetrodroneParameters.instance.sustain) {
            self.enableDurationSlider()
        } else {
            self.disableDurationSlider()
        }
    }
    
    func enableDurationSlider() {
        DispatchQueue.main.async {
            self._viewDurationSliderMinTrack.alpha = 1
            self._imageviewDurationSliderMaxTrack.alpha = 1
            self._sliderDuration.isUserInteractionEnabled = true
            self._sliderDuration.setThumbImage(UIImage(named:"img_slider_thumb_normal"), for: .normal)
            self._sliderDuration.setThumbImage(UIImage(named:"img_slider_thumb_normal"), for: .highlighted)
            if let delegate = self.metrodronePlayerDelegate {
                delegate.onDurationSliderEnabled()
            }
        }
    }
    
    func disableDurationSlider() {
        DispatchQueue.main.async {
            self._viewDurationSliderMinTrack.alpha = 0
            self._imageviewDurationSliderMaxTrack.alpha = 0.5
            self._sliderDuration.isUserInteractionEnabled = false
            self._sliderDuration.setThumbImage(UIImage(named:"img_slider_thumb_disabled"), for: .normal)
        }
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
        updateAllMetrodrone()
    }
    
    func onOctaveDown() {
        changeOctave(direction: 1)
    }
    
    func onOctaveUp() {
        changeOctave(direction: -1)
    }
    
    func updateCurrNote(_ newIndex:Int) {
        if (newIndex < 0) {
            MetrodroneParameters.instance.currNote = "X"
        } else {
            MetrodroneParameters.instance.currNote = _viewDroneFrame.droneLetters[newIndex]
        }

        updateMetrodroneOutlets()
    }
    
    func tapDown() {
        updateMetrodroneNote()
        
        if let bpm = MetrodroneParameters.instance.tempoDetective.addTap() {
            // if BPM is detected (after ~3 taps)
            ModacityDebugger.debug("bpm = \(bpm) detected")
            self.setNewTempo(Int(bpm))
            self.stopMetroClick()
            self.playMetroClick()
        } else {
            stopMetroClick()
            metrodrone.playSingleClick()
        }
    }
    
    func tapUp() {
        
    }
    
    func toneWheelNoteDown(noteIndex: Int, currMode: TouchDownMode) {
        //ModacityDebugger.debug("Tone wheel down at \(noteIndex) with mode \(currMode)")
        if (currMode == .Select) {
            toneWheelSelectNote(noteIndex: noteIndex)
        } else {
            toneWheelDeselectNote(noteIndex: noteIndex)
        }
    }
    
    func toneWheelNoteUp() {

        if (!MetrodroneParameters.instance.sustain) {
            metrodrone.stopInfiniteDrone()
        }
        if (isMetrodronePlaying) {
            self.playMetroClick()
        }
    }
    

    func toneWheelDeselectNote(noteIndex: Int) {
        // deselect the current note
        // if metrodrone is going, turn it into click only
        // if sustain is going, stop it and deselect any note
        UIDelegate?.setSelectedIndex(-1)
        wheelSelected = -1
        MetrodroneParameters.instance.currNote = "X"
        self.processDurationSliderEnabledStatus()
        
        updateAllMetrodrone()
    }
    
    func toneWheelSelectNote(noteIndex: Int) {
        // select the current note
        // if metrodrone is going, make sure it starts using this note
        // start playing this note. on toneWheelUp event, stop playing (unless sustain is on)
        
        UIDelegate?.setSelectedIndex(noteIndex)

        updateCurrNote(noteIndex)

        updateAllMetrodrone()
        if ((!MetrodroneParameters.instance.sustain) && (!isMetrodronePlaying)) {
            self.metrodrone.playInfiniteDrone()
        }
        
        
        self.processDurationSliderEnabledStatus()
    }

    
    func updateAllMetrodrone() {
        updateMetrodroneNote()
        updateDroneSustain()
        updateMetroClick()
    }
    
    func updateDroneSustain() {
        if (MetrodroneParameters.instance.sustain && MetrodroneParameters.instance.isNoteSelected()) {
            metrodrone.playInfiniteDrone()
        } else {
            metrodrone.stopInfiniteDrone()
        }
    }
    
    func toggleMetroClickPlay() {
        if (self.isMetrodronePlaying) {
            self.stopMetroClick()
        } else {
            self.playMetroClick()
        }
    }
    
    func updateMetroClick() {
        if self.isMetrodronePlaying {
            playMetroClick()
        }
    }
    
    func updateMetrodroneNote() {
        updateCurrNote(UIDelegate!.getSelectedIndex())
    }
    
    func playMetroClick() {
        let includeDrone: Bool = (
            (!MetrodroneParameters.instance.sustain) &&
                (!metrodrone.isDroning) &&
                (MetrodroneParameters.instance.isNoteSelected()))
        
        metrodrone.playPulsing(bpm: Double(MetrodroneParameters.instance.tempo), includeDrone: includeDrone, ratio: MetrodroneParameters.instance.durationRatio, subdivision: MetrodroneParameters.instance.subdivisions)
        isMetrodronePlaying = true
    
        self.processDurationSliderEnabledStatus()
        setPauseImage()
        
    }
    
    func stopMetroClick() {
        metrodrone.stopPulsing()
        isMetrodronePlaying = false
        self.processDurationSliderEnabledStatus()
        setPlayImage()
    }
    
    func stopSustainDrone() {
        metrodrone.stopInfiniteDrone()
        MetrodroneParameters.instance.sustain = false
        self._buttonSustain.isSelected = false
    }
    
    func stopPlayer() {
        
        self.stopMetroClick()
        if (metrodrone.isDroning && MetrodroneParameters.instance.sustain) {
            self.stopSustainDrone()
        }
    }
}
