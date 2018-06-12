//
//  MetrodroneView.swift
//  Modacity
//
//  Created by BC Engineer on 9/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class MetrodroneView: UIView {
    
    @IBOutlet var viewContainer: UIView!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonMetrodronePlay: UIButton!
    @IBOutlet weak var buttonSustain: UIButton!
    
    @IBOutlet weak var labelOctave: UILabel!
    @IBOutlet weak var buttonOctaveUp: UIButton!
    
    @IBOutlet weak var buttonOctaveDown: UIButton!
    @IBOutlet weak var viewSubdivision: UIView!
    
    @IBOutlet weak var buttonSubdivisionStatusOnButton: UIImageView!
    @IBOutlet weak var buttonSubDivisionNoteOnButton: UIImageView!
    @IBOutlet weak var buttonSubDivision: UIButton!
    
    @IBOutlet weak var buttonSubdivisionNote1: UIButton!
    @IBOutlet weak var buttonSubdivisionNote2: UIButton!
    @IBOutlet weak var buttonSubdivisionNote3: UIButton!
    @IBOutlet weak var buttonSubdivisionNote4: UIButton!
    var selectedSubdivisionNote: Int = -1
    var subdivisionPanelShown = false
    
//    @IBOutlet weak var viewBottomXBar: UIView!
    
    @IBOutlet weak var imageViewMetrodroneViewShowingArrow: UIImageView!
    @IBOutlet weak var viewMinTrack: UIView!
    
    @IBOutlet weak var constraintForMinTrackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForMinTrackImageWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneBackgroundImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewMaxTrack: UIImageView!
    
    var metrodonePlayer : MetrodronePlayer? = nil
    var metrodroneViewHeight = CGFloat(336)
    let metrodroneViewMinHeight = CGFloat(0)
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("metrodroneview", owner: self, options: nil)
        addSubview(viewContainer)
        viewContainer.frame = self.bounds
        viewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func initializeDroneUIs() {
//        self.viewBottomXBar.backgroundColor = Color(hexString:"#292a4a")
//        self.constraintForMaximizedDroneBottomSpace.constant =  metrodroneViewHeight - metrodroneViewMinHeight
        self.viewSubdivision.isHidden = true
        self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
        prepareMetrodrone()
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((MetrodroneParameters.instance.durationRatio - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
        self.selectedSubdivisionNote = MetrodroneParameters.instance.subdivisions - 1
        self.configureSubdivisionNoteSelectionGUI()
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
    
    func processSubdivision() {
        // TODO : here, drone media programming for subdivisions
        // self.selectedSubdivisionNote value will be used here
        
        if ((self.selectedSubdivisionNote < 0) || (self.selectedSubdivisionNote > 3)) {
            self.selectedSubdivisionNote = 0
        }
        if let mPlayer = self.metrodonePlayer {
            mPlayer.setSubdivision(self.selectedSubdivisionNote+1)
        }
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
    
    @IBAction func onSubdivision(_ sender: Any) {
        if !self.subdivisionPanelShown {
            self.viewSubdivision.isHidden = false
        } else {
            self.viewSubdivision.isHidden = true
        }
        
        self.subdivisionPanelShown = !self.subdivisionPanelShown
    }
    
    @IBAction func onCloseDrone(_ sender:Any) {
//        self.closeDroneView()
    }
    
//    @objc func processDroneViewTap(gesture : UITapGestureRecognizer) {
//        let touchPoint = gesture.location(in: self.viewMaximizedDrone)
//
//        if !self.metrodronePlayerShown {
//            self.openDroneView()
//        } else {
//            if touchPoint.y < 50 {
//                self.closeDroneView()
//            }
//        }
//    }
    
//    @IBAction func onTabDrone(_ sender: Any) {
//        self.openDroneView()
//    }
    
//    func openDroneView() {
//
//        let distance = abs(self.constraintForMaximizedDroneBottomSpace.constant)
//        self.constraintForMaximizedDroneBottomSpace.constant = 0
//
//        UIView.animate(withDuration: TimeInterval(distance / (metrodroneViewHeight - metrodroneViewMinHeight) * CGFloat(1.0)), animations: {
//            self.view.layoutIfNeeded()
//        }) { (finished) in
//            if finished {
//                self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_down")
//                if !self.metrodronePlayerShown {
//                    self.startMetrodrone()
//                }
//            }
//        }
//    }
    
    func prepareMetrodrone() {
        self.metrodonePlayer = MetrodronePlayer()//MetrodronePlayer.instance
        self.metrodonePlayer!.metrodronePlayerDelegate = self
        DispatchQueue.main.async {
            self.metrodonePlayer!.initializeOutlets(lblTempo: self.labelTempo,
                                                    droneFrame: self.viewDroneFrame,
                                                    playButton: self.buttonMetrodronePlay,
                                                    durationSlider: self.sliderDuration,
                                                    sustainButton: self.buttonSustain,
                                                    buttonOctaveUp: self.buttonOctaveUp,
                                                    buttonOctaveDown: self.buttonOctaveDown,
                                                    labelOctaveNum: self.labelOctave,
                                                    imageViewSubdivisionCircleStatus: self.buttonSubdivisionStatusOnButton,
                                                    viewSliderMinTrack: self.viewMinTrack,
                                                    imageViewSliderMaxTrack: self.imageViewMaxTrack,
                                                    imageViewSubdivisionNote: self.buttonSubDivisionNoteOnButton)
        }
    }
    
//    func startMetrodrone() {
//        ModacityAnalytics.LogEvent(.MetrodroneDrawerOpen)
//        if self.metrodonePlayer == nil {
//            prepareMetrodrone()
//        }
//        self.metrodronePlayerShown = true
//    }
    
//    func closeDroneView() {
//
//        if self.subdivisionPanelShown {
//            self.onSubdivision(self.view)
//        }
//
//        let distance = abs(metrodroneViewHeight - metrodroneViewMinHeight - self.constraintForMaximizedDroneBottomSpace.constant)
//        self.constraintForMaximizedDroneBottomSpace.constant = metrodroneViewHeight - metrodroneViewMinHeight
//
//        UIView.animate(withDuration: TimeInterval(distance / (metrodroneViewHeight - metrodroneViewMinHeight) * CGFloat(1.0)), animations: {
//            self.view.layoutIfNeeded()
//        }) { (finished) in
//            if finished {
//                self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
//                self.endMetrodrone()
//            }
//        }
//    }
    
//    func endMetrodrone() {
//        if self.metrodronePlayerShown {
//
//            ModacityAnalytics.LogEvent(.MetrodroneDrawerClose)
//
//
//            //            if let metrodronePlayer = self.metrodonePlayer {
//            //                metrodronePlayer.stopPlayer()
//            //            }
//            self.metrodronePlayerShown = false
//        }
//    }
    
    @IBAction func onSustainButton(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            self.buttonSustain.isSelected = mPlayer.toggleSustain()
        }
    }
    
    @IBAction func onDurationChanged(_ sender: Any) {
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
        if let mPlayer = self.metrodonePlayer {
            mPlayer.changeDuration(newValue: self.sliderDuration.value)
        }
    }
    
    @IBAction func onBtnPlay(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            if (!mPlayer.isMetrodronePlaying) {
                mPlayer.startMetronome()
            } else {
                mPlayer.stopMetrodrone()
            }
        }
    }
    
    @IBAction func onTapDown(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.tapDown()
        }
    }
    
    @IBAction func onTapTouchup(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.tapUp()
        }
    }
    
    @IBAction func onOctaveUp(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.onOctaveUp()
        }
    }
    
    @IBAction func onOctaveDown(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.onOctaveDown()
        }
    }
    
    @IBAction func onIncreaseBPMTouch(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.increaseBPMTouch()
        }
    }
    
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.decreaseBPMTouch()
        }
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.stopBPMChangeTimer()
        }
    }
}

extension MetrodroneView: MetrodronePlayerDelegate {
    func onDurationSliderEnabled() {
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }
}
