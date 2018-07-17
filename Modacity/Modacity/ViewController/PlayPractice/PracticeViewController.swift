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
import Intercom
import MBProgressHUD
import Crashlytics

class PracticeViewController: UIViewController {
    
    var playlistViewModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    var parentContentViewController: PlaylistContentsViewController!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    // MARK:- Process for practice break
    var practiceBreakShown = false
    var practiceBreakTime: Int! = 0
    var viewPracticeBreakPrompt: PracticeBreakPromptView! = nil
    
    // MARK:- Property values for timer
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    @IBOutlet weak var viewTimeArea: UIView!
    @IBOutlet weak var viewTimeAreaPausedPanel: UIView!
    @IBOutlet weak var buttonTimerUpDownArrow: UIButton!
    @IBOutlet weak var labelTimerUp: UILabel!
    
    var audioEngineRegreshing = false
    
    var timer: Timer!
    var timerRunning = false
    var timerStarted: Date!
    var secondsPrevPlayed: Int!
    
    var countdownTimerStarted: Date!
    var secondsPrevCountDownPlayed: Int!
    
    var overallPracticeTimeInSeconds: Int! = 0
    var countDownDuration: Int! = 0
    var countDownPlayed: Int! = 0
    
    var timerUpProcessed = false
    var timerDirection = 0
    
    var dingSoundPlayer: AVAudioPlayer? = nil
    var countDownNotification: UILocalNotification? = nil
    
    // unused
    var countupTimerStarted: Date!
    var secondsPrevCountUpPlayed: Int!
    
    var isCountDown = false
    var countDownTimerStart = 0
    var timerShouldStartFrom = 0
    var timerShouldDown = false
    var timerShouldFinish = 0
    
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
    @IBOutlet weak var viewWaveFormContainer: UIView!
    var viewSiriWaveFormView: SCSiriWaveformView!
    @IBOutlet weak var buttonAudioPlay: UIButton!
    @IBOutlet weak var buttonAudioForward: UIButton!
    @IBOutlet weak var buttonAudioBackward: UIButton!
    @IBOutlet weak var labelPlayerRemainsTime: UILabel!
    @IBOutlet weak var labelPlayerCurrentTime: UILabel!
    @IBOutlet weak var viewRatePanel: UIView!
    @IBOutlet weak var imageViewRateDirection: UIImageView!
    @IBOutlet weak var labelRateValue: UILabel!
    @IBOutlet weak var buttonSaveRecord: UIButton!
    
    // MARK: - Properties for drone
    
    var metrodroneView: MetrodroneView? = nil
    var metrodroneViewTopConstraint: NSLayoutConstraint!
    var subdivisionView: SubdivisionSelectView? = nil
    var heightOfMetrodroneView = (AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in) ? CGFloat(320) : CGFloat(360)

    @IBOutlet weak var viewBottomXBar: UIView!

    // MARK: - Properties for notes
    @IBOutlet weak var collectionViewNotes: UICollectionView!
    var quoteSelected: [String:String]!
    var notesToShow = [Note]()
    
    // MARK: - Properties for ui resizing
    @IBOutlet weak var constraintForImageHeaderViewHeight: NSLayoutConstraint!
    
    // MARK: - Timer processing
    var timerInputView: TimerInputView!
    var timerInputViewTopConstraint: NSLayoutConstraint!
    
    var practiceStartedTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.playlistViewModel != nil {
            self.playlistViewModel.storePlaylist()
            self.labelPracticeItemName.text = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeItemName.text = self.practiceItem.name ?? ""
        }
        
        self.buttonSaveRecord.alpha = 0.5
        self.buttonSaveRecord.isEnabled = false
        
