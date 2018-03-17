//
//  PracticeViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import AVFoundation
import SCSiriWaveformView
import FDWaveformView

class PracticeViewController: MetrodroneBaseViewController {
    
    var playlistViewModel: PlaylistDetailsViewModel!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    // MARK:- Property values for timer
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    @IBOutlet weak var viewTimeArea: UIView!
    @IBOutlet weak var viewTimeAreaPausedPanel: UIView!
    var timer: Timer!
    var timerRunning = false
    var timerStarted: Date!
    var secondsPrevPlayed: Int!
    var isCountDown = false
    var countDownTimerStart = 0
    var timerShouldStartFrom = 0
    var timerShouldDown = false
    var timerShouldFinish = 0
    var dingSoundPlayer: AVAudioPlayer? = nil
    
    // MARK: - Properties for prompt panel processing
    @IBOutlet weak var viewPromptPanel: UIView!
    
    // MARK: - Properties for recording
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var waveformAudioPlay: FDWaveformView!
    var recorder: AVAudioRecorder!
    var isRecording = false
    
    // MARK: - Properties for audio player
    var player: AVAudioPlayer?
    var audioPlayerTimer: Timer?
    var isPlaying = false
    var currentRate = 1.0
    @IBOutlet weak var viewAudioPlayer: UIView!
    @IBOutlet weak var viewSiriWaveFormView: SCSiriWaveformView!
    @IBOutlet weak var buttonAudioPlay: UIButton!
    @IBOutlet weak var buttonAudioForward: UIButton!
    @IBOutlet weak var buttonAudioBackward: UIButton!
    @IBOutlet weak var labelPlayerRemainsTime: UILabel!
    @IBOutlet weak var labelPlayerCurrentTime: UILabel!
    @IBOutlet weak var viewRatePanel: UIView!
    @IBOutlet weak var imageViewRateDirection: UIImageView!
    @IBOutlet weak var labelRateValue: UILabel!
    
    // MARK: - Properties for drone
    @IBOutlet weak var viewMinimizedDrone: UIView!
    @IBOutlet weak var viewMaximizedDrone: UIView!
    @IBOutlet weak var constraintForMaximizedDroneBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewDroneFrame: ViewDroneFrame!
    @IBOutlet weak var sliderDuration: UISlider!
    @IBOutlet weak var labelTempo: UILabel!
    @IBOutlet weak var buttonMetrodronePlay: UIButton!
    @IBOutlet weak var buttonSustain: UIButton!
    
    @IBOutlet weak var viewSubdivision: UIView!
    @IBOutlet weak var buttonSubdivisionNote1: UIButton!
    @IBOutlet weak var buttonSubdivisionNote2: UIButton!
    @IBOutlet weak var buttonSubdivisionNote3: UIButton!
    @IBOutlet weak var buttonSubdivisionNote4: UIButton!
    var selectedSubdivisionNote: Int = -1
    var subdivisionPanelShown = false
    
    @IBOutlet weak var viewBottomXBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.initializeOutlets(lblTempo: labelTempo,
                          droneFrame: viewDroneFrame,
                          playButton: buttonMetrodronePlay,
                          durationSlider: sliderDuration,
                          sustainButton: buttonSustain)
        
        self.playlistViewModel.storePlaylist()
        self.labelPracticeItemName.text = self.playlistViewModel.currentPracticeItem.name
        
        self.initializeDroneUIs()
        self.processFavoriteIconImage()
        self.initializeAudioPlayerUI()
        self.initializeTipPromptPanel()
        self.initializeTimer()
    }
    
    func processFavoriteIconImage() {
        if !(self.playlistViewModel.isFavoritePracticeItem(for: self.playlistViewModel.currentPracticeItem.name)) {
            self.buttonFavorite.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonFavorite.alpha = 0.5
        } else {
            self.buttonFavorite.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonFavorite.alpha = 1.0
        }
    }
    
    deinit {
        self.timer.invalidate()
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_rate" {
            let controller = segue.destination as! PracticeRateViewController
            controller.playlistViewModel = self.playlistViewModel
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = self.player {
            if self.isPlaying {
                self.onPlayPauseAudio(self)
            }
        }
    }
}

