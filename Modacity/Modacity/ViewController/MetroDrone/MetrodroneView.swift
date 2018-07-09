//
//  MetrodroneView.swift
//  Modacity
//
//  Created by BC Engineer on 9/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol MetrodroneViewDelegate {
    func onTapHeaderBar()
    func onSubdivision()
}

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
    
    @IBOutlet weak var imageViewMetrodroneViewShowingArrow: UIImageView!
    @IBOutlet weak var viewMinTrack: UIView!
    
    @IBOutlet weak var constraintForMinTrackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForMinTrackImageWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneBackgroundImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewMaxTrack: UIImageView!
    
    var delegate: MetrodroneViewDelegate? = nil
    var selectedSubdivisionNote: Int = -1
    var subdivisionPanelShown = false
    var metrodonePlayer : MetrodronePlayer? = nil
    
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
        self.viewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.viewContainer.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    func initializeDroneUIs() {
        self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
        prepareMetrodrone()
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((MetrodroneParameters.instance.durationRatio - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
        self.selectedSubdivisionNote = MetrodroneParameters.instance.subdivisions - 1
    }
    
    func subdivisionButtonFrame() {
        
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
    
    @IBAction func onSubdivision(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onSubdivision()
        }
    }
    
    @IBAction func onCloseDrone(_ sender:Any) {
        if let delegate = self.delegate {
            delegate.onTapHeaderBar()
        }
    }
    
    func prepareMetrodrone() {
        self.metrodonePlayer = MetrodronePlayer()
        self.metrodonePlayer!.metrodronePlayerDelegate = self
//        DispatchQueue.main.async {
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
            
            ModacityDebugger.debug("Metrodrone player prepared")
            NotificationCenter.default.post(Notification(name: AppConfig.appNotificationMetrodroneAudioEnginePrepared))
//        }
    }
    
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
    
    func viewDidDisappear() {
        if let mPlayer = self.metrodonePlayer {
            mPlayer.stopPlayer()
            mPlayer.stopMetrodrone()
            self.metrodonePlayer = nil
        }
    }
}

extension MetrodroneView: MetrodronePlayerDelegate {
    func onDurationSliderEnabled() {
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }
}