        if AppUtils.sizeModelOfiPhone() == .iphone6p_55in {
            constraintForImageHeaderViewHeight.constant = 480
        } else if AppUtils.sizeModelOfiPhone() == .iphone6_47in {
            constraintForImageHeaderViewHeight.constant = 480
        } else if AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            constraintForImageHeaderViewHeight.constant = 360
        } else if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            constraintForImageHeaderViewHeight.constant = 320
        }
        
        self.labelTimerUp.isHidden = true
        self.viewTimeAreaPausedPanel.isHidden = true
        
        self.viewBottomXBar.backgroundColor = Color(hexString:"#292a4a")
        self.initializeDroneUIs()
        self.processFavoriteIconImage()
        self.initializeAudioPlayerUI()
        self.startPractice()
        self.initializeForNotes()
        
        self.addTabBar()
        
        ModacityAnalytics.LogEvent(.StartPracticeItem, extraParamName: "ItemName", extraParamValue: self.labelPracticeItemName.text)
        NotificationCenter.default.addObserver(self, selector: #selector(resetMetrodroneEngine), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processRouteChange), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    func startPractice() {
        
        if !AppOveralDataManager.manager.walkThroughDoneForPracticePage() {
            self.showWalkthrough()
        } else {
            self.startPracticeTimer()
        }
    }
    
    func startPracticeTimer() {
        self.practiceStartedTime = Date()
        self.initializeTimer()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
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
    
    func processFavoriteIconImage() {
        if self.playlistViewModel != nil {
            if !(self.playlistViewModel.isFavoritePracticeItem(forItemId: self.playlistViewModel.currentPracticeEntry.practiceItemId)) {
                self.buttonFavorite.setImage(UIImage(named:"icon_heart"), for: .normal)
                self.buttonFavorite.alpha = 0.5
            } else {
                self.buttonFavorite.setImage(UIImage(named:"icon_heart_red"), for: .normal)
                self.buttonFavorite.alpha = 1.0
            }
        } else {
            if !(PracticeItemLocalManager.manager.isFavoritePracticeItem(for: self.practiceItem.id)) {
                self.buttonFavorite.setImage(UIImage(named:"icon_heart"), for: .normal)
                self.buttonFavorite.alpha = 0.5
            } else {
                self.buttonFavorite.setImage(UIImage(named:"icon_heart_red"), for: .normal)
                self.buttonFavorite.alpha = 1.0
            }
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
            if self.playlistViewModel != nil {
                controller.playlistViewModel = self.playlistViewModel
            } else {
                controller.practiceItem = self.practiceItem
                controller.deliverModel = self.deliverModel
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = AppOveralDataManager.manager.settingsPhoneSleepPrevent()
        self.configureNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        if let _ = self.player {
            if self.isPlaying {
                self.onPlayPauseAudio(self)
            }
        }
        
        if let metrodroneView = self.metrodroneView {
            metrodroneView.viewDidDisappear()
        }
    }
}

// MARK: - Metrodone processing
extension PracticeViewController: MetrodroneViewDelegate, SubdivisionSelectViewDelegate {
    
    @objc func processRouteChange() {
        DispatchQueue.main.async {
            self.resetMetrodroneEngine()
        }
    }
    
    @objc func resetMetrodroneEngine() {
        print("metrodrone engine reset")
        if self.audioEngineRegreshing {
            return
        }
        if let player = self.metrodroneView?.metrodonePlayer {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.audioEngineRegreshing = true
            player.stopPlayer()
            self.metrodroneView?.metrodonePlayer = nil
            self.metrodroneView?.prepareMetrodrone()
            
            self.perform(#selector(processAudioEnginePrepared), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func processAudioEnginePrepared() {
        MBProgressHUD.hide(for: self.view, animated: true)
        self.audioEngineRegreshing = false
    }
    
    func initializeDroneUIs() {
        
        self.metrodroneView = MetrodroneView()
        
        self.view.addSubview(self.metrodroneView!)
        self.view.leadingAnchor.constraint(equalTo: self.metrodroneView!.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.metrodroneView!.trailingAnchor).isActive = true
        self.metrodroneView!.heightAnchor.constraint(equalToConstant: heightOfMetrodroneView).isActive = true
        self.metrodroneView!.delegate = self
        if #available(iOS 11.0, *) {
            if AppUtils.iphoneIsXModel() {
                self.metrodroneViewTopConstraint = self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
            } else {
                self.metrodroneViewTopConstraint = self.view.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
            }
        } else {
            self.metrodroneViewTopConstraint = self.view.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
        }
        self.metrodroneViewTopConstraint?.constant = 0
        self.metrodroneViewTopConstraint?.isActive = true
        self.metrodroneView!.initializeDroneUIs()
        self.metrodroneView!.isHidden = true
    }
    
    func onTapHeaderBar() {
        self.showMetrodroneView()
    }
    
    func onSubdivision() {
        if self.subdivisionView == nil {
            self.subdivisionView = SubdivisionSelectView()
            self.subdivisionView!.delegate = self
            self.view.addSubview(self.subdivisionView!)
            let frame = self.view.convert(self.metrodroneView!.buttonSubDivision.frame, from: self.metrodroneView!.buttonSubDivision.superview)
            self.subdivisionView!.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: frame.origin.y).isActive = true
            self.subdivisionView!.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: frame.origin.x + frame.size.width / 2).isActive = true
            self.subdivisionView!.isHidden = true
        }
        
        if let subdivisionView = self.subdivisionView {
            subdivisionView.isHidden = !subdivisionView.isHidden
        }
    }
    
    func subdivisionSelectionChanged(idx: Int) {
        if let player = self.metrodroneView?.metrodonePlayer {
            player.setSubdivision(idx + 1)
        }
    }
    
    func showMetrodroneView() {
        
        if self.metrodroneView!.isHidden {
            ModacityAnalytics.LogEvent(.MetrodroneDrawerOpen)
            self.metrodroneView!.isHidden = false
            self.metrodroneViewTopConstraint.constant = heightOfMetrodroneView
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (finished) in
                if finished {
                    self.metrodroneView!.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_down")
                }
            }
        } else {
            
            if self.subdivisionView != nil && self.subdivisionView!.isHidden == false {
                self.subdivisionView!.isHidden = true
            }
            
            self.metrodroneViewTopConstraint.constant = 0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (finished) in
                if finished {
                    self.metrodroneView!.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
                    self.metrodroneView!.isHidden = true
                }
            }
        }
    }
    
    @IBAction func onTabDrone() {
        self.showMetrodroneView()
    }
}

// MARK: - Process navigations
extension PracticeViewController {
    