// MARK: - Metrodone processing
extension PracticeViewController {
    
    func initializeDroneUIs() {
        self.viewBottomXBar.backgroundColor = Color(hexString:"#292a4a")
        self.constraintForMaximizedDroneBottomSpace.constant =  self.view.bounds.size.height * 336/667 - 40
        self.viewSubdivision.isHidden = true
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
        self.setSubdivision(self.selectedSubdivisionNote)
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
    
    @IBAction func onShowDrones(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        if self.player != nil && self.isPlaying {
            self.onPlayPauseAudio(sender)
        }
        
        if !self.viewPromptPanel.isHidden {
            self.onCloseAlertPanel(sender)
        }
        
        self.viewMaximizedDrone.isHidden = false
        self.constraintForMaximizedDroneBottomSpace.constant = 0
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onHideDrones(_ sender: Any) {
        
        if self.subdivisionPanelShown {
            self.onSubdivision(sender)
        }
        
        self.constraintForMaximizedDroneBottomSpace.constant =  self.view.bounds.size.height * 336/667 - 40
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.viewMinimizedDrone.isHidden = false
                self.viewMaximizedDrone.isHidden = true
            }
        }
    }
    
    @IBAction func onSustainButton(_ sender: Any) {
        let isOn = toggleSustain()
        buttonSustain.alpha = (isOn) ? 1.0 : 0.50
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
        tapUp()
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

// MARK: - Process navigations
extension PracticeViewController {
    
    @IBAction func onEnd(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        if !isCountDown {
            var duration = 0
            if timerRunning {
                duration = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
            } else {
                duration = self.secondsPrevPlayed
            }
            self.timer.invalidate()
            self.playlistViewModel.setDuration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId,
                                               duration: duration + (self.playlistViewModel.duration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId) ?? 0))
            self.performSegue(withIdentifier: "sid_rate", sender: nil)
        } else {
            var duration = 0
            if timerRunning {
                duration = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
            } else {
                duration = self.secondsPrevPlayed
            }
            self.timer.invalidate()
            self.playlistViewModel.setDuration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId,
                                               duration: duration + (self.playlistViewModel.duration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId) ?? 0))
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func onToggleFavorite(_ sender: Any) {
        self.playlistViewModel.setLikePracticeItem(for: self.playlistViewModel.currentPracticeItem.name)
        self.processFavoriteIconImage()
    }
    
    @IBAction func onImprove(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        let controller = UIStoryboard(name: "improve", bundle: nil).instantiateViewController(withIdentifier: "improve_scene") as! UINavigationController
        let root = controller.viewControllers[0] as! ImproveSuggestionViewController
        root.playlistModel = self.playlistViewModel
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onAskExpert(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        let controller = UIStoryboard(name:"feedback", bundle:nil).instantiateViewController(withIdentifier: "feedbackscene") as! UINavigationController
        let feedbackRootViewController = controller.viewControllers[0] as! FeedbackRootViewController
        feedbackRootViewController.pageIsRootFromMenu = false
        feedbackRootViewController.pageUIMode = 0
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func onFeedback(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        let controller = UIStoryboard(name:"feedback", bundle:nil).instantiateViewController(withIdentifier: "feedbackscene") as! UINavigationController
        let feedbackRootViewController = controller.viewControllers[0] as! FeedbackRootViewController
        feedbackRootViewController.pageIsRootFromMenu = false
        feedbackRootViewController.pageUIMode = 1
        self.present(controller, animated: true, completion: nil)
    }
}

// MARK: - Process audio player
extension PracticeViewController: AVAudioPlayerDelegate, FDWaveformViewDelegate {
    
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
    
    @IBAction func onTouchDownOnBackward(_ sender: Any) {
        if let player = self.player {
            self.currentRate = self.currentRate / 2.0
            if self.currentRate < 1 / 16.0 {
                self.currentRate = 1.0
            }
            player.rate = Float(self.currentRate)
            self.showRateValue()
        }
    }
    
    @IBAction func onTouchUpOutsideOnBackward(_ sender: Any) {
    }
    
    @IBAction func onTouchUpInsideOnBackward(_ sender: Any) {
        
    }
    
    @IBAction func onTouchDownOnForward(_ sender: Any) {
        if let player = self.player {
            self.currentRate = self.currentRate * 2.0
            if self.currentRate > 16.0 {
                self.currentRate = 1.0
            }
            player.rate = Float(self.currentRate)
            self.showRateValue()
        }
    }
    
    @IBAction func onTouchUpOutsideOnForward(_ sender: Any) {
    }
    
    @IBAction func onTouchUpInsideOnForward(_ sender: Any) {
    }
    
    func prepareAudioPlay() {
        self.viewSiriWaveFormView.isHidden = true
        self.viewAudioPlayer.isHidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let soundFilePath = dirPath[0] + "/recording.wav"
        let url = URL(fileURLWithPath: soundFilePath)
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
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
        
        self.audioPlayerTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
            if let player = self.player {
                self.waveformAudioPlay.highlightedSamples = 0..<Int(Double(self.waveformAudioPlay.totalSamples) * (player.currentTime / player.duration))
                self.labelPlayerCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
                self.labelPlayerRemainsTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
            }
        })
    }
    
