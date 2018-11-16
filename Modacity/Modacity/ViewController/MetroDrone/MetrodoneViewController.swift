//
//  MetrodoneViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/24/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit


class MetrodoneViewController: ModacityParentViewController {
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintForSubdivisionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintForDroneViewTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var btnSustain: UIButton!
    @IBOutlet weak var labelOctave: UILabel!
    @IBOutlet weak var buttonOctaveDown: UIButton!
    
    @IBOutlet weak var buttonOctaveUp: UIButton!
    
    @IBOutlet weak var imageViewMaxTrick: UIImageView!
    @IBOutlet weak var viewMintrick: UIView!
    @IBOutlet weak var constraintForMinTrickViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForMinTrickImageWidth: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewNoteStatusOnButton: UIImageView!
    @IBOutlet weak var imageViewNoteOnButton: UIImageView!
    
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    @IBOutlet weak var constraintDronframeTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintDroneFrameBottomSpace: NSLayoutConstraint!
    
    var selectedSubdivisionNote: Int = -1
    
    @IBOutlet weak var btnShowSubdivision: UIButton!
    var subdivisionView: SubdivisionSelectView? = nil
    
    var metrodronePlayer: MetrodronePlayer? = nil// MetrodronePlayer()//MetrodronePlayer.instance
    
    var premiumLockView: PremiumUpgradeLockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ModacityAnalytics.LogStringEvent("Loaded Standalone Metrodrone")
        self.prepareMetrodronePlayer()
        self.configureLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(processRouteChange), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processAudioEngineRefresh), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumUpgradeLockView), name: AppConfig.NotificationNames.appNotificationPremiumStatusChanged, object: nil)
        self.updatePremiumUpgradeLockView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if self.metrodronePlayer != nil {
            self.metrodronePlayer!.stopPlayer()
            self.metrodronePlayer = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = AppOveralDataManager.manager.settingsPhoneSleepPrevent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (self.metrodronePlayer != nil) {
            self.metrodronePlayer!.stopPlayer()
        }
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @objc func processAudioEngineRefresh() {
        ModacityDebugger.debug("application did enter foreground!")
        if self.metrodronePlayer != nil {
            self.metrodronePlayer!.stopPlayer()
            self.metrodronePlayer = nil
        }
        self.prepareMetrodronePlayer()
    }
    
    @objc func processRouteChange() {
        ModacityDebugger.debug("Audio route changed!")
        if self.metrodronePlayer != nil {
            self.metrodronePlayer!.stopPlayer()
            self.metrodronePlayer = nil
        }
        self.prepareMetrodronePlayer()
    }
    
    func prepareMetrodronePlayer() {
        self.metrodronePlayer = MetrodronePlayer()
        self.metrodronePlayer!.initializeOutlets(lblTempo: labelTempo,
                                          droneFrame: viewDroneFrame,
                                          playButton: buttonPlay,
                                          durationSlider: sliderDuration,
                                          sustainButton: btnSustain,
                                          buttonOctaveUp: buttonOctaveUp,
                                          buttonOctaveDown: buttonOctaveDown,
                                          labelOctaveNum: labelOctave,
                                          imageViewSubdivisionCircleStatus: imageViewNoteStatusOnButton,
                                          viewSliderMinTrack: self.viewMintrick,
                                          imageViewSliderMaxTrack: self.imageViewMaxTrick,
                                          imageViewSubdivisionNote: imageViewNoteOnButton,
                                          playButtonImage: UIImage(named:"btn_drone_play_large"),
                                          pauseButtonImage: UIImage(named:"btn_drone_pause_large"))
        self.metrodronePlayer!.metrodronePlayerDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewMintrick.layer.masksToBounds = true
        self.constraintForMinTrickImageWidth.constant = self.imageViewMaxTrick.frame.size.width
        self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }

    @IBAction func onMenu(_ sender: Any) {
        ModacityAnalytics.LogEvent(.SideMenu)
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func configureLayout() {
        
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphonexR_xSMax {
            self.constraintDronframeTopSpace.constant = 50
            self.constraintDroneFrameBottomSpace.constant = 50
        }
        
        self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((MetrodroneParameters.instance.durationRatio - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }

    @IBAction func onDurationChanged(_ sender: Any) {
        if let player = self.metrodronePlayer {
            self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
            player.changeDuration(newValue: sliderDuration.value)
        }
    }
    
    @IBAction func onBtnPlay(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.toggleMetroClickPlay()
        }
            /*if (!player.isMetrodronePlaying) {
                player.startMetronome()
            } else {
                player.stopMetrodrone()
            }*/
        
    }
    
    @IBAction func onTapDown(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.tapDown()
        }
    }
    
    @IBAction func onTapTouchup(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.tapUp()
        }
    }

    @IBAction func onButtonOctaveDown(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.onOctaveDown()
        }
    }
    
    @IBAction func onButtonOctaveUp(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.onOctaveUp()
        }
    }
    
    @IBAction func onSustainButton(_ sender: Any) {
        if let player = self.metrodronePlayer {
            btnSustain.isSelected = player.toggleSustain()
        }
    }
    
    @IBAction func onIncreaseBPMTouchUp(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.increaseBPMTouchUp()
        }
    }
    @IBAction func onDecreaseBPMTouchUp(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.decreaseBPMTouchUp()
        }
    }
    @IBAction func onDecreaseBPMTouch(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.decreaseBPMTouchDown()
        }
    }
    
    @IBAction func onIncreaseBPMTouch(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.increaseBPMTouchDown()
        }
    }
    
    @IBAction func onChangeBPMStop(_ sender: Any) {
        if let player = self.metrodronePlayer {
            player.stopBPMChangeTimer()
        }
    }
    
    @IBAction func onSubdivision(_ sender: Any) {
        self.showSubdivision()
    }

    func showSubdivision() {
        if self.subdivisionView == nil {
            self.subdivisionView = SubdivisionSelectView()
            self.subdivisionView!.delegate = self
            self.view.addSubview(self.subdivisionView!)
            let frame = self.view.convert(self.btnShowSubdivision.frame, from: self.btnShowSubdivision.superview)
            self.subdivisionView!.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: frame.origin.y).isActive = true
            self.subdivisionView!.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: frame.origin.x + frame.size.width / 2).isActive = true
            self.subdivisionView!.isHidden = true
        }
        
        if let subdivisionView = self.subdivisionView {
            subdivisionView.isHidden = !subdivisionView.isHidden
        }
    }
}

