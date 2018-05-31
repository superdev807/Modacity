//
//  ImprovementViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import AVFoundation
import SCSiriWaveformView
import FDWaveformView

class ImprovementViewController: UIViewController {
    
    var playlistViewModel: PlaylistDetailsViewModel!
    var practiceItem: PracticeItem!
    var viewModel: ImprovementViewModel!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var imageViewHeader: UIImageView!
    @IBOutlet weak var labelHypothesis: UILabel!
    @IBOutlet weak var labelSuggestion: UILabel!
    @IBOutlet weak var labelImprovementNote: UILabel!
    
    var recorder: AVAudioRecorder!
    var isRecording = false
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var viewSiriWaveFormView: SCSiriWaveformView!
    
    var player: AVAudioPlayer?
    var audioPlayerTimer: Timer?
    var isPlaying = false
    var currentRate = 1.0
    @IBOutlet weak var waveformAudioPlay: FDWaveformView!
    @IBOutlet weak var viewAudioPlayer: UIView!
    @IBOutlet weak var buttonAudioPlay: UIButton!
    @IBOutlet weak var labelPlayerRemainsTime: UILabel!
    @IBOutlet weak var labelPlayerCurrentTime: UILabel!
    @IBOutlet weak var viewImprovedYesPanel: UIView!
    @IBOutlet weak var viewImprovedAlert: UIView!
    @IBOutlet weak var viewRatePanel: UIView!
    @IBOutlet weak var imageViewRateDirection: UIImageView!
    @IBOutlet weak var labelRateValue: UILabel!
    
    @IBOutlet weak var viewMinimizedDrone: UIView!
    @IBOutlet weak var viewMaximizedDrone: UIView!
    @IBOutlet weak var constraintForMaximizedDroneBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewBottomXBar: UIView!
    @IBOutlet weak var imageViewMetrodroneViewShowingArrow: UIImageView!
    
    // MARK: - Properties for drone
    
    var metrodonePlayer : MetrodronePlayer? = nil
    
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var buttonSustain: UIButton!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var buttonMetroPlay: UIButton!
    @IBOutlet weak var buttonTap: UIButton!
    @IBOutlet weak var labelBPM: UILabel!
    @IBOutlet weak var buttonOctaveUp: UIButton!
    @IBOutlet weak var buttonOctaveDown: UIButton!
    @IBOutlet weak var labelOctave: UILabel!
    
    @IBOutlet weak var viewSubdivision: UIView!
    @IBOutlet weak var buttonSubdivisionStatusOnButton: UIImageView!
    @IBOutlet weak var buttonSubDivisionNoteOnButton: UIImageView!
    @IBOutlet weak var buttonSubdivisionNote1: UIButton!
    @IBOutlet weak var buttonSubdivisionNote2: UIButton!
    @IBOutlet weak var buttonSubdivisionNote3: UIButton!
    @IBOutlet weak var buttonSubdivisionNote4: UIButton!
    
    @IBOutlet weak var viewMinTrack: UIView!
    @IBOutlet weak var constraintForMinTrackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintForMinTrackImageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewMaxTrack: UIImageView!
    
    @IBOutlet weak var constraintForDroneBackgroundImageViewHeight: NSLayoutConstraint!
    var selectedSubdivisionNote: Int = -1
    var subdivisionPanelShown = false
    
    var panGesture  = UIPanGestureRecognizer()
    var tapGesture  = UITapGestureRecognizer()
    var metrodroneViewHeight = CGFloat(336)
    let metrodroneViewMinHeight = CGFloat(40)
    var metrodronePlayerShown  = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.playlistViewModel != nil {
            self.labelPracticeItemName.text = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeItemName.text = self.practiceItem.name ?? ""
        }
        
        self.labelHypothesis.text = self.viewModel.selectedHypothesis
        self.labelSuggestion.text = self.viewModel.selectedSuggestion
        
        if AppUtils.sizeModelOfiPhone() == .iphone6p_55in {
            metrodroneViewHeight = CGFloat(380)
            constraintForDroneBackgroundImageViewHeight.constant = CGFloat(380)
        }
        
        self.initializeDronesUI()
        self.initializeAudioPlayerUI()
        self.viewAudioPlayer.isHidden = true
        
        self.initializeImproveActionViews()
        NotificationCenter.default.addObserver(self, selector: #selector(processRouteChange), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = AppOveralDataManager.manager.settingsPhoneSleepPrevent()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if self.audioPlayerTimer != nil {
            self.audioPlayerTimer!.invalidate()
            self.audioPlayerTimer = nil
        }
        
