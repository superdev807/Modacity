//
//  RecordingViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/10/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FDWaveformView
import AVFoundation

protocol RecordingCellDelegate {
    func onPlayOrPause(_ recording:Recording)
    func onAudioPlayOrPause()
    func onAudioBackward()
    func onAudioForward()
    func onAudioToFirst()
    
    func onShare(_ recording:Recording)
    func onDelete(_ recording:Recording)
}

class RecordingCell: UITableViewCell {
    
    @IBOutlet weak var imageViewPlayIcon: UIImageView!
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var labelRecordedTime: UILabel!
    @IBOutlet weak var viewPlayingPanel: UIView!
    @IBOutlet weak var waveformAudio: FDWaveformView!
    @IBOutlet weak var buttonAudioPlaying: UIButton!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var labelRemainingTime: UILabel!
    @IBOutlet weak var buttonRemove: UIButton!
    
    var recording: Recording!
    var delegate: RecordingCellDelegate? = nil
    
    func configure(with recording:Recording, isPlaying: Bool, isAudioPlaying: Bool, withAudioPlayer: AVAudioPlayer?) {
        
        self.recording = recording
        self.labelPracticeName.text = recording.practiceName
        self.labelRecordedTime.text = (Date(timeIntervalSince1970: Double(recording.createdAt) ?? 0)).toString(format: "MM/dd/yy @ h:mm a")
        
        if isPlaying {
            self.buttonRemove.isHidden = false
            self.imageViewPlayIcon.image = UIImage(named: "icon_pause_white")
            self.viewPlayingPanel.isHidden = false
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let soundFilePath = dirPath[0] + "/" + recording.fileName + ".wav"
            let url = URL(fileURLWithPath: soundFilePath)
            
            self.waveformAudio.audioURL = url
            self.waveformAudio.doesAllowStretch = false
            self.waveformAudio.doesAllowScroll = false
            self.waveformAudio.doesAllowScrubbing = false
            self.waveformAudio.wavesColor = Color.white.alpha(0.5)
            self.waveformAudio.progressColor = Color.white
            
            if isAudioPlaying {
                self.buttonAudioPlaying.setImage(UIImage(named:"icon_pause_white"), for: .normal)
            } else {
                self.buttonAudioPlaying.setImage(UIImage(named:"icon_play"), for: .normal)
            }
            
            if let player = withAudioPlayer {
                self.waveformAudio.highlightedSamples = 0..<Int(Double(self.waveformAudio.totalSamples) * (player.currentTime / player.duration))
                self.labelCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
                self.labelRemainingTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
            }
            
        } else {
            self.buttonRemove.isHidden = true
            self.imageViewPlayIcon.image = UIImage(named: "icon_play")
            self.viewPlayingPanel.isHidden = true
        }
    }
    
    @IBAction func onRun(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onPlayOrPause(self.recording)
        }
    }
    
    @IBAction func onAudioPlaying(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onAudioPlayOrPause()
        }
    }
    
    @IBAction func onBackward(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onAudioBackward()
        }
    }
    
    @IBAction func onForward(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onAudioForward()
        }
    }
    
    @IBAction func onToFirst(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onAudioToFirst()
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onDelete(self.recording)
        }
    }
    
    @IBAction func onShare(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onShare(self.recording)
        }
    }
}

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    var viewModel = RecordingViewModel()
    
    var audioPlayer : AVAudioPlayer? = nil
    var audioPlaying = false
    var audioPlayerTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableViewMain.tableFooterView = UIView()
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        self.audioPlayerTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { (_) in
            self.audioPlayingProgressUpdate()
        })
        self.bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Playlist"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.loadRecording()
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "recordings") { (_, _, _) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "playingRecording") { (_, _, _) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.loadRecording()
    }
}