    @IBAction func onEnd(_ sender: Any) {

        if self.playlistViewModel != nil {
            ModacityAnalytics.LogStringEvent("Pressed End Practice Item", extraParamName: "item", extraParamValue: self.playlistViewModel.currentPracticeEntry.name)
        } else {
            ModacityAnalytics.LogStringEvent("Pressed End Practice Item", extraParamName: "item", extraParamValue: self.practiceItem.name)
        }
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        if self.playlistViewModel != nil {
            self.playlistViewModel.updateDuration(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, duration: self.overallPracticeTimeInSeconds)
            self.playlistViewModel.currentPracticeEntry.practiceItem()?.updateLastPracticedTime(to: self.practiceStartedTime)
            self.playlistViewModel.currentPracticeEntry.practiceItem()?.updateLastPracticedDuration(duration: self.overallPracticeTimeInSeconds)
        } else {
            self.practiceItem.updateLastPracticedTime(to: self.practiceStartedTime)
            self.practiceItem.updateLastPracticedDuration(duration: self.overallPracticeTimeInSeconds)
            self.deliverModel.sessionTime = self.overallPracticeTimeInSeconds
            AppOveralDataManager.manager.addPracticeTime(inSec: self.overallPracticeTimeInSeconds)
        }

        if self.timer != nil {
            self.timer.invalidate()
        }
        
        var practiceCompleted = false
        
        if self.countDownDuration == 0 {
            practiceCompleted = true
        } else {
            if self.countDownPlayed < self.countDownDuration {
                practiceCompleted = false
            } else {
                practiceCompleted = true
            }
        }
        
        self.cancelCountDownNotification()
        
        if practiceCompleted {
            self.performSegue(withIdentifier: "sid_rate", sender: nil)
        } else {
            if self.playlistViewModel != nil {
                let id = PracticingDailyLocalManager.manager.saveNewPracticing(practiceItemId: self.playlistViewModel.currentPracticeEntry.practiceItemId,
                                                                      started: self.playlistViewModel.sessionTimeStarted ?? Date(),
                                                                      duration: self.overallPracticeTimeInSeconds,
                                                                      rating: 0,
                                                                      inPlaylist: self.playlistViewModel.playlist.id,
                                                                      forPracticeEntry: self.playlistViewModel.currentPracticeEntry.entryId,
                                                                      improvements: self.playlistViewModel.sessionImproved)
                self.playlistViewModel.playlistPracticeData.practices.append(id)
                self.playlistViewModel.sessionImproved = [ImprovedRecord]()
                self.navigationController?.popViewController(animated: true)
            } else {
                self.performSegue(withIdentifier: "sid_rate", sender: nil)
            }
        }
    }
    
    @IBAction func onToggleFavorite(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Practice Screen - Toggled Favorite")
        if self.playlistViewModel != nil {
            if let practiceItem = self.playlistViewModel.currentPracticeEntry.practiceItem() {
                self.playlistViewModel.setLikePracticeItem(for: practiceItem)
                self.processFavoriteIconImage()
            }
        } else {
            PracticeItemLocalManager.manager.setFavoritePracticeItem(forItemId: self.practiceItem.id)
            if self.practiceItem.isFavorite == 1 {
                self.practiceItem.isFavorite = 0
            } else {
                self.practiceItem.isFavorite = 1
            }
            self.processFavoriteIconImage()
        }
        ModacityAnalytics.LogStringEvent("Toggled Favorite")
    }
    
}

// MARK: - Process audio player
extension PracticeViewController: AVAudioPlayerDelegate, FDWaveformViewDelegate {
    
    func initializeAudioPlayerUI() {
        self.viewWaveFormContainer.isHidden = true
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
        self.viewWaveFormContainer.isHidden = true
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
            ModacityDebugger.debug("Audio player error \(error)")
        }
        
        self.isPlaying = false
        
        self.waveformAudioPlay.audioURL = url
        self.waveformAudioPlay.doesAllowStretch = false
        self.waveformAudioPlay.doesAllowScroll = false
        self.waveformAudioPlay.doesAllowScrubbing = true
        self.waveformAudioPlay.wavesColor = Color.white.alpha(0.5)
        self.waveformAudioPlay.progressColor = Color.white
        self.waveformAudioPlay.delegate = self
        
        self.audioPlayerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onAudioTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onAudioTimer() {
        if let player = self.player {
            if player.duration != 0 {
                let samples = Int(Double(self.waveformAudioPlay.totalSamples) * (player.currentTime / player.duration))
                if samples > 0 {
                    self.waveformAudioPlay.highlightedSamples = 0..<samples
                }
            }
            self.labelPlayerCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
            self.labelPlayerRemainsTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
        }
    }
    