        if self.recorder != nil && self.recorder.isRecording {
            self.recorder.stop()
        }
        
        if self.player != nil && self.player!.isPlaying {
            self.player!.stop()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.constraintForMinTrackViewWidth.constant = self.imageViewMaxTrack.frame.size.width * CGFloat((self.sliderDuration.value - self.sliderDuration.minimumValue) / (self.sliderDuration.maximumValue - self.sliderDuration.minimumValue))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_rate" {
            let controller = segue.destination as! PracticeRateViewController
            if self.playlistViewModel != nil {
                controller.playlistViewModel = self.playlistViewModel
            } else {
                controller.practiceItem = self.practiceItem
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        if let _ = self.player {
            if self.isPlaying {
                self.onPlayPauseAudio(self)
            }
        }
        if let mPlayer = self.metrodonePlayer {
            mPlayer.stopPlayer()
            mPlayer.stopMetrodrone()
            self.metrodonePlayer = nil
        }
    }
    
    @IBAction func onEnd(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
         ModacityAnalytics.LogStringEvent("Exited Hypothesis Test Screen")
        self.navigationController?.popViewController(animated: true)
    }
    
   
}

// MARK: - Drone processing
extension ImprovementViewController {
    
    @objc func processRouteChange() {
        if let player = self.metrodonePlayer {
            player.stopPlayer()
            self.metrodonePlayer = nil
            
            self.prepareMetrodrone()
        }
    }
    