extension RecordingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.recordings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let recording = self.viewModel.recordings[indexPath.row]
        var rowIsPlaying = false
        if let currentPlaying = self.viewModel.playingRecording {
            if currentPlaying.id == recording.id {
                rowIsPlaying = true
            }
        }
        if rowIsPlaying {
            return 264
        } else {
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell") as! RecordingCell
        let recording = self.viewModel.recordings[indexPath.row]
        var rowIsPlaying = false
        if let currentPlaying = self.viewModel.playingRecording {
            if currentPlaying.id == recording.id {
                rowIsPlaying = true
            }
        }
        cell.configure(with: recording, isPlaying: rowIsPlaying, isAudioPlaying: self.audioPlaying, withAudioPlayer: self.audioPlayer)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if let currentPlaying = self.viewModel.playingRecording {
            if currentPlaying.id == self.viewModel.recordings[indexPath.row].id {
                return []
            }
        }
        
        let delete = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            self.viewModel.deleteRecording(at: indexPath.row)
        }
        delete.setIcon(iconImage: UIImage(named:"icon_delete_white")!, backColor: Color(hexString: "#6815CE"), cellHeight: 64, iconSizePercentage: 0.25)
        
        return [delete]
        
    }
}

extension RecordingViewController: RecordingCellDelegate {
    
    func onPlayOrPause(_ recording:Recording) {
        if let currentPlaying = self.viewModel.playingRecording {
            if currentPlaying.id == recording.id {
                self.viewModel.playingRecording = nil
                self.audioPlaying = false
                if let player = self.audioPlayer {
                    player.stop()
                }
                self.audioPlayer = nil
                return
            } else {
                self.audioPlaying = false
                if let player = self.audioPlayer {
                    player.stop()
                }
                self.audioPlayer = nil
            }
        }
        self.viewModel.playingRecording = recording
    }
    
    func onAudioPlayOrPause() {
        if self.audioPlayer == nil {
            self.prepareAudio()
        }
        
        if !self.audioPlaying {
            self.audioPlaying = true
            self.audioPlayer!.play()
        } else {
            self.audioPlaying = false
            self.audioPlayer!.pause()
        }
        
        if let cell = self.playingCell() {
            if self.audioPlaying {
                cell.buttonAudioPlaying.setImage(UIImage(named:"icon_pause_white"), for: .normal)
            } else {
                cell.buttonAudioPlaying.setImage(UIImage(named:"icon_play"), for: .normal)
            }
        }
    }
    
    func playingCell() -> RecordingCell? {
        return self.tableViewMain.cellForRow(at: IndexPath(row: self.playingRow(), section: 0)) as? RecordingCell
    }
    
    func playingRow() -> Int {
        if let playing = self.viewModel.playingRecording {
            for idx in 0..<self.viewModel.recordings.count {
                if self.viewModel.recordings[idx].id == playing.id {
                    return idx
                }
            }
        }
        return -1
    }
    
    func onAudioForward() {
        if let player = self.audioPlayer {
            player.currentTime = player.currentTime - 1.0
        }
    }
    
    func onAudioBackward() {
        if let player = self.audioPlayer {
            player.currentTime = player.currentTime + 1.0
        }
    }
    
    func onAudioToFirst() {
        if let player = self.audioPlayer {
            player.currentTime = 0
        }
    }
    
    func onShare(_ recording:Recording) {
        let shareText = "My recording for " + recording.practiceName
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let targetUrl = URL(fileURLWithPath: dirPath[0] + "/" + recording.fileName + ".wav")
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, targetUrl], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func onDelete(_ recording:Recording) {
        if let playingRecording = self.viewModel.playingRecording {
            if playingRecording.id == recording.id {
                self.audioPlaying = false
                if let player = self.audioPlayer {
                    player.stop()
                }
                self.audioPlayer = nil
                self.viewModel.deleteRecording(for: recording)
                return
            }
        } else {
            self.viewModel.deleteRecording(for: recording)
        }
    }
    
}

extension RecordingViewController: AVAudioPlayerDelegate {
    
    func prepareAudio() {
        
        if let recording = self.viewModel.playingRecording {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let soundFilePath = dirPath[0] + "/" + recording.fileName + ".wav"
            let url = URL(fileURLWithPath: soundFilePath)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                guard let player = self.audioPlayer else { return }
                player.prepareToPlay()
                player.delegate = self
            } catch let error {
                print("Audio player error \(error)")
            }
        }
        
    }
    
    func audioPlayingProgressUpdate() {
        if let _ = self.viewModel.playingRecording {
            if let player = self.audioPlayer {
                if let cell = self.playingCell() {
                    cell.waveformAudio.highlightedSamples = 0..<Int(Double(cell.waveformAudio.totalSamples) * (player.currentTime / player.duration))
                    cell.labelCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
                    cell.labelRemainingTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlaying = false
        if let cell = self.playingCell() {
            cell.buttonAudioPlaying.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
}