    @IBAction func onPlayPauseAudio(_ sender: Any) {
        if self.isPlaying {
            pauseAudio()
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
    
    func pauseAudio() {
        if let player = player {
            player.pause()
        }
        self.isPlaying = false
        self.buttonAudioPlay.setImage(UIImage(named: "icon_play"), for: .normal)
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
            } else if self.practiceItem != nil {
                let practiceName = String(self.practiceItem.name.prefix(16))
                let autoIncrementedNumber = AppOveralDataManager.manager.fileNameAutoIncrementedNumber()
                textField.text = "\(practiceName)_\(Date().toString(format: "yyyyMMdd"))_\(String(format:"%02d", autoIncrementedNumber))"
            }
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let name = alertController.textFields?[0].text {
                if name != "" {
                    if self.playlistViewModel != nil {
                        AppOveralDataManager.manager.increaseAutoIncrementedNumber()
                        self.playlistViewModel.saveCurrentRecording(toFileName: name)
                        self.buttonSaveRecord.alpha = 0.5
                        self.buttonSaveRecord.isEnabled = false
                    } else if self.practiceItem != nil {
                        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: name,
                                                                            playlistId: "practice-\(self.practiceItem.id)",
                                                                            practiceName: self.practiceItem.name ?? "",
                                                                            practiceEntryId: self.practiceItem.id,
                                                                            practiceItemId: self.practiceItem.id)
                        self.buttonSaveRecord.alpha = 0.5
                        self.buttonSaveRecord.isEnabled = false
                    }
                    ModacityAnalytics.LogStringEvent("Saved Practice Recording",
                                                    extraParamName: "filename",
                                                    extraParamValue:name)
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
            if self.waveformAudioPlay.totalSamples != 0 {
                player.currentTime = player.duration * (Double(self.waveformAudioPlay.highlightedSamples?.count ?? 0) / Double(self.waveformAudioPlay.totalSamples))
            }
        }
    }
}

// MARK: - Process recording
extension PracticeViewController {
    @IBAction func onRecordStart(_ sender: Any) {
        if !self.isRecording {
            // Start Recording
            self.viewAudioPlayer.isHidden = true
            self.viewWaveFormContainer.isHidden = false
            if self.viewSiriWaveFormView == nil {
                self.viewSiriWaveFormView = SCSiriWaveformView()
                self.viewSiriWaveFormView.backgroundColor = Color.clear
                self.viewSiriWaveFormView.translatesAutoresizingMaskIntoConstraints = false
                self.viewWaveFormContainer.addSubview(self.viewSiriWaveFormView)
                self.viewSiriWaveFormView.leadingAnchor.constraint(equalTo: self.viewWaveFormContainer.leadingAnchor).isActive = true
                self.viewSiriWaveFormView.trailingAnchor.constraint(equalTo: self.viewWaveFormContainer.trailingAnchor).isActive = true
                self.viewSiriWaveFormView.topAnchor.constraint(equalTo: self.viewWaveFormContainer.topAnchor).isActive = true
                self.viewSiriWaveFormView.bottomAnchor.constraint(equalTo: self.viewWaveFormContainer.bottomAnchor).isActive = true
            }
            
            self.viewWaveFormContainer.isHidden = false
            
            self.imageViewHeader.image = UIImage(named:"bg_practice_recording_header")
            self.btnRecord.setImage(UIImage(named:"btn_record_stop"), for: .normal)
            
            self.pauseAudio()
            self.startRecording()
            
            self.isRecording = true
            
        } else {
            
            self.buttonSaveRecord.alpha = 1.0
            self.buttonSaveRecord.isEnabled = true
            
            // Stop Recording
            self.imageViewHeader.image = UIImage(named:"bg_practice_header")
            self.btnRecord.setImage(UIImage(named:"img_record"), for: .normal)
            
            self.stopRecording()
            self.isRecording = false
            
            self.prepareAudioPlay()
            
            if !AppOveralDataManager.manager.settingsDisableAutoPlayback() {
                if let player = self.metrodroneView?.metrodonePlayer {
                    player.stopMetrodrone()
                }
                self.startPlayAudio()
            }
        }
    }
    
    func startRecording() {
        ModacityAnalytics.LogEvent(.RecordStart)
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
            ModacityDebugger.debug("recorder error : \(error)")
        }
        
    }
    
    @objc func updateMeters() {
        recorder.updateMeters()
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePower(forChannel:0))/20)
        self.viewSiriWaveFormView.update(withLevel:normalizedValue)
    }
    
    func stopRecording() {
        ModacityAnalytics.LogEvent(.RecordStop)
        recorder.stop()
    }
}

// MARK: - Timer processing
extension PracticeViewController {
    
    func initializeTimer() {
        
        self.viewTimeAreaPausedPanel.isHidden = true
        self.viewTimeArea.layer.cornerRadius = 10
        self.viewTimeArea.layer.masksToBounds = true
        self.labelTimerUp.isHidden = true
        
        if self.playlistViewModel != nil {
            self.countDownDuration = self.playlistViewModel.currentPracticeEntry.countDownDuration ?? 0
            self.countDownPlayed = self.playlistViewModel.countDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId) ?? 0
        }
        
        self.perform(#selector(onTimerStart), with: nil, afterDelay: 0.5)
    }
    
    @IBAction func onTapTimerArrow(_ sender: Any) {
        if self.timerUpProcessed && self.timerDirection == 1 {
            self.labelTimerUp.isHidden = true
            self.viewTimeArea.isHidden = false
            self.timerDirection = 0
        } else if self.timerUpProcessed && self.timerDirection == 0 {
            self.labelTimerUp.isHidden = false
            self.viewTimeArea.isHidden = true
            self.timerDirection = 1
        } else {
            if self.timerDirection == 0 && self.countDownDuration == 0 {
                self.onTabTimer()
            } else if self.timerDirection == 0 && self.countDownPlayed >= self.countDownDuration {
                self.onTabTimer()
            } else {
                self.timerDirection = (self.timerDirection == 0) ? 1 : 0
            }
        }
        
        let modeName = (isCountDown) ? "Countdown" : "Countup"
        ModacityAnalytics.LogStringEvent("Changed Timer Mode to \(modeName)")
    }
    
