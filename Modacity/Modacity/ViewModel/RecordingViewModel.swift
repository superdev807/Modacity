//
//  RecordingViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class RecordingViewModel: ViewModel {
    
    var recordings: [Recording] = [Recording]() {
        didSet {
            if let callback = self.callBacks["recordings"] {
                callback(.simpleChange, oldValue, recordings)
            }
        }
    }
    
    var playingRecording: Recording? = nil {
        didSet{
            if let callback = self.callBacks["playingRecording"] {
                callback(.simpleChange, oldValue, playingRecording)
            }
        }
    }
    
    func loadRecording() {
        self.recordings = RecordingsLocalManager.manager.loadRecordings()
    }
    
    func deleteRecording(at row: Int) {

        let recordingToRemove = self.recordings[row]
        do {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let url = URL(fileURLWithPath: dirPath[0] + "/" + recordingToRemove.fileName +  AppConfig.Constants.appSavedAudioFileExtension)
            try FileManager.default.removeItem(at: url)
        } catch let error as NSError {
            ModacityDebugger.debug("file removing error - \(error.localizedDescription)")
        }
        
        self.recordings.remove(at: row)
        RecordingsLocalManager.manager.removeRecording(forId: recordingToRemove.id)
        RecordingsLocalManager.manager.saveAllRecordings(self.recordings)
        
    }
    
    func deleteRecording(for recording:Recording) {
        do {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let url = URL(fileURLWithPath: dirPath[0] + "/" + recording.fileName +  AppConfig.Constants.appSavedAudioFileExtension)
            try FileManager.default.removeItem(at: url)
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
        RecordingsLocalManager.manager.saveAllRecordings(self.recordings)
    }
}
