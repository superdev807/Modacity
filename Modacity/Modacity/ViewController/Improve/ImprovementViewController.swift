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
    
    @IBOutlet weak var viewMinimizedDrone: UIView!
    @IBOutlet weak var viewMaximizedDrone: UIView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var imageViewHeader: UIImageView!
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var constraintForMaximizedDroneBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var waveformAudioPlay: FDWaveformView!
    @IBOutlet weak var viewAudioPlayer: UIView!
    @IBOutlet weak var viewSiriWaveFormView: SCSiriWaveformView!
    
    @IBOutlet weak var buttonAudioPlay: UIButton!
    
    @IBOutlet weak var labelPlayerRemainsTime: UILabel!
    @IBOutlet weak var labelPlayerCurrentTime: UILabel!
    
    @IBOutlet weak var labelHypothesis: UILabel!
    @IBOutlet weak var labelSuggestion: UILabel!
    @IBOutlet weak var labelImprovementNote: UILabel!
    
    @IBOutlet weak var viewImprovedYesPanel: UIView!
    @IBOutlet weak var viewImprovedAlert: UIView!
    
    var playlistViewModel: PlaylistDetailsViewModel!
    var viewModel: ImprovementViewModel!
    
    var recorder: AVAudioRecorder!
    var isRecording = false
    
    var player: AVAudioPlayer?
    var audioPlayerTimer: Timer?
    var isPlaying = false
    
    @IBOutlet weak var viewBottomXBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.viewBottomXBar.backgroundColor = Color(hexString:"#292a4a")
        
        self.constraintForMaximizedDroneBottomSpace.constant =  self.view.bounds.size.height * 336/667 - 40
        self.labelPracticeItemName.text = self.playlistViewModel.currentPracticeItem.name
        self.viewSiriWaveFormView.isHidden = true
        self.viewAudioPlayer.isHidden = true
        
        self.labelHypothesis.text = self.viewModel.selectedHypothesis
        self.labelSuggestion.text = self.viewModel.selectedSuggestion
        self.labelImprovementNote.isHidden = false
        self.viewImprovedAlert.isHidden = true
        self.viewImprovedYesPanel.isHidden = true
    }
    
    deinit {
        if self.audioPlayerTimer != nil {
            self.audioPlayerTimer!.invalidate()
            self.audioPlayerTimer = nil
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
    
    @IBAction func onEnd(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onShowDrones(_ sender: Any) {
        self.viewMaximizedDrone.isHidden = false
        self.constraintForMaximizedDroneBottomSpace.constant = 0
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onHideDrones(_ sender: Any) {
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
    
    @IBAction func onImprove(_ sender: Any) {
        let controller = UIStoryboard(name: "improve", bundle: nil).instantiateViewController(withIdentifier: "improve_scene") as! UINavigationController
        let root = controller.viewControllers[0] as! ImproveSuggestionViewController
        root.playlistModel = self.playlistViewModel
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onAskExpert(_ sender: Any) {
        
        let controller = UIStoryboard(name:"feedback", bundle:nil).instantiateViewController(withIdentifier: "feedbackscene") as! UINavigationController
        let feedbackRootViewController = controller.viewControllers[0] as! FeedbackRootViewController
        feedbackRootViewController.pageIsRootFromMenu = false
        feedbackRootViewController.pageUIMode = 0
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func onFeedback(_ sender: Any) {
        let controller = UIStoryboard(name:"feedback", bundle:nil).instantiateViewController(withIdentifier: "feedbackscene") as! UINavigationController
        let feedbackRootViewController = controller.viewControllers[0] as! FeedbackRootViewController
        feedbackRootViewController.pageIsRootFromMenu = false
        feedbackRootViewController.pageUIMode = 1
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onImprovedNo(_ sender: Any) {
        self.viewModel.alreadyTried = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onImprovedYes(_ sender: Any) {
        self.playlistViewModel.addNewImprovement(self.viewModel.generateImprovement(with: self.playlistViewModel.playlist, practice: self.playlistViewModel.currentPracticeItem))
        self.viewImprovedAlert.isHidden = true
        self.viewImprovedYesPanel.isHidden = false
    }
    
    @IBAction func onImprovedNext(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onImproveAgain(_ sender: Any) {
        self.viewModel.alreadyTried = true
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ImprovementViewController: AVAudioPlayerDelegate {
    
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
            player.prepareToPlay()
            
            player.delegate = self
            
        } catch let error {
            print("Audio player error \(error)")
        }
        
        self.isPlaying = false
        
        self.waveformAudioPlay.audioURL = url
        self.waveformAudioPlay.doesAllowStretch = false
        self.waveformAudioPlay.doesAllowScroll = false
        self.waveformAudioPlay.doesAllowScrubbing = false
        self.waveformAudioPlay.wavesColor = Color.white.alpha(0.5)
        self.waveformAudioPlay.progressColor = Color.white
        
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
            if let player = player {
                player.play()
            }
            self.isPlaying = true
            self.buttonAudioPlay.setImage(UIImage(named: "icon_pause_white"), for: .normal)
        }
    }
    
    @IBAction func onAudioBackward(_ sender: Any) {
        if let player = player {
            player.currentTime = player.currentTime - 1.0
        }
    }
    
    @IBAction func onAudioForward(_ sender: Any) {
        if let player = player {
            player.currentTime = player.currentTime + 1.0
        }
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
}