    @IBAction func onTapTimer(_ sender:Any) {
        if self.timerRunning {
            ModacityAnalytics.LogStringEvent("Paused Practice Timer")
            self.secondsPrevPlayed = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
            if self.countupTimerStarted != nil {
                self.secondsPrevCountUpPlayed = Int(Date().timeIntervalSince1970 - self.countupTimerStarted.timeIntervalSince1970) + self.secondsPrevCountUpPlayed
            }
            if self.countdownTimerStarted != nil {
                self.secondsPrevCountDownPlayed = Int(Date().timeIntervalSince1970 - self.countdownTimerStarted.timeIntervalSince1970) + self.secondsPrevCountDownPlayed
                self.cancelCountDownNotification()
            }
            self.timer.invalidate()
            self.timerRunning = false
            self.viewTimeAreaPausedPanel.isHidden = false
        } else {
            ModacityAnalytics.LogStringEvent("Resumed Practice Timer")
            self.timerStarted = Date()
            self.countdownTimerStarted = Date()
            self.countupTimerStarted = Date()
            if self.countDownDuration > 0 && self.countDownPlayed < self.countDownDuration {
                self.generateCountdownLocalNotification(date: Date().addingTimeInterval(TimeInterval(self.countDownDuration - self.countDownPlayed)))
            }
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
            self.timerRunning = true
            self.viewTimeAreaPausedPanel.isHidden = true
        }
    }
    
    @objc func onTimerStart() {
        self.timerStarted = Date()
        
        self.secondsPrevPlayed = 0
        self.secondsPrevCountDownPlayed = self.countDownPlayed ?? 0
        
        self.countupTimerStarted = Date()
        self.secondsPrevCountUpPlayed = 0
        
        self.timerDirection = 0
        if self.countDownDuration > 0 {
            if self.countDownPlayed < self.countDownDuration {
                self.countdownTimerStarted = Date()
                self.timerDirection = 1
                self.generateCountdownLocalNotification(date: Date().addingTimeInterval(TimeInterval(self.countDownDuration - self.countDownPlayed)))
            }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        self.timerRunning = true
    }
    
    @objc func onTimer() {
        let date = Date()
        self.overallPracticeTimeInSeconds = Int(date.timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970) + self.secondsPrevPlayed
        
        var durationSeconds = self.overallPracticeTimeInSeconds ?? 0
        
        var timerDirection = 0

        if self.countDownDuration > 0 && self.timerDirection == 1 {
            self.countDownPlayed = Int(date.timeIntervalSince1970 - self.countdownTimerStarted.timeIntervalSince1970) + self.secondsPrevCountDownPlayed
            if self.playlistViewModel != nil {
                self.playlistViewModel.updateCountDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, time: self.countDownPlayed)
            }
            if self.countDownPlayed < self.countDownDuration {
                durationSeconds = (self.countDownDuration - self.countDownPlayed)
                timerDirection = 1
            } else {
                if !self.timerUpProcessed {
                    self.timerUpProcessed = true
                    self.countDownPlayed = self.countDownDuration
                    if self.playlistViewModel != nil {
                        self.playlistViewModel.updateCountDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, time: self.countDownPlayed)
                    }
                    self.processTimerUp()
                    return
                }
            }
        }
        
        self.labelHour.text = String(format:"%02d", durationSeconds / 3600)
        self.labelMinute.text = String(format:"%02d", (durationSeconds % 3600) / 60)
        self.labelSeconds.text = String(format:"%02d", durationSeconds % 60)
        
        if self.timerUpProcessed && self.timerDirection == 1 {
            self.buttonTimerUpDownArrow.setImage(UIImage(named: "icon_arrow_updown"), for: .normal)
        } else {
            self.buttonTimerUpDownArrow.setImage(UIImage(named:(timerDirection == 1 ? "icon_timer_arrow_count_down" : "icon_timer_arrow_count_up")), for: .normal)
        }
        
        if self.practiceBreakTime > 0 {
            if self.overallPracticeTimeInSeconds >= self.practiceBreakTime {
                if !self.practiceBreakShown {
                    self.processPracticeBreak(with: durationSeconds)
                    return
                }
            }
        }
    }
    
    func processPracticeBreak(with time:Int) {
        self.onTapTimer(self.view)
        self.showPracticeBreakPrompt(with: time)
    }
    
    func showPracticeBreakPrompt(with time: Int) {
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
        }
        self.viewPracticeBreakPrompt = PracticeBreakPromptView()
        self.viewPracticeBreakPrompt.delegate = self
        self.view.addSubview(self.viewPracticeBreakPrompt)
        self.view.topAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.trailingAnchor).isActive = true
        self.practiceBreakShown = true
        self.viewPracticeBreakPrompt.delegate = self
        if #available(iOS 11.0, *) {
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        } else {
            self.view.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        }
        self.view.bringSubview(toFront: self.viewPracticeBreakPrompt)
        self.viewPracticeBreakPrompt.labelHour.text = String(format:"%02d", time / 3600)
        self.viewPracticeBreakPrompt.labelMinute.text = String(format:"%02d", (time % 3600) / 60)
        self.viewPracticeBreakPrompt.labelSecond.text = String(format:"%02d", time % 60)
        
        if self.parentContentViewController != nil {
            self.parentContentViewController.practiceBreakShown = true
        }
    }
    
    func processTimerUp() {
        ModacityAnalytics.LogStringEvent("Practice Time's Up!")
        self.playDingSound()
        self.viewTimeArea.isHidden = true
        self.labelTimerUp.isHidden = false
        self.buttonTimerUpDownArrow.setImage(UIImage(named: "icon_arrow_updown"), for: .normal)
        self.cancelCountDownNotification()
        if !AppOveralDataManager.manager.walkThroughDoneForPracticeTimerUp() {
            self.showTimerUpWalkThrough()
        }
    }
    
    func playDingSound() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else { return }
        do {
            self.dingSoundPlayer = try AVAudioPlayer(contentsOf: url)
            self.dingSoundPlayer!.prepareToPlay()
            self.dingSoundPlayer!.play()
        } catch let error {
            ModacityDebugger.debug("Audio player (ding sound) error \(error)")
        }
    }
}

