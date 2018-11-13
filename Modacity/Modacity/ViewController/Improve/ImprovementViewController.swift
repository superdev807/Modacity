//
//  ImprovementViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/10/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SCSiriWaveformView
import FDWaveformView
import MBProgressHUD

class ImprovementViewController: UIViewController {
    
    var playlistViewModel: PlaylistContentsViewModel!
    var practiceItem: PracticeItem!
    var viewModel: ImprovementViewModel!
    var deliverModel: PlaylistAndPracticeDeliverModel!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var imageViewHeader: UIImageView!
    @IBOutlet weak var labelHypothesis: UILabel!
    @IBOutlet weak var labelImprovementNote: UILabel!
    @IBOutlet weak var buttonSaveRecord: UIButton!
    
    var recorder: AVAudioRecorder!
    var isRecording = false
    @IBOutlet weak var btnRecord: UIButton!
    
    @IBOutlet weak var viewWaveformContainer: UIView!
    var viewSiriWaveFormView: SCSiriWaveformView!
    
    var player: AVAudioPlayer?
    var audioPlayerTimer: Timer?
    var isPlaying = false
    var currentRate = 1.0
    
    @IBOutlet weak var waveformAudioPlay: FDWaveformView!
    @IBOutlet weak var viewAudioPlayer: UIView!
    @IBOutlet weak var buttonAudioPlay: UIButton!
    @IBOutlet weak var labelPlayerRemainsTime: UILabel!
    @IBOutlet weak var labelPlayerCurrentTime: UILabel!
//    @IBOutlet weak var viewImprovedYesPanel: UIView!
    @IBOutlet weak var viewImprovedAlert: UIView!
    @IBOutlet weak var viewRatePanel: UIView!
    @IBOutlet weak var imageViewRateDirection: UIImageView!
    @IBOutlet weak var labelRateValue: UILabel!
    
    var metrodroneViewShown = false
    var metrodroneView: MetrodroneView? = nil
    var metrodroneViewTopConstraint: NSLayoutConstraint!
    var subdivisionView: SubdivisionSelectView? = nil
    var heightOfMetrodroneView = (AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in) ? CGFloat(320) : CGFloat(360)
    
    @IBOutlet weak var viewBottomXBar: UIView!
    
    var donePopupView: ImprovedDonePopupView?
    
    // MARK: - Properties for drone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.playlistViewModel != nil {
            self.labelPracticeItemName.text = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelPracticeItemName.text = self.practiceItem.name ?? ""
        }
        
        self.labelHypothesis.text = self.viewModel.selectedHypothesis
        
        switch AppUtils.sizeModelOfiPhone() {
        case .iphone4_35in:
            heightOfMetrodroneView = 320
        case .iphone5_4in:
            heightOfMetrodroneView = 320
        case .iphone6_47in:
            heightOfMetrodroneView = 360
        case .iphone6p_55in:
            heightOfMetrodroneView = 360
        case .iphoneX_xS:
            heightOfMetrodroneView = 400
        case .iphonexR_xSMax:
            heightOfMetrodroneView = 400
        case .unknown:
            break
        }
        
        self.buttonSaveRecord.alpha = 0.5
        self.buttonSaveRecord.isEnabled = false
        
        self.initializeDroneUIs()
        self.initializeAudioPlayerUI()
        self.viewAudioPlayer.isHidden = true
        
        self.initializeImproveActionViews()
        NotificationCenter.default.addObserver(self, selector: #selector(resetMetrodroneEngine), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
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
        
        if let metrodroneView = self.metrodroneView {
            metrodroneView.viewDidDisappear()
        }
    }
    
    @IBAction func onEnd(_ sender: Any) {
        
        if self.recorder != nil && self.recorder.isRecording {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please stop recording before leaving the page.")
            return
        }
        ModacityAnalytics.LogStringEvent("Exited Hypothesis Test Screen")
        self.stopMetrodronePlay()
        self.navigationController?.popViewController(animated: true)
        
    }
}

// MARK: - Drone processing
extension ImprovementViewController: MetrodroneViewDelegate, SubdivisionSelectViewDelegate {

    @objc func processRouteChange() {
        DispatchQueue.main.async {
            if let player = self.metrodroneView?.metrodonePlayer {
                player.stopPlayer()
                self.metrodroneView?.metrodonePlayer = nil
                self.metrodroneView?.prepareMetrodrone()
            }
        }
    }
    
