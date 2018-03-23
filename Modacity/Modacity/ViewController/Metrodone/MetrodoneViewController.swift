//
//  MetrodoneViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/24/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit


class MetrodoneViewController: MetrodroneBaseViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var btnSustain: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initializeOutlets(lblTempo: labelTempo, droneFrame: viewDroneFrame, playButton: buttonPlay, durationSlider: sliderDuration, sustainButton: btnSustain)
        
        self.configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
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
    
    @IBAction func onSustainButton(_ sender: Any) {
        let isOn = toggleSustain()
        btnSustain.alpha = (isOn) ? 1.0 : 0.50
    }
    
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        decreaseBPMTouch()
        
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        stopBPMChangeTimer()
    }
    
    override func setPlayImage() {
        _buttonPlayPause.setImage(UIImage(named:"btn_drone_play_large"), for: .normal)
    }
    
    override func setPauseImage() {
        _buttonPlayPause.setImage(UIImage(named:"btn_drone_pause_large"), for: .normal)
    }
}