// MARK: - Notes

extension PracticeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PracticeNoteCellDelegate {
    
    @IBAction func onTabNotes() {
        
        ModacityAnalytics.LogStringEvent("Practicing - Pressed Notes")
        
        if AppOveralDataManager.manager.settingsTimerPauseDuringNote() {
            if self.timerRunning {
                self.onTapTimer(self.view)
            }
        }
        
        let detailsViewController = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        
        detailsViewController.startTabIdx = 2
        
        if self.playlistViewModel != nil {
            detailsViewController.practiceItemId = self.playlistViewModel.currentPracticeEntry.practiceItemId
        } else {
            detailsViewController.practiceItemId = self.practiceItem.id
        }
        
        self.navigationController?.pushViewController(detailsViewController, animated: true)
        
    }
    
    func initializeForNotes() {
        self.quoteSelected = MusicQuotesManager.manager.randomeQuote()
        if self.collectionViewNotes != nil {
            if let layout = self.collectionViewNotes.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }
        self.collectionViewNotes.register(UINib(nibName: "PracticeMusicQuoteCell", bundle: nil), forCellWithReuseIdentifier: "PracticeMusicQuoteCell")
        self.collectionViewNotes.register(UINib(nibName: "PracticeNoteCell", bundle: nil), forCellWithReuseIdentifier: "PracticeNoteCell")
        self.collectionViewNotes.isPagingEnabled = true
        self.collectionViewNotes.showsVerticalScrollIndicator = false
        self.collectionViewNotes.delegate = self
        self.collectionViewNotes.dataSource = self
    }
    