    @objc func resetMetrodroneEngine() {
        if let player = self.metrodroneView?.metrodonePlayer {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            player.stopPlayer()
            self.metrodroneView?.metrodonePlayer = nil
            self.metrodroneView?.prepareMetrodrone()
            
            self.perform(#selector(processAudioEnginePrepared), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func processAudioEnginePrepared() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func initializeDroneUIs() {
        self.metrodroneView = MetrodroneView()
        self.view.addSubview(self.metrodroneView!)
        self.view.leadingAnchor.constraint(equalTo: self.metrodroneView!.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.metrodroneView!.trailingAnchor).isActive = true
        self.metrodroneView!.heightAnchor.constraint(equalToConstant: heightOfMetrodroneView).isActive = true
        self.metrodroneView!.delegate = self
        if #available(iOS 11.0, *) {
            self.metrodroneViewTopConstraint = self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
        } else {
            self.metrodroneViewTopConstraint = self.view.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
        }
        if AppUtils.sizeModelOfiPhone() == .iphonexR_xSMax {
            self.metrodroneViewTopConstraint?.constant = 24
        } else {
            self.metrodroneViewTopConstraint?.constant = 44
        }
        self.metrodroneViewTopConstraint?.isActive = true
        self.metrodroneView!.initializeDroneUIs()
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
            let subdivision = idx + 1
            if (MetrodroneParameters.instance.subdivisions == subdivision) {
                if let subdivisionView = self.subdivisionView {
                    subdivisionView.isHidden = true
                }
            } else {
                player.setSubdivision(subdivision)
            }
        }
    }
    
    func showMetrodroneView() {
        
        if !self.metrodroneViewShown {
            
            ModacityAnalytics.LogEvent(.MetrodroneDrawerOpen)
            self.metrodroneView!.isHidden = false
            self.metrodroneViewTopConstraint.constant = heightOfMetrodroneView
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (finished) in
                if finished {
                    self.metrodroneView!.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_down")
                    self.metrodroneViewShown = true
                }
            }
            
        } else {
            
            if self.subdivisionView != nil && self.subdivisionView!.isHidden == false {
                self.subdivisionView!.isHidden = true
            }
            
            if AppUtils.sizeModelOfiPhone() == .iphonexR_xSMax {
                self.metrodroneViewTopConstraint.constant = 24
            } else {
                self.metrodroneViewTopConstraint.constant = 44
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (finished) in
                if finished {
                    self.metrodroneView!.imageViewMetrodroneViewShowingArrow.image = UIImage(named:"icon_arrow_up")
                    self.metrodroneViewShown = false
                }
            }
        }
    }
    
    @IBAction func onTabDrone() {
        self.showMetrodroneView()
    }
}

// MARK: - Audio playing
extension ImprovementViewController: AVAudioPlayerDelegate, FDWaveformViewDelegate {
    
