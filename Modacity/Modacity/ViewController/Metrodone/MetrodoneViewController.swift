//
//  MetrodoneViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/24/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol DroneFrameDelegate : class {
    func selectedIndexChanged(newIndex: Int)
    func toneWheelNoteDown()
    func toneWheelNoteUp()
}

class MetrodoneViewController: UIViewController, DroneFrameDelegate {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    
    var timer: Timer!
    var durationRatio: Float = 0.5
    var currNote : String = "C"
    var isPlaying : Bool = false
    var tempoDetective : DetectTapTempo = DetectTapTempo(timeOut: 1.5, minimumTaps: 3)
    var clickSound : Bool = false
    
   /* let noteNames : [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#"]
    */
    var tempo: Int = 120 { didSet {
        labelTempo.text = String(self.tempo)
        }
    }
    
    var metrodrone : Metrodrone = {
        let highUrl = Bundle.main.url(forResource: "monodrone_A", withExtension: "wav", subdirectory: "waveforms")!
        return Metrodrone(mainClickFile: highUrl)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewDroneFrame.delegate = self
        self.updateMetrodroneInfo()
        self.configureLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func updateMetrodroneInfo() {
        // updates labels, sliders, etc.
        labelTempo.text = String(tempo)
        sliderDuration.value = durationRatio
        
    }
    
    func selectedIndexChanged(newIndex: Int) {
        //newIndex = -1 means none selected
        //else ranges from 0 to 11
        if (newIndex < 0) {
            print("negative drone idnex")
            currNote = "C"
            return
        }
        currNote = viewDroneFrame.droneLetters[newIndex]
        updateMetrodroneNote()
    }
    
    func toneWheelNoteDown() {
        
        clickSound = isPlaying
        updateMetrodroneNote()
        if (!isPlaying) {
            metrodrone.playUntimed()
        } else {
            goMetronome()
        }
    }
    
    func toneWheelNoteUp() {
        //updateMetrodroneNote()
        if (!isPlaying){
            metrodrone.stop()
        } 
        
    }
    
    func configureLayout() {
        
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            self.constraintForSubdivisionButtonWidth.constant = 90
        } else {
            self.constraintForSubdivisionButtonWidth.constant = 112
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForDroneViewLeading.constant = 60
            self.constraintForDroneViewTrailing.constant = 60
        } else {
            self.constraintForDroneViewLeading.constant = 20
            self.constraintForDroneViewTrailing.constant = 20
        }
    }

    @IBAction func onDurationChanged(_ sender: Any) {
        durationRatio = sliderDuration.value
        goMetronome()
    }
    
    @IBAction func onBtnPlay(_ sender: Any) {
        if (!isPlaying) {
            goMetronome()
            buttonPlay.setImage(#imageLiteral(resourceName: "icon_pause_white"), for: .normal)
        } else {
            stopMetrodrone()
            buttonPlay.setImage(#imageLiteral(resourceName: "btn_drone_play_large"), for: .normal)
        }
    }
    
    
    @IBAction func onTapDown(_ sender: Any) {
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
    
    @IBAction func onTapTouchup(_ sender: Any) {
        stopMetrodrone()
    }
    
    @IBAction func onIncreaseBPMTouch(_ sender: Any) {
        print("touch")
        singleFire(+1)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(rapidFireUp), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        singleFire(-1)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(rapidFireDown), userInfo: nil, repeats: true)
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        timer.invalidate()
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
        goMetronome()
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
    
    func goMetronome() {
        var sub = 1 // segmentSubdivision.selectedSegmentIndex + 1 // start at 1= quarter, 2=eighth,etc.
        clickSound = true
        updateMetrodroneNote()
        metrodrone.play(bpm: Double(tempo), ratio: durationRatio, subdivision: sub)
        isPlaying = true
    }
    
    func stopMetrodrone() {
        metrodrone.stop()
        isPlaying = false
    }
    
    func waveformURL(wavename: String) -> URL? {
        return Bundle.main.url(forResource: wavename, withExtension: "wav", subdirectory: "waveforms")
    }
    
}
