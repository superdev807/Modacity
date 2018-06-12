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
    @IBOutlet weak var viewImprovedYesPanel: UIView!
    @IBOutlet weak var viewImprovedAlert: UIView!
    @IBOutlet weak var viewRatePanel: UIView!
    @IBOutlet weak var imageViewRateDirection: UIImageView!
    @IBOutlet weak var labelRateValue: UILabel!
    
    var metrodroneViewShown = false
    var metrodroneView: MetrodroneView? = nil
    var metrodroneViewTopConstraint: NSLayoutConstraint!
    var subdivisionView: SubdivisionSelectView? = nil
    
    @IBOutlet weak var viewBottomXBar: UIView!
    
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
        self.labelSuggestion.text = self.viewModel.selectedSuggestion
        
        if AppUtils.sizeModelOfiPhone() == .iphone6p_55in {
        }
        
        self.initializeDroneUIs()
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
        self.navigationController?.popViewController(animated: true)
        
    }
}

// MARK: - Drone processing
extension ImprovementViewController: MetrodroneViewDelegate, SubdivisionSelectViewDelegate {

    @objc func processRouteChange() {
        if let player = self.metrodroneView?.metrodonePlayer {
            player.stopPlayer()
            self.self.metrodroneView?.metrodonePlayer = nil
            self.self.metrodroneView?.prepareMetrodrone()
        }
    }
    
    func initializeDroneUIs() {
        self.metrodroneView = MetrodroneView()
        self.view.addSubview(self.metrodroneView!)
        self.view.leadingAnchor.constraint(equalTo: self.metrodroneView!.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.metrodroneView!.trailingAnchor).isActive = true
        self.metrodroneView!.heightAnchor.constraint(equalToConstant: 360).isActive = true
        self.metrodroneView!.delegate = self
        self.metrodroneViewTopConstraint = self.view.bottomAnchor.constraint(equalTo: self.metrodroneView!.topAnchor)
        self.metrodroneViewTopConstraint?.constant = 44
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
            player.setSubdivision(idx + 1)
        }
    }
    
    func showMetrodroneView() {
        
        if !self.metrodroneViewShown {
            
            ModacityAnalytics.LogEvent(.MetrodroneDrawerOpen)
            self.metrodroneView!.isHidden = false
            self.metrodroneViewTopConstraint.constant = 360
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
            
            self.metrodroneViewTopConstraint.constant = 44
            
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
