//
//  RecordingCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 23/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FDWaveformView
import AVFoundation

protocol RecordingCellDelegate {
    func onPlayOrPause(_ recording:Recording)
    func onExpand(_ recording:Recording)
    func onAudioPlayOrPause()
    func onAudioBackward()
    func onAudioForward()
    func onAudioToFirst()
    func onAudioSeekTo(_ time:Double)
    func onShare(_ recording:Recording)
    func onDelete(_ recording:Recording)
    func onMenu(_ buttonMenu: UIButton, recording:Recording)
}

class RecordingCell: UITableViewCell, FDWaveformViewDelegate {
    
    @IBOutlet weak var imageViewPlayIcon: UIImageView!
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var labelRecordedTime: UILabel!
    @IBOutlet weak var viewPlayingPanel: UIView!
    @IBOutlet weak var waveformAudio: FDWaveformView!
    @IBOutlet weak var buttonAudioPlaying: UIButton!
    @IBOutlet weak var labelCurrentTime: UILabel!
    @IBOutlet weak var labelRemainingTime: UILabel!
    @IBOutlet weak var buttonRemove: UIButton!
    
    @IBOutlet weak var viewAudioPlaybackRatePanel: UIView!
    @IBOutlet weak var labelAudioPlaybackRateValue: UILabel!
    @IBOutlet weak var imageViewAudioPlaybackRate: UIImageView!
    @IBOutlet weak var buttonMenu: UIButton!
    
    @IBOutlet weak var viewNoAudioFilePanel: UIView!
    
    var recording: Recording!
    var delegate: RecordingCellDelegate? = nil
    
    func configure(with recording:Recording, isPlaying: Bool, isAudioPlaying: Bool, withAudioPlayer: AVAudioPlayer?) {
        
        self.recording = recording
        self.labelPracticeName.text = recording.practiceName + " - " + recording.fileName
        self.labelRecordedTime.text = (Date(timeIntervalSince1970: Double(recording.createdAt) ?? 0)).toString(format: "MM/dd/yy @ h:mm a")
        self.viewAudioPlaybackRatePanel.isHidden = true
        
        if isPlaying {
            self.viewPlayingPanel.isHidden = false
            self.viewNoAudioFilePanel.isHidden = true
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let soundFilePath = dirPath[0] + "/" + recording.fileName +  AppConfig.Constants.appSavedAudioFileExtension
            
            
            let fileManager = FileManager.default
            
            let url = URL(fileURLWithPath: soundFilePath)
            
            if fileManager.fileExists(atPath: url.path)  {
                self.waveformAudio.audioURL = url
                self.waveformAudio.doesAllowStretch = false
                self.waveformAudio.doesAllowScroll = false
                self.waveformAudio.doesAllowScrubbing = true
                self.waveformAudio.wavesColor = Color.white.alpha(0.5)
                self.waveformAudio.progressColor = Color.white
                self.waveformAudio.delegate = self
                
                if isAudioPlaying {
                    self.buttonAudioPlaying.setImage(UIImage(named:"icon_pause_white"), for: .normal)
                    self.imageViewPlayIcon.image = UIImage(named:"icon_pause_white")
                } else {
                    self.buttonAudioPlaying.setImage(UIImage(named:"icon_play"), for: .normal)
                    self.imageViewPlayIcon.image = UIImage(named:"icon_play")
                }
                
                if let player = withAudioPlayer {
                    if player.duration > 0 {
                        let samples = Int(Double(self.waveformAudio.totalSamples) * (player.currentTime / player.duration))
                        ModacityDebugger.debug("samples - \(samples), total - \(self.waveformAudio.totalSamples)")
                        if samples > 0 {
                            self.waveformAudio.highlightedSamples = 0..<samples
                        }
                    }
                    self.labelCurrentTime.text = String(format:"%d:%02d", Int(player.currentTime) / 60, Int(player.currentTime) % 60)
                    self.labelRemainingTime.text = String(format:"-%d:%02d", Int(player.duration - player.currentTime) / 60, Int(player.duration - player.currentTime) % 60)
                }
            } else {
                self.viewPlayingPanel.isHidden = true
                self.viewNoAudioFilePanel.isHidden = false
            }
            
        } else {
            self.imageViewPlayIcon.image = UIImage(named: "icon_play")
            self.viewPlayingPanel.isHidden = true
        }
    }
    
    func processsAudioPlaybackRate(player: AVAudioPlayer) {
        
        if player.rate == 1.0 {
            self.viewAudioPlaybackRatePanel.isHidden = true
        } else {
            self.viewAudioPlaybackRatePanel.isHidden = false
            if player.rate < 1.0 {
                self.imageViewAudioPlaybackRate.image = UIImage(named:"icon_backward")
                self.labelAudioPlaybackRateValue.text = "x \(Int(1 / player.rate))"
            } else {
                self.imageViewAudioPlaybackRate.image = UIImage(named:"icon_forward_white")
                self.labelAudioPlaybackRateValue.text = "x \(Int(player.rate))"
            }
        }
    }
    
    func waveformDidEndScrubbing(_ waveformView: FDWaveformView) {
        if let delegate = self.delegate {
            if self.waveformAudio.totalSamples > 0 {
                delegate.onAudioSeekTo(Double(self.waveformAudio.highlightedSamples?.count ?? 0) / Double(self.waveformAudio.totalSamples))
            }
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
    
    @IBAction func onExpand(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onExpand(self.recording)
        }
    }
    
    @IBAction func onShare(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onShare(self.recording)
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onMenu(self.buttonMenu, recording: self.recording)
        }
    }
}
