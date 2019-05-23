//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Charts
import AVFoundation

protocol RecordingsListViewDelegate {
    func onShareRecording(text: String, url: URL)
}

class RecordingsListView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var recordings: [Recording] = [Recording]()
    var playingRecording: Recording? = nil
    var audioPlayer : AVAudioPlayer? = nil
    var audioPlaying = false
    var audioPlayerTimer: Timer?
    var currentRate = 1.0
    var delegate: RecordingsListViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RecordingsListView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewMain.register(UINib(nibName: "RecordingCell", bundle: nil), forCellReuseIdentifier: "RecordingCell")
        self.audioPlayerTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(audioPlayingProgressUpdate), userInfo: nil, repeats: true)
        self.tableViewMain.tableFooterView = UIView()
    }
    
    func showRecordings(_ recordings:[Recording]) {
        self.recordings = recordings
        self.tableViewMain.reloadData()
    }
    
    func cleanPlaying() {
        self.stopPlaying()
        if let timer = self.audioPlayerTimer {
            timer.invalidate()
            self.audioPlayerTimer = nil
        }
    }
    
    func stopPlaying() {
        if let player = self.audioPlayer {
            player.stop()
            self.audioPlayer = nil
            self.playingRecording = nil
        }
    }
}

extension RecordingsListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let recording = self.recordings[indexPath.row]
        var rowIsPlaying = false
        if let currentPlaying = self.playingRecording {
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
        let recording = self.recordings[indexPath.row]
        var rowIsPlaying = false
        if let currentPlaying = self.playingRecording {
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
    
}

extension RecordingsListView: RecordingCellDelegate {
    
    func onPlayOrPause(_ recording:Recording) {
        
        if let currentPlaying = self.playingRecording {
            if currentPlaying.id == recording.id {
                self.onAudioPlayOrPause()
                return
            }
        }
        
        self.expandRecordingCell(recording: recording)
        self.onAudioPlayOrPause()
    }
    
    func expandRecordingCell(recording:Recording) {
        if let currentPlaying = self.playingRecording {
            if currentPlaying.id == recording.id {
                self.playingRecording = nil
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
        
        self.playingRecording = recording
        self.tableViewMain.reloadData()
    }
    
    func onAudioPlayOrPause() {
        if self.audioPlayer == nil {
            self.prepareAudio()
        }
        
        if !self.audioPlaying {
            self.audioPlaying = true
            self.audioPlayer!.play()
            ModacityAnalytics.LogStringEvent("Recordings Tab: Play")
        } else {
            self.audioPlaying = false
            self.audioPlayer!.pause()
            ModacityAnalytics.LogStringEvent("Recordings Tab: Pause")
        }
        
        if let cell = self.playingCell() {
            if self.audioPlaying {
                cell.buttonAudioPlaying.setImage(UIImage(named:"icon_pause_white"), for: .normal)
                cell.imageViewPlayIcon.image = UIImage(named:"icon_pause_white")
            } else {
                cell.buttonAudioPlaying.setImage(UIImage(named:"icon_play"), for: .normal)
                cell.imageViewPlayIcon.image = UIImage(named:"icon_play")
            }
        }
    }
    
    func playingCell() -> RecordingCell? {
        return self.tableViewMain.cellForRow(at: IndexPath(row: self.playingRow(), section: 0)) as? RecordingCell
    }
    
    func playingRow() -> Int {
        if let playing = self.playingRecording {
            for idx in 0..<self.recordings.count {
                if self.recordings[idx].id == playing.id {
                    return idx
                }
            }
        }
        return -1
    }
    
    func onAudioSeekTo(_ time:Double) {
        if let player = self.audioPlayer {
            player.currentTime = player.duration * time
        }
    }
    
    func onAudioBackward() {
        if let player = self.audioPlayer {
//            self.currentRate = self.currentRate / 2.0
//            if self.currentRate < 1 / 16.0 {
//                self.currentRate = 1.0
//            }
            
            var newRate = 1.0
            
            switch(self.currentRate) {
            case 1.5:
                newRate = 2.0
            case 1.4:
                newRate = 1.5
            case 1.3:
                newRate = 1.4
            case 1.2:
                newRate = 1.3
            case 1.1:
                newRate = 1.2
            case 1:
                newRate = 1.1
            default:
                // covers the case where rate = 8x
                // and the case when user has been slow playing
                // and wants to reset to 1.0
                newRate = 1.0
            }
            
            self.currentRate = newRate
            
            player.rate = Float(self.currentRate)
            if let cell = self.playingCell() {
                cell.processsAudioPlaybackRate(player: player)
            }
        }
    }
    
    func onAudioForward() {
        if let player = self.audioPlayer {
//            self.currentRate = self.currentRate * 2.0
//            if self.currentRate > 16.0 {
//                self.currentRate = 1.0
//            }
            
            var newRate = 1.0
            
            switch(self.currentRate) {
            case 0.6:
                newRate = 0.5
            case 0.7:
                newRate = 0.6
            case 0.8:
                newRate = 0.7
            case 0.9:
                newRate = 0.8
            case 1.0:
                newRate = 0.9
            default:
                newRate = 1.0
            }
            
            self.currentRate = newRate
            player.rate = Float(self.currentRate)
            if let cell = self.playingCell() {
                cell.processsAudioPlaybackRate(player: player)
            }
        }
    }
    
    func onAudioToFirst() {
        if let player = self.audioPlayer {
            player.currentTime = 0
        }
    }
    
    func onShare(_ recording:Recording) {
        if let delegate = self.delegate {
            
            let shareText = "My recording for " + recording.practiceName
            
            ModacityAnalytics.LogStringEvent("Shared Recording", extraParamName: "name", extraParamValue: recording.fileName)
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let targetUrl = URL(fileURLWithPath: dirPath[0] + "/" + recording.fileName + AppConfig.Constants.appSavedAudioFileExtension)
        
            delegate.onShareRecording(text: shareText, url: targetUrl)
        }
    }
    
    func onDelete(_ recording:Recording) {
        ModacityAnalytics.LogStringEvent("Deleted Recording", extraParamName: "name", extraParamValue: recording.fileName)
        if let playingRecording = self.playingRecording {
            if playingRecording.id == recording.id {
                self.audioPlaying = false
                if let player = self.audioPlayer {
                    player.stop()
                }
                self.audioPlayer = nil
            }
            self.deleteRecording(for: recording)
        } else {
            self.deleteRecording(for: recording)
        }
    }
    
    func onExpand(_ recording: Recording) {
        self.expandRecordingCell(recording: recording)
    }
    
    func onMenu(_ buttonMenu: UIButton, recording: Recording) {
        
        DropdownMenuView.instance.show(in: self.viewContent,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_share_white", "text": "Share"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                if row == 1 {
                                                    self.onDelete(recording)
                                                } else  {
                                                    self.onShare(recording)
                                                }
        }
        
    }
    
}

extension RecordingsListView: AVAudioPlayerDelegate {
    
    func prepareAudio() {
        
        if let recording = self.playingRecording {
            if let filePath = recording.filePath() {
                let url = URL(fileURLWithPath: filePath)
                
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    guard let player = self.audioPlayer else { return }
                    player.enableRate = true
                    player.prepareToPlay()
                    currentRate = 1.0
                    player.delegate = self
                } catch let error {
                    ModacityDebugger.debug("Audio player error \(error.localizedDescription)")
                }
            } else {
                ModacityDebugger.debug("Audio file deleted")
            }
        }
        
    }
    
    @objc func audioPlayingProgressUpdate() {
        if let _ = self.playingRecording {
            if let player = self.audioPlayer {
                if let cell = self.playingCell() {
                    if player.duration > 0 {
                        let samples = Int(Double(cell.waveformAudio.totalSamples) * (player.currentTime / player.duration))
                        ModacityDebugger.debug("samples - \(samples), total - \(cell.waveformAudio.totalSamples)")
                        if samples > 0 {
                            cell.waveformAudio.highlightedSamples = 0..<samples
                        }
                    }
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
            cell.imageViewPlayIcon.image = UIImage(named:"icon_play")
            cell.waveformAudio.highlightedSamples = 0..<cell.waveformAudio.totalSamples
        }
    }
}

extension RecordingsListView {
    
    func deleteRecording(at row: Int) {
        
        let recordingToRemove = self.recordings[row]
        do {
            if let filePath = recordingToRemove.filePath() {
                let url = URL(fileURLWithPath: filePath)
                try FileManager.default.removeItem(at: url)
            } else {
                ModacityDebugger.debug("No file exists")
            }
        } catch let error as NSError {
            ModacityDebugger.debug("file removing error - \(error.localizedDescription)")
        }
        
        self.recordings.remove(at: row)
        RecordingsLocalManager.manager.removeRecording(forId: recordingToRemove.id)
        self.tableViewMain.reloadData()
        
    }
    
    func deleteRecording(for recording:Recording) {
        do {
            if let filePath = recording.filePath() {
                let url = URL(fileURLWithPath: filePath)
                try FileManager.default.removeItem(at: url)
            } else {
                ModacityDebugger.debug("No file exists")
            }
        } catch let error as NSError {
            ModacityDebugger.debug("file removing error - \(error.localizedDescription)")
        }
        
        for idx in 0..<self.recordings.count {
            if self.recordings[idx].id == recording.id {
                self.recordings.remove(at: idx)
                break
            }
        }
        
        RecordingsLocalManager.manager.removeRecording(forId: recording.id)
        self.tableViewMain.reloadData()
    }
}
