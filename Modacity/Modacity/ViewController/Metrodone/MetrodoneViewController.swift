//
//  MetrodoneViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/24/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit


class MetrodoneViewController: UIViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var btnSustain: UIButton!

    var subdivisionPanelShown = false
    var selectedSubdivisionNote: Int = -1
    @IBOutlet weak var viewSubdivision: UIView!
    @IBOutlet weak var buttonSubdivisionNote1: UIButton!
    @IBOutlet weak var buttonSubdivisionNote2: UIButton!
    @IBOutlet weak var buttonSubdivisionNote3: UIButton!
    @IBOutlet weak var buttonSubdivisionNote4: UIButton!
    
    @IBOutlet weak var imageViewMaxTrick: UIImageView!
    @IBOutlet weak var viewMintrick: UIView!
    @IBOutlet weak var constraintForMinTrickViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForMinTrickImageWidth: NSLayoutConstraint!
    
    
    var metrodonePlayer = MetrodronePlayer.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        metrodonePlayer.initializeOutlets(lblTempo: labelTempo,
                                          droneFrame: viewDroneFrame,
                                          playButton: buttonPlay,
                                          durationSlider: sliderDuration,
                                          sustainButton: btnSustain,
                                          playButtonImage: UIImage(named:"btn_drone_play_large"),
                                          pauseButtonImage: UIImage(named:"btn_drone_pause_large"))
        self.viewSubdivision.isHidden = true
        self.configureSubdivisionNoteSelectionGUI()
        self.configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = AppOveralDataManager.manager.settingsPhoneSleepPrevent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        self.metrodonePlayer.stopPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewMintrick.layer.masksToBounds = true
        self.constraintForMinTrickImageWidth.constant = self.imageViewMaxTrick.frame.size.width
        self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
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
        
//        if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
//            self.constraintForSubdivisionButtonWidth.constant = 90
//        } else {
//            self.constraintForSubdivisionButtonWidth.constant = 112
//        }
        
//        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
//            self.constraintForDroneViewLeading.constant = 60
//            self.constraintForDroneViewTrailing.constant = 60
//        } else {
//            self.constraintForDroneViewLeading.constant = 20
//            self.constraintForDroneViewTrailing.constant = 20
//        }
    }

    @IBAction func onDurationChanged(_ sender: Any) {
        self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
        self.metrodonePlayer.changeDuration(newValue: sliderDuration.value)
    }
    
    @IBAction func onBtnPlay(_ sender: Any) {
        if (!self.metrodonePlayer.isMetrodronePlaying) {
            self.metrodonePlayer.goMetronome()
        } else {
            self.metrodonePlayer.stopMetrodrone()
        }
    }
    
    @IBAction func onTapDown(_ sender: Any) {
        self.metrodonePlayer.tapDown()
    }
    
    @IBAction func onTapTouchup(_ sender: Any) {
        self.metrodonePlayer.stopMetrodrone()
    }
    
    @IBAction func onIncreaseBPMTouch(_ sender: Any) {
        self.metrodonePlayer.increaseBPMTouch()
    }
    
    @IBAction func onSustainButton(_ sender: Any) {
        btnSustain.isSelected = self.metrodonePlayer.toggleSustain()
    }
    
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        self.metrodonePlayer.decreaseBPMTouch()
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        self.metrodonePlayer.stopBPMChangeTimer()
    }
    
    @IBAction func onSubdivision(_ sender: Any) {
        if !self.subdivisionPanelShown {
            self.viewSubdivision.isHidden = false
        } else {
            self.viewSubdivision.isHidden = true
        }
        
        self.subdivisionPanelShown = !self.subdivisionPanelShown
    }
    
    func processSubdivision() {
        if ((self.selectedSubdivisionNote < 0) || (self.selectedSubdivisionNote > 3)) {
            self.selectedSubdivisionNote = 0
        }
        self.metrodonePlayer.setSubdivision(self.selectedSubdivisionNote + 1)
    }
    
    @IBAction func onSubdivisionNotes(_ sender: UIButton) {
        if sender == self.buttonSubdivisionNote1 {
            self.selectedSubdivisionNote = 0
        } else if sender == self.buttonSubdivisionNote2 {
            self.selectedSubdivisionNote = 1
        } else if sender == self.buttonSubdivisionNote3 {
            self.selectedSubdivisionNote = 2
        } else if sender == self.buttonSubdivisionNote4 {
            self.selectedSubdivisionNote = 3
        }
        
        self.configureSubdivisionNoteSelectionGUI()
        self.processSubdivision()
    }
    
    func configureSubdivisionNoteSelectionGUI() {
        self.buttonSubdivisionNote1.alpha = 0.5
        self.buttonSubdivisionNote2.alpha = 0.5
        self.buttonSubdivisionNote3.alpha = 0.5
        self.buttonSubdivisionNote4.alpha = 0.5
        switch self.selectedSubdivisionNote {
        case 0:
            self.buttonSubdivisionNote1.alpha = 1.0
        case 1:
            self.buttonSubdivisionNote2.alpha = 1.0
        case 2:
            self.buttonSubdivisionNote3.alpha = 1.0
        case 3:
            self.buttonSubdivisionNote4.alpha = 1.0
        default:
            return
        }
    }
}