    func configureNotes() {
        if self.playlistViewModel != nil {
            if let notes = self.playlistViewModel.currentPracticeEntry.practiceItem()?.notes {
                self.notesToShow = [Note]()
                for note in notes {
                    if !note.archived {
                        self.notesToShow.append(note)
                    }
                }
            }
        } else {
            if let practiceItemId = self.practiceItem.id {
                self.practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId)
            }
            if let notes = self.practiceItem.notes {
                self.notesToShow = [Note]()
                for note in notes {
                    if !note.archived {
                        self.notesToShow.append(note)
                    }
                }
            }
        }
        self.collectionViewNotes.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.notesToShow.count == 0 || self.notesToShow.count == 1 {
            return 1
        } else {
            return self.notesToShow.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.notesToShow.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PracticeMusicQuoteCell", for: indexPath) as! PracticeMusicQuoteCell
            cell.configure(note: self.quoteSelected["quote"] ?? "", name: self.quoteSelected["person"] ?? "")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PracticeNoteCell", for: indexPath) as! PracticeNoteCell
            cell.configure(note: self.notesToShow[indexPath.row], indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.notesToShow.count == 0 {
            return CGSize(width: self.collectionViewNotes.frame.size.width, height: self.collectionViewNotes.frame.size.height)
        } else {
            if self.notesToShow.count == 1 {
                return CGSize(width: self.collectionViewNotes.frame.size.width, height: self.collectionViewNotes.frame.size.height)
            } else if self.notesToShow.count == 2 {
                return CGSize(width: self.collectionViewNotes.frame.size.width - 30, height: self.collectionViewNotes.frame.size.height)
            } else {
                return CGSize(width: self.collectionViewNotes.frame.size.width / 2 - 30, height: self.collectionViewNotes.frame.size.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.notesToShow.count > 0 {
            
            let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNoteDetailsViewController") as! PracticeNoteDetailsViewController
            controller.note = self.notesToShow[indexPath.row]
            controller.playlistViewModel = self.playlistViewModel
            if self.playlistViewModel != nil {
                controller.playlistPracticeEntry = self.playlistViewModel.currentPracticeEntry
            }
            
            controller.practiceItem = self.practiceItem
            ModacityAnalytics.LogStringEvent("Practicing - Opened Note", extraParamName: "NoteIndex", extraParamValue: indexPath.row)
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
    }
    
    func onNoteSwipeUp(note: Note, cell: PracticeNoteCell, indexPath: IndexPath) {
        ModacityAnalytics.LogStringEvent("Practicing - Swiped Note Up")
        if self.playlistViewModel != nil {
            cell.startStraitUpAnimate {
                if self.notesToShow.count > 2 {
                    self.collectionViewNotes.performBatchUpdates({
                        self.playlistViewModel.changeArchiveStatusForNote(noteId: note.id, for: self.playlistViewModel.currentPracticeEntry)
                        self.collectionViewNotes.deleteItems(at: [indexPath])
                        self.configureNotes()
                    }, completion: nil)
                } else {
                    self.playlistViewModel.changeArchiveStatusForNote(noteId: note.id, for: self.playlistViewModel.currentPracticeEntry)
                    self.configureNotes()
                }
            }
        } else {
            cell.startStraitUpAnimate {
                if self.notesToShow.count > 2 {
                    self.collectionViewNotes.performBatchUpdates({
                        self.practiceItem.archiveNote(for: note.id)
                        self.collectionViewNotes.deleteItems(at: [indexPath])
                        self.configureNotes()
                    }, completion: nil)
                } else {
                    self.practiceItem.archiveNote(for: note.id)
                    self.configureNotes()
                }
            }
        }
    }
}

// MARK: - Process walkthrough

extension PracticeViewController: PlayPracticeWalkthroughViewDelegate, PracticeTimerUpWalkThroughViewDelegate {
    
    func showWalkthrough() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Practice - Displayed")
        let walkThrough: PlayPracticeWalkthroughView = PlayPracticeWalkthroughView()
        self.view.addSubview(walkThrough)
        walkThrough.commonInit()
        
        
        if #available(iOS 11.0, *) {
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: walkThrough.bottomAnchor).isActive = true
        } else {
            self.view.bottomAnchor.constraint(equalTo: walkThrough.bottomAnchor).isActive = true
        }
        self.view.topAnchor.constraint(equalTo: walkThrough.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: walkThrough.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: walkThrough.trailingAnchor).isActive = true
        self.view.bringSubview(toFront: walkThrough)
        walkThrough.delegate = self
        walkThrough.alpha = 0
        UIView.animate(withDuration: 0.5) {
            walkThrough.alpha = 1
        }
    }
    
    func dismiss(playpracticeWalkThroughView: PlayPracticeWalkthroughView, storing: Bool) {
        ModacityAnalytics.LogStringEvent("Walkthrough - Practice - Dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            playpracticeWalkThroughView.alpha = 0
        }) { (finished) in
            if finished {
                playpracticeWalkThroughView.removeConstraints(playpracticeWalkThroughView.constraints)
                playpracticeWalkThroughView.removeFromSuperview()
                if storing {
                    AppOveralDataManager.manager.walkThroughPracticePage()
                }
                self.startPracticeTimer()
            }
        }
    }
    
    func showTimerUpWalkThrough() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Timer's Up - Displayed")
        let walkThrough: PracticeTimerUpWalkThroughView = PracticeTimerUpWalkThroughView()
        self.view.addSubview(walkThrough)
        
        if #available(iOS 11.0, *) {
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: walkThrough.bottomAnchor).isActive = true
        } else {
            self.view.bottomAnchor.constraint(equalTo: walkThrough.bottomAnchor).isActive = true
        }
        self.view.topAnchor.constraint(equalTo: walkThrough.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: walkThrough.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: walkThrough.trailingAnchor).isActive = true
        self.view.bringSubview(toFront: walkThrough)
        walkThrough.delegate = self
        walkThrough.alpha = 0
        UIView.animate(withDuration: 0.5) {
            walkThrough.alpha = 1
        }
    }
    
    func dismiss(practiceTimerUpWalkThroughView: PracticeTimerUpWalkThroughView, storing: Bool) {
        ModacityAnalytics.LogStringEvent("Walkthrough - Timer's Up - Dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            practiceTimerUpWalkThroughView.alpha = 0
        }) { (finished) in
            if finished {
                practiceTimerUpWalkThroughView.removeConstraints(practiceTimerUpWalkThroughView.constraints)
                practiceTimerUpWalkThroughView.removeFromSuperview()
                if storing {
                    AppOveralDataManager.manager.walkThroughPracticeTimerUp()
                }
            }
        }
    }
}

// MARK: - Tab bar control

extension PracticeViewController: PlayPracticeTabBarViewDelegate {
    
    func addTabBar() {
        let tabBarView = PlayPracticeTabBarView()
        tabBarView.delegate = self
        self.view.insertSubview(tabBarView, at: self.view.subviews.count - 2)
        if #available(iOS 11.0, *) {
            if AppUtils.iphoneIsXModel() {
                tabBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                tabBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            }
        } else {
            tabBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
        tabBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    }
    
    func onTab(idx: Int) {
        switch idx {
        case 0:
            self.onImprove()
        case 1:
            self.onTabDrone()
        case 2:
            self.onTabNotes()
        case 3:
            self.onTabTimer()
        case 4:
            self.onAskExpert()
        default:
            return
        }
    }
    