extension MetrodoneViewController: SubdivisionSelectViewDelegate {
    func subdivisionSelectionChanged(idx: Int) {
        let subdivision = idx + 1
        if let player = self.metrodronePlayer {
            if (MetrodroneParameters.instance.subdivisions == subdivision) {
                self.showSubdivision()
            } else {
                player.setSubdivision(subdivision)
            }
        }
    }
}

extension MetrodoneViewController: MetrodronePlayerDelegate, PremiumUpgradeLockViewDelegate {
    
    func onDurationSliderEnabled() {
        self.constraintForMinTrickViewWidth.constant = self.imageViewMaxTrick.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }
    
    func attachLockView() {
        if self.premiumLockView == nil {
            self.premiumLockView = PremiumUpgradeLockView()
            self.view.addSubview(self.premiumLockView)
            self.premiumLockView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.premiumLockView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.premiumLockView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.premiumLockView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
            self.premiumLockView.delegate = self
            self.view.bringSubview(toFront: self.premiumLockView)
        }
        
        self.premiumLockView.configureForMetrodrone()
    }
    
    func detachLockView() {
        if self.premiumLockView != nil {
            self.premiumLockView.removeFromSuperview()
            self.premiumLockView = nil
        }
    }
    
    func onFindOutMore() {
        let controller = UIStoryboard(name: "premium", bundle: nil).instantiateViewController(withIdentifier: "PremiumUpgradeScene")
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func updatePremiumUpgradeLockView() {
        if !PremiumDataManager.manager.isPremiumUnlocked() {
            self.attachLockView()
        } else {
            self.detachLockView()
        }
    }
    
}