    func initializeDronesUI() {
        self.viewBottomXBar.backgroundColor = Color(hexString:"#292a4a")
        self.constraintForMaximizedDroneBottomSpace.constant =  metrodroneViewHeight - metrodroneViewMinHeight
        self.viewSubdivision.isHidden = true
        self.configureSubdivisionNoteSelectionGUI()
        self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggingDroneView))
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(processDroneViewTap))
        self.viewMaximizedDrone.addGestureRecognizer(panGesture)
        self.viewMaximizedDrone.addGestureRecognizer(tapGesture)
        prepareMetrodrone()
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
    
    @objc func draggingDroneView(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        let direction = self.constraintForMaximizedDroneBottomSpace.constant > (metrodroneViewHeight - metrodroneViewMinHeight) / 2
        
        if sender.state == .ended {
            if direction {
                self.closeDroneView()
            } else {
                self.openDroneView()
            }
        } else {
            if self.metrodronePlayerShown {
                let newPosition = translation.y
                if newPosition <  metrodroneViewHeight - metrodroneViewMinHeight && newPosition > 0 {
                    self.constraintForMaximizedDroneBottomSpace.constant = newPosition
                }
            } else {
                let newPosition = metrodroneViewHeight - metrodroneViewMinHeight + translation.y
                if newPosition > 0 {
                    self.constraintForMaximizedDroneBottomSpace.constant = newPosition
                }
            }
        }
        
    }
    
    @objc func processDroneViewTap(gesture : UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: self.viewMaximizedDrone)
        
        if !self.metrodronePlayerShown {
            self.openDroneView()
        } else {
            if touchPoint.y < 50 {
                self.closeDroneView()
            }
        }
    }
    
    func openDroneView() {
        
        let distance = abs(self.constraintForMaximizedDroneBottomSpace.constant)
        self.constraintForMaximizedDroneBottomSpace.constant = 0
        
        UIView.animate(withDuration: TimeInterval(distance / (metrodroneViewHeight - metrodroneViewMinHeight) * CGFloat(1.0)), animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_down")
                if !self.metrodronePlayerShown {
                    self.startMetrodrone()
                }
            }
        }
    }
    func prepareMetrodrone() {
        self.metrodonePlayer = MetrodronePlayer()//MetrodronePlayer.instance
        DispatchQueue.main.async {
            self.metrodonePlayer!.initializeOutlets(lblTempo: self.labelBPM,
                                                    droneFrame: self.viewDroneFrame,
                                                    playButton: self.buttonMetroPlay,
                                                    durationSlider: self.sliderDuration,
                                                    sustainButton: self.buttonSustain,
                                                    buttonOctaveUp: self.buttonOctaveUp,
                                                    buttonOctaveDown:self.buttonOctaveDown,
                                                    labelOctaveNum: self.labelOctave,
                                                    imageViewSubdivisionCircleStatus: self.buttonSubdivisionStatusOnButton,
                                                    imageViewSubdivisionNote: self.buttonSubDivisionNoteOnButton)
        }
        
    }
    
    func startMetrodrone() {
        ModacityAnalytics.LogEvent(.MetrodroneDrawerOpen)
        if self.metrodonePlayer == nil {
            prepareMetrodrone()
        }
        self.metrodronePlayerShown = true
    }
    
    func closeDroneView() {
        
        let distance = abs(metrodroneViewHeight - metrodroneViewMinHeight - self.constraintForMaximizedDroneBottomSpace.constant)
        self.constraintForMaximizedDroneBottomSpace.constant = metrodroneViewHeight - metrodroneViewMinHeight
        
        UIView.animate(withDuration: TimeInterval(distance / (metrodroneViewHeight - metrodroneViewMinHeight) * CGFloat(1.0)), animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
                self.endMetrodrone()
            }
        }
    }
    
    func endMetrodrone() {
        ModacityAnalytics.LogEvent(.MetrodroneDrawerClose)
        if self.subdivisionPanelShown {
            self.onSubdivision(self.view)
        }
        if self.metrodronePlayerShown {
            self.metrodronePlayerShown = false
        }
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




// MARK: - Audio playing
extension ImprovementViewController: AVAudioPlayerDelegate, FDWaveformViewDelegate {
    
    func initializeAudioPlayerUI() {
        self.viewSiriWaveFormView.isHidden = true
        self.viewAudioPlayer.isHidden = true
        self.viewRatePanel.isHidden = true
    }
    
    func showRateValue() {
        if self.currentRate == 1.0 {
            self.viewRatePanel.isHidden = true
        } else {
            self.viewRatePanel.isHidden = false
            if self.currentRate < 1 {
                self.imageViewRateDirection.image = UIImage(named:"icon_backward")
                self.labelRateValue.text = "\(Int(1.0 / self.currentRate))"
            } else {
                self.imageViewRateDirection.image = UIImage(named:"icon_forward_white")
                self.labelRateValue.text = "\(Int(self.currentRate))"
            }
        }
    }
    
    func prepareAudioPlay() {
        self.viewSiriWaveFormView.isHidden = true
        self.viewAudioPlayer.isHidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let soundFilePath = dirPath[0] + "/recording.wav"
        let url = URL(fileURLWithPath: soundFilePath)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.enableRate = true
            player.prepareToPlay()
            player.delegate = self
            
        } catch let error {
            print("Audio player error \(error)")
        }
        
        self.isPlaying = false
        
        self.waveformAudioPlay.audioURL = url
        self.waveformAudioPlay.doesAllowStretch = false
        self.waveformAudioPlay.doesAllowScroll = false
        self.waveformAudioPlay.doesAllowScrubbing = true
        self.waveformAudioPlay.wavesColor = Color.white.alpha(0.5)
        self.waveformAudioPlay.progressColor = Color.white
        self.waveformAudioPlay.delegate = self
        
        self.audioPlayerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onAudioPlayerTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onAudioPlayerTimer() {
        if let player = self.player {
            self.waveformAudioPlay.highlightedSamples = 0..<Int(Double(self.waveformAudioPlay.totalSamples) * (player.currentTime / player.duration))
            self.labelPlayerCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
            self.labelPlayerRemainsTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
        }
    }
    
    @IBAction func onPlayPauseAudio(_ sender: Any) {
        if self.isPlaying {
            if let player = player {
                player.pause()
            }
            self.isPlaying = false
            self.buttonAudioPlay.setImage(UIImage(named: "icon_play"), for: .normal)
        } else {
            if let player = player {
                player.play()
            }
            self.isPlaying = true
            self.buttonAudioPlay.setImage(UIImage(named: "icon_pause_white"), for: .normal)
        }
    }
    
    @IBAction func onAudioBackward(_ sender: Any) {
        if let player = self.player {
            self.currentRate = self.currentRate / 2.0
            if self.currentRate < 1 / 16.0 {
                self.currentRate = 1.0
            }
            player.rate = Float(self.currentRate)
            self.showRateValue()
        }
    }
    
    @IBAction func onAudioForward(_ sender: Any) {
        if let player = self.player {
            self.currentRate = self.currentRate * 2.0
            if self.currentRate > 16.0 {
                self.currentRate = 1.0
            }
            player.rate = Float(self.currentRate)
            self.showRateValue()
        }
    }
    
    @IBAction func onSaveRecord(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Name Your Recording!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            if self.playlistViewModel != nil {
                if var practiceName = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name {
                    practiceName = String(practiceName.prefix(16))
                    let autoIncrementedNumber = AppOveralDataManager.manager.fileNameAutoIncrementedNumber()
                    textField.text = "\(practiceName)_\(Date().toString(format: "yyyyMMdd"))_\(String(format:"%02d", autoIncrementedNumber))"
                }
            } else {
                if var practiceName = self.practiceItem.name {
                    practiceName = String(practiceName.prefix(16))
                    let autoIncrementedNumber = AppOveralDataManager.manager.fileNameAutoIncrementedNumber()
                    textField.text = "\(practiceName)_\(Date().toString(format: "yyyyMMdd"))_\(String(format:"%02d", autoIncrementedNumber))"
                }
            }
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let name = alertController.textFields?[0].text {
                if name != "" {
                    AppOveralDataManager.manager.increaseAutoIncrementedNumber()
                    if self.playlistViewModel != nil {
                        self.playlistViewModel.saveCurrentRecording(toFileName: name)
                    } else {
                        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: name, playlistId: "practice-\(self.practiceItem.id)", practiceName: self.practiceItem.name ?? "", practiceEntryId: self.practiceItem.id)
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style:.cancel, handler:nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onAudioToFirst(_ sender: Any) {
        if let player = player {
            player.currentTime = 0
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.buttonAudioPlay.setImage(UIImage(named: "icon_play"), for: .normal)
    }
    
    func waveformDidEndScrubbing(_ waveformView: FDWaveformView) {
        if let player = self.player {
            player.currentTime = player.duration * (Double(self.waveformAudioPlay.highlightedSamples?.count ?? 0) / Double(self.waveformAudioPlay.totalSamples))
        }
    }
}

// MARK: - Audio recording
extension ImprovementViewController {
    @IBAction func onRecordStart(_ sender: Any) {
        
        if !self.isRecording {
            
            self.labelImprovementNote.isHidden = true
            self.viewAudioPlayer.isHidden = true
            self.viewSiriWaveFormView.isHidden = false
            
            self.imageViewHeader.image = UIImage(named:"bg_improvement_recording")
            self.btnRecord.setImage(UIImage(named:"btn_record_stop"), for: .normal)
            
            self.startRecording()
            
            self.isRecording = true
            
        } else {
            
            self.viewImprovedAlert.isHidden = false
            self.imageViewHeader.image = UIImage(named:"bg_improvement_normal")
            self.btnRecord.setImage(UIImage(named:"img_record"), for: .normal)
            
            self.stopRecording()
            self.isRecording = false
            self.btnRecord.isHidden = true
            self.prepareAudioPlay()
        }
    }
    
    func startRecording() {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let soundFilePath = dirPath[0] + "/recording.wav"
        let url = URL(fileURLWithPath: soundFilePath)
        
        let settings:[String:Any] = [
            AVSampleRateKey: 44100.0,
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey:32,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            
            recorder.prepareToRecord()
            recorder.isMeteringEnabled = true
            recorder.record()
            
            let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
            displayLink.add(to: RunLoop.current, forMode: .commonModes)
            
        } catch let error {
            print("recorder error : \(error)")
        }
        
    }
    
    @objc func updateMeters() {
        recorder.updateMeters()
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePower(forChannel:0))/20)
        self.viewSiriWaveFormView.update(withLevel:normalizedValue)
    }
    
    func stopRecording() {
        recorder.stop()
    }
}

// MARK: - Process actions
extension ImprovementViewController {
    
    func initializeImproveActionViews() {
        self.labelImprovementNote.isHidden = false
        self.viewImprovedAlert.isHidden = true
        self.viewImprovedYesPanel.isHidden = true
    }
    
    @IBAction func onImprovedNo(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Hypothesis Didn't Work")
        self.viewModel.alreadyTried = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onImprovedYes(_ sender: Any) {
       ModacityAnalytics.LogStringEvent("Hypothesis Worked")
        if self.playlistViewModel != nil {
            self.playlistViewModel.addNewImprovement(self.viewModel.generateImprovement(with: self.playlistViewModel.playlist, practice: self.playlistViewModel.currentPracticeEntry))
        } else {
            AppOveralDataManager.manager.addImprovementsCount()
        }
        self.viewImprovedAlert.isHidden = true
        self.viewImprovedYesPanel.isHidden = false
    }
    
    @IBAction func onImprovedNext(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Don't Practice Hypothesis Again")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onImproveAgain(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Practice Same Hypothesis Again")
        self.viewModel.alreadyTried = true
        self.navigationController?.popViewController(animated: true)
    }
}