    func initializeAudioPlayerUI() {
        self.viewWaveformContainer.isHidden = true
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
        self.viewWaveformContainer.isHidden = true
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
        
        self.audioPlayerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onAudioPlayerTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onAudioPlayerTimer() {
        if let player = self.player {
            if player.duration > 0 {
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
            self.pauseAudio()
        } else {
            self.startPlayAudio()
        }
    }
    
    func pauseAudio() {
        if let player = player {
            player.pause()
        }
        self.isPlaying = false
        self.buttonAudioPlay.setImage(UIImage(named: "icon_play"), for: .normal)
    }
    
    func startPlayAudio() {
        if let player = player {
            player.play()
        }
        self.isPlaying = true
        self.buttonAudioPlay.setImage(UIImage(named: "icon_pause_white"), for: .normal)
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
            textField.clearButtonMode = UITextFieldViewMode.always
            
            if self.playlistViewModel != nil {
                if var practiceName = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name {
                    AppOveralDataManager.manager.increaseAutoIncrementedNumber()
                    practiceName = String(practiceName.prefix(16))
                    let autoIncrementedNumber = AppOveralDataManager.manager.fileNameAutoIncrementedNumber()
                    textField.text = "\(practiceName)_\(Date().toString(format: "yyyyMMdd"))_\(String(format:"%02d", autoIncrementedNumber))"
                }
            } else {
                if var practiceName = self.practiceItem.name {
                    AppOveralDataManager.manager.increaseAutoIncrementedNumber()
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
                    } else if self.practiceItem != nil {
                        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: name, playlistId: "practice-\(self.practiceItem.id)", practiceName: self.practiceItem.name ?? "", practiceEntryId: self.practiceItem.id, practiceItemId: self.practiceItem.id)
                    }
                    
                    self.buttonSaveRecord.alpha = 0.5
                    self.buttonSaveRecord.isEnabled = false
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
            if self.waveformAudioPlay.totalSamples > 0 {
                player.currentTime = player.duration * (Double(self.waveformAudioPlay.highlightedSamples?.count ?? 0) / Double(self.waveformAudioPlay.totalSamples))
            }
        }
    }
}

// MARK: - Audio recording
extension ImprovementViewController {
    @IBAction func onRecordStart(_ sender: Any) {
        
        if !self.isRecording {
            
            self.labelImprovementNote.isHidden = true
            self.viewAudioPlayer.isHidden = true
            self.viewWaveformContainer.isHidden = false
            if self.viewSiriWaveFormView == nil {
                self.viewSiriWaveFormView = SCSiriWaveformView()
                self.viewSiriWaveFormView.backgroundColor = Color.clear
                self.viewSiriWaveFormView.translatesAutoresizingMaskIntoConstraints = false
                self.viewWaveformContainer.addSubview(self.viewSiriWaveFormView)
                self.viewWaveformContainer.leadingAnchor.constraint(equalTo: self.viewSiriWaveFormView.leadingAnchor).isActive = true
                self.viewWaveformContainer.trailingAnchor.constraint(equalTo: self.viewSiriWaveFormView.trailingAnchor).isActive = true
                self.viewWaveformContainer.topAnchor.constraint(equalTo: self.viewSiriWaveFormView.topAnchor).isActive = true
                self.viewWaveformContainer.bottomAnchor.constraint(equalTo: self.viewSiriWaveFormView.bottomAnchor).isActive = true
            }
            self.imageViewHeader.image = UIImage(named:"bg_improvement_recording")
            self.btnRecord.setImage(UIImage(named:"btn_record_stop"), for: .normal)
            self.startRecording()
            self.isRecording = true
            
        } else {
            
            self.buttonSaveRecord.alpha = 1.0
            self.buttonSaveRecord.isEnabled = true
            
            self.viewImprovedAlert.isHidden = false
            self.imageViewHeader.image = UIImage(named:"bg_improvement_normal")
            self.btnRecord.setImage(UIImage(named:"img_record"), for: .normal)
            
            self.stopRecording()
            self.isRecording = false
            self.btnRecord.isHidden = true
            self.prepareAudioPlay()
            
            if !AppOveralDataManager.manager.settingsDisableAutoPlayback() {
                if let player = self.metrodroneView?.metrodonePlayer {
                    player.stopPlayer()
                }
                self.startPlayAudio()
            }
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
            ModacityDebugger.debug("recorder error : \(error)")
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
    }
    
    @IBAction func onImprovedNo(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Hypothesis Didn't Work")
        self.viewModel.alreadyTried = true
        self.stopMetrodronePlay()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onImprovedYes(_ sender: Any) {
       ModacityAnalytics.LogStringEvent("Hypothesis Worked")
        self.showDonePopup()
    }
    
    func stopMetrodronePlay() {
        if let metrodroneView = self.metrodroneView {
            if let mPlayer = metrodroneView.metrodonePlayer {
                mPlayer.stopPlayer()
            }
        }
    }
}

extension ImprovementViewController: ImprovedDonePopupViewDelegate {
    
    func showDonePopup() {
        let popupView = ImprovedDonePopupView()
        self.view.addSubview(popupView)
        self.view.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: popupView.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        popupView.delegate = self
        self.donePopupView = popupView
    }
    
    func onPopupButtonNo() {
        ModacityAnalytics.LogStringEvent("Don't Practice Hypothesis Again")
        self.generateImprovedRecord()
        self.stopMetrodronePlay()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func onPopupButtonYes() {
        ModacityAnalytics.LogStringEvent("Practice Same Hypothesis Again")
        self.viewModel.alreadyTried = true
        self.btnRecord.isHidden = false
        
        if self.isPlaying {
            self.onPlayPauseAudio(self)
        }
        
        self.viewWaveformContainer.isHidden = true
        self.viewAudioPlayer.isHidden = true
        self.viewRatePanel.isHidden = true
        self.labelImprovementNote.isHidden = true
        self.viewAudioPlayer.isHidden = true
        self.labelImprovementNote.isHidden = false
        
        self.viewImprovedAlert.isHidden = true
        
        if let popupView = self.donePopupView {
            popupView.removeFromSuperview()
            self.donePopupView = nil
        }
    }

    func generateImprovedRecord() {
        let improvedRecord = ImprovedRecord()
        improvedRecord.suggestion = self.viewModel.selectedSuggestion
        improvedRecord.hypothesis = self.viewModel.selectedHypothesis
        if self.playlistViewModel != nil {
            self.playlistViewModel.sessionImproved.append(improvedRecord)
            self.playlistViewModel.addNewImprovement(self.viewModel.generateImprovement(with: self.playlistViewModel.playlist, practice: self.playlistViewModel.currentPracticeEntry))
            self.playlistViewModel.addImprovedNote(to: self.playlistViewModel.currentPracticeEntry, improved: improvedRecord)
        } else {
            self.deliverModel.sessionImproved.append(improvedRecord)
            
            if self.deliverModel.deliverPracticeItem != nil {
                self.deliverModel.deliverPracticeItem.addImprovedNote(improvedRecord)
            }
            AppOveralDataManager.manager.addImprovementsCount()
        }
        
        self.viewModel.processSuggestionCustomization()
    }
}