    @IBAction func onImprove() {
        ModacityAnalytics.LogEvent(.PressedImprove)
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        
        if AppOveralDataManager.manager.settingsTimerPauseDuringImprove() {
            if self.timerRunning {
                self.onTapTimer(self.view)
            }
        }
        
        let controller = UIStoryboard(name: "improve", bundle: nil).instantiateViewController(withIdentifier: "improve_scene") as! UINavigationController
        let root = controller.viewControllers[0] as! ImproveSuggestionViewController
        if self.playlistViewModel != nil {
            root.playlistModel = self.playlistViewModel
        } else {
            root.practiceItem = self.practiceItem
            root.deliverModel = self.deliverModel
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onAskExpert() {
        ModacityAnalytics.LogEvent(.PressedAsk)
        let attr :ICMUserAttributes = ICMUserAttributes.init()
        attr.customAttributes = ["AppLocation" : "practice"]
        Intercom.updateUser(attr)
        Intercom.presentMessageComposer()
    }
}

extension PracticeViewController: TimerInputViewDelegate {
    
    func onTabTimer() {
        ModacityAnalytics.LogStringEvent("Pressed Timer Button")
        self.showTimer()
    }
    
    func showTimer() {
        if self.timerInputView == nil {
            self.timerInputView = TimerInputView()
            self.view.addSubview(self.timerInputView)
            self.timerInputView.imageViewTriangle.isHidden = true
            self.timerInputView.delegate = self
            self.view.leadingAnchor.constraint(equalTo: self.timerInputView.leadingAnchor).isActive = true
            self.view.trailingAnchor.constraint(equalTo: self.timerInputView.trailingAnchor).isActive = true
            self.timerInputView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height - 80).isActive = true
            timerInputViewTopConstraint = self.timerInputView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:  UIScreen.main.bounds.size.height)
            timerInputViewTopConstraint.isActive = true
            
            if self.countDownDuration > 0 {
                self.timerInputView.showValues(timer: self.countDownDuration)
            }
            
            let deadline = DispatchTime.now() + .milliseconds(200)
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.timerInputViewTopConstraint.constant = 80
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            self.timerInputView.isHidden = false
            self.timerInputViewTopConstraint.constant = 80
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func closeTimer() {
        ModacityAnalytics.LogStringEvent("Practice - Closed Timer")
        self.timerInputViewTopConstraint.constant = UIScreen.main.bounds.size.height
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.timerInputView.isHidden = true
            }
        }
    }
    
    func onTimerSelected(timerInSec: Int) {
        ModacityAnalytics.LogStringEvent("Practice - Set Timer", extraParamName: "Duration", extraParamValue: timerInSec)
        if timerInSec != 0 {
            self.startCountDown(from: timerInSec)
        } else {
            if self.countDownDuration > 0 {
                self.countDownDuration = 0
                self.countDownPlayed = 0
                
                self.viewTimeArea.isHidden = false
                self.buttonTimerUpDownArrow.isHidden = false
                self.labelTimerUp.isHidden = true
                self.viewTimeAreaPausedPanel.isHidden = true
                
                if self.playlistViewModel != nil {
                    self.playlistViewModel.changeCountDownDuration(for: self.playlistViewModel.currentPracticeEntry.entryId, duration: 0)
                    self.playlistViewModel.updateCountDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, time: 0)
                }
                
                self.countupTimerStarted = Date()
                self.timerDirection = 0
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
                self.timerRunning = true
                
                self.cancelCountDownNotification()
            }
        }
        
        self.closeTimer()
    }
    
    func startCountDown(from: Int) {
        if self.timer != nil && self.timerRunning {
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.countDownDuration = from
        self.countDownPlayed = 0
        self.timerUpProcessed = false
        self.viewTimeArea.isHidden = false
        self.buttonTimerUpDownArrow.isHidden = false
        self.labelTimerUp.isHidden = true
        self.viewTimeAreaPausedPanel.isHidden = true
        
        if self.playlistViewModel != nil {
            self.playlistViewModel.changeCountDownDuration(for: self.playlistViewModel.currentPracticeEntry.entryId, duration: self.countDownDuration)
            self.playlistViewModel.updateCountDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, time: 0)
        }
        
        self.secondsPrevCountDownPlayed = self.countDownPlayed ?? 0
        self.countdownTimerStarted = Date()
        self.timerDirection = 1
        
        self.generateCountdownLocalNotification(date: Date().addingTimeInterval(TimeInterval(self.countDownDuration - self.countDownPlayed)))
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        self.timerRunning = true
    }
    
    func startCountUp(from: Int) {
        if self.timer != nil && self.timerRunning {
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.countDownDuration = 0
        self.countDownPlayed = 0
        
        self.viewTimeArea.isHidden = false
        self.buttonTimerUpDownArrow.isHidden = false
        self.labelTimerUp.isHidden = true
        self.viewTimeAreaPausedPanel.isHidden = true
        
        if self.playlistViewModel != nil {
            self.playlistViewModel.changeCountDownDuration(for: self.playlistViewModel.currentPracticeEntry.entryId, duration: 0)
            self.playlistViewModel.updateCountDownPlayedTime(forPracticeItem: self.playlistViewModel.currentPracticeEntry.entryId, time: 0)
        }

        self.countupTimerStarted = Date()
        self.secondsPrevCountUpPlayed = from
        self.timerDirection = 0
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        self.timerRunning = true
        
        self.cancelCountDownNotification()
    }
    
    func onTimerDismiss() {
        self.closeTimer()
    }
    
    func cancelCountDownNotification() {
        if let oldNotification = self.countDownNotification {
            UIApplication.shared.cancelLocalNotification(oldNotification)
            self.countDownNotification = nil
        }
    }
    
    func generateCountdownLocalNotification(date: Date) {
        
        self.cancelCountDownNotification()
        
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = "TIME'S UP"
        notification.alertAction = "timesup"
        notification.hasAction = true
        UIApplication.shared.scheduleLocalNotification(notification)
        
        self.countDownNotification = notification
    }
}

extension PracticeViewController: PracticeBreakPromptViewDelegate {
    func dismiss(practiceBreakPromptView: PracticeBreakPromptView) {
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
            self.viewPracticeBreakPrompt = nil
            self.onTapTimer(self.view)
        }
    }
}