    @IBAction func onPlayPauseAudio(_ sender: Any) {
        if self.isPlaying {
            if let player = player {
                player.pause()
            }
            self.isPlaying = false
            self.buttonAudioPlay.setImage(UIImage(named: "icon_play"), for: .normal)
        } else {
            startPlayAudio()
        }
    }
    
    func startPlayAudio() {
        if let player = player {
            player.play()
        }
        self.isPlaying = true
        self.buttonAudioPlay.setImage(UIImage(named: "icon_pause_white"), for: .normal)
    }
    
    @IBAction func onSaveRecord(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "Enter the file name!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            if var practiceName = self.playlistViewModel.currentPracticeItem.name {
                practiceName = String(practiceName.prefix(16))
                let autoIncrementedNumber = self.playlistViewModel.fileNameAutoIncrementedNumber()
                textField.text = "\(practiceName)_\(Date().toString(format: "yyyyMMdd"))_\(String(format:"%02d", autoIncrementedNumber))"
            }
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let name = alertController.textFields?[0].text {
                if name != "" {
                    self.playlistViewModel.increaseAutoIncrementedNumber()
                    self.playlistViewModel.saveCurrentRecording(toFileName: name)
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

// MARK: - Process recording
extension PracticeViewController {
    @IBAction func onRecordStart(_ sender: Any) {
        
        if !self.viewPromptPanel.isHidden {
            self.onCloseAlertPanel(sender)
        }
        
        if !self.isRecording {
            
            self.viewAudioPlayer.isHidden = true
            self.viewSiriWaveFormView.isHidden = false
            
            self.imageViewHeader.image = UIImage(named:"bg_practice_recording_header")
            self.btnRecord.setImage(UIImage(named:"btn_record_stop"), for: .normal)
            
            self.startRecording()
            
            self.isRecording = true
            
        } else {
            
            self.imageViewHeader.image = UIImage(named:"bg_practice_header")
            self.btnRecord.setImage(UIImage(named:"img_record"), for: .normal)
            
            self.stopRecording()
            self.isRecording = false
            
            self.prepareAudioPlay()
            self.startPlayAudio()
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            
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

// MARK: - Tip prompt panel processing
extension PracticeViewController {
    
    func initializeTipPromptPanel() {
        self.viewPromptPanel.layer.cornerRadius = 5
        if self.playlistViewModel.tooltipAlreadyShown() {
            self.viewPromptPanel.isHidden = true
        } else {
            self.viewPromptPanel.isHidden = false
            self.playlistViewModel.didTooltipShown()
        }
    }
    
    @IBAction func onCloseAlertPanel(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewPromptPanel.alpha = 0
        }) { (_) in
            self.viewPromptPanel.isHidden = true
        }
    }
    
}

// MARK: - Timer processing
extension PracticeViewController {
    
    func initializeTimer() {
        self.viewTimeAreaPausedPanel.isHidden = true
        self.viewTimeArea.layer.cornerRadius = 10
        self.viewTimeArea.layer.masksToBounds = true
        self.processTimerStarting()
        self.perform(#selector(onTimerStart), with: nil, afterDelay: 0.5)
        if let countDownTimer =  self.playlistViewModel.currentPracticeItem.countDownDuration {
            if countDownTimer > 0 {
                self.isCountDown = true
                if let timePracticed = self.playlistViewModel.duration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId) {
                    if timePracticed < countDownTimer {
                        self.countDownTimerStart = countDownTimer - timePracticed
                    } else {
                        self.countDownTimerStart = 0
                    }
                }
            }
        }
    }
    
    @IBAction func onTapTimer(_ sender: Any) {
        if !self.viewPromptPanel.isHidden {
            self.onCloseAlertPanel(sender)
        }
        
        if self.timerRunning {
            self.secondsPrevPlayed = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
            self.timer.invalidate()
            self.timerRunning = false
            self.viewTimeAreaPausedPanel.isHidden = false
        } else {
            self.timerStarted = Date()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
            self.timerRunning = true
            self.viewTimeAreaPausedPanel.isHidden = true
        }
    }
    
    @objc func onTimerStart() {
        self.timerStarted = Date()
        self.secondsPrevPlayed = 0
        self.labelHour.text = String(format:"%02d", timerShouldStartFrom / 3600)
        self.labelMinute.text = String(format:"%02d", (timerShouldStartFrom % 3600) / 60)
        self.labelSeconds.text = String(format:"%02d", timerShouldStartFrom % 60)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        self.timerRunning = true
    }
    
    @objc func onTimer() {
        let date = Date()
        var durationSeconds = Int(date.timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
        
        if timerShouldDown {
            if durationSeconds >= timerShouldStartFrom {
                self.finishCountDownTimer()
                return
            } else {
                durationSeconds = timerShouldStartFrom - durationSeconds
            }
        } else {
            durationSeconds = durationSeconds + timerShouldStartFrom
        }
        
        self.labelHour.text = String(format:"%02d", durationSeconds / 3600)
        self.labelMinute.text = String(format:"%02d", (durationSeconds % 3600) / 60)
        self.labelSeconds.text = String(format:"%02d", durationSeconds % 60)
    }
    
    func playDingSound() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            self.dingSoundPlayer = try AVAudioPlayer(contentsOf: url)
            self.dingSoundPlayer!.prepareToPlay()
            self.dingSoundPlayer!.play()
        } catch let error {
            print("Audio player (ding sound) error \(error)")
        }
    }
    
    func finishCountDownTimer() {
        self.playDingSound()
        self.labelHour.text = "00"
        self.labelMinute.text = "00"
        self.labelSeconds.text = "00"
        self.timer.invalidate()
        
        let duration = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
        self.playlistViewModel.setDuration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId,
                                           duration: duration + (self.playlistViewModel.duration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId) ?? 0))
        self.performSegue(withIdentifier: "sid_rate", sender: nil)
    }
    
    func processTimerStarting() {
        var timeAlreadyPracticed = 0
        if let timePracticed = self.playlistViewModel.duration(forPracticeItem: self.playlistViewModel.currentPracticeItem.entryId) {
            timeAlreadyPracticed = timePracticed
        }
        
        if let countDownTimer =  self.playlistViewModel.currentPracticeItem.countDownDuration {
            if countDownTimer > 0 {
                if let reseted = self.playlistViewModel.countdownReseted[self.playlistViewModel.currentPracticeItem.entryId] {
                    if reseted {
                        timerShouldDown = true
                        timerShouldStartFrom = countDownTimer
                        self.playlistViewModel.countdownReseted[self.playlistViewModel.currentPracticeItem.entryId] = false
                        return
                    }
                }
                
                if timeAlreadyPracticed >= countDownTimer {
                    timerShouldDown = false
                    timerShouldStartFrom = timeAlreadyPracticed
                } else {
                    timerShouldDown = true
                    timerShouldStartFrom = countDownTimer - timeAlreadyPracticed
                }
                return
            }
        }
        
        timerShouldDown = false
        timerShouldStartFrom = timeAlreadyPracticed
    }
}
