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

class MetrodoneViewController: MetrodroneBaseViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    
    
   /* let noteNames : [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#"]
    */
    /* { didSet {
        labelTempo.text = String(self.tempo)
        }
    }*/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeOutlets(lblTempo: labelTempo, droneFrame: viewDroneFrame, playButton: buttonPlay, durationSlider: sliderDuration)
        
        self.configureLayout()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
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
        changeDuration(newValue: sliderDuration.value)
        
    }
    
    @IBAction func onBtnPlay(_ sender: Any) {
        if (!isMetrodronePlaying) {
            goMetronome()
        } else {
            stopMetrodrone()
        }
    }
    
    @IBAction func onTapDown(_ sender: Any) {
        tapDown()
    }
    
    @IBAction func onTapTouchup(_ sender: Any) {
        stopMetrodrone()
    }
    
    @IBAction func onIncreaseBPMTouch(_ sender: Any) {
        increaseBPMTouch()
    }
    
    
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        decreaseBPMTouch()
        
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        stopBPMChangeTimer()
    }
}
