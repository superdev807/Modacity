//
//  RecordingsLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import GZZAudioConverter

class RecordingsLocalManager: NSObject {
    
    static let manager = RecordingsLocalManager()
    
    func saveCurrentRecording(toFileName: String, playlistId: String, practiceName: String, practiceEntryId: String, practiceItemId:String) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        DispatchQueue.global(qos: .background).async {
            let sourcePath = dirPath[0] + AppConfig.Constants.appRecordingStartFileName
            let targetPath = dirPath[0] + "/" + toFileName + AppConfig.Constants.appSavedAudioFileExtension
            
            let converter = GZZAudioConverter()
            converter.inputFile = sourcePath
            converter.outputFile = targetPath
            converter.outputFileType = kAudioFileMP3Type
            converter.outputFormatID = kAudioFormatMPEGLayer3
            let success = converter.convert()
            
            if success {
                ModacityDebugger.debug("Successfully converted")
                
                if let recording = Recording(JSON: ["id":UUID().uuidString,
                                                    "created_at":"\(Date().timeIntervalSince1970)",
                    "file_name":toFileName,
                    "playlist_id":playlistId,
                    "practice_name":practiceName,
                    "practiceEntryId":practiceEntryId,
                    "practiceItemId":practiceItemId]) {
                    self.addNewRecording(recording)
                }
                
            } else {
                ModacityDebugger.debug("Convert failed.")
                
                
            }
        }
        
    }
    
    func removeRecording(forId: String) {
        
        if let oldRecordingIds = self.loadRecordingIds() {
            var recordingIds = [String]()
            for recordingId in oldRecordingIds {
                if recordingId != forId {
                    recordingIds.append(recordingId)
                }
            }
            self.saveRecordingIds(recordingIds)
        }
        
        UserDefaults.standard.removeObject(forKey: "recording-" + forId)
        UserDefaults.standard.synchronize()
    }
    
    func saveAllRecordings(_ recordings:[Recording]) {
        var recordingIds = [String]()
        for recording in recordings {
            recordingIds.append(recording.id)
        }
        self.saveRecordingIds(recordingIds)
    }
    
    func saveRecordingIds(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: "recording_ids")
        UserDefaults.standard.synchronize()
    }
    
    func loadRecordingIds() -> [String]? {
        return UserDefaults.standard.object(forKey: "recording_ids") as? [String]
    }
    
    func recording(forId: String) -> Recording? {
        if let recordingData = UserDefaults.standard.object(forKey: "recording-" + forId) as? [String:Any] {
            return Recording(JSON: recordingData)
        } else {
            return nil
        }
    }
    
    func loadRecordings() -> [Recording] {
        if let recordingIds = self.loadRecordingIds() {
            var result = [Recording]()
            
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let fileManager = FileManager.default
            
            for recordingId in recordingIds {
                if let recording = self.recording(forId: recordingId) {
                    
                    let mp3FilePath = dirPath[0] + "/" + recording.fileName + AppConfig.Constants.appSavedAudioFileExtension
                    let wavFilePath = dirPath[0] + "/" + recording.fileName + ".wav"
                    
                    if fileManager.fileExists(atPath: mp3FilePath) || fileManager.fileExists(atPath: wavFilePath) {
                        result.append(recording)
                    }
                }
            }
            return result.sorted(by: { (recording1, recording2) -> Bool in
                let time1 = Date(timeIntervalSince1970: Double(recording1.createdAt) ?? 0)
                let time2 = Date(timeIntervalSince1970: Double(recording2.createdAt) ?? 0)
                return time1.compare(time2) == .orderedDescending
            })
        } else {
            return [Recording]()
        }
    }
    
    func loadRecordings(forPracticeId: String) -> [Recording] {
        if let recordingIds = self.loadRecordingIds() {
            var result = [Recording]()
            for recordingId in recordingIds {
                if let recording = self.recording(forId: recordingId) {
                    if (recording.practiceEntryId == forPracticeId) {
                        result.append(recording)
                    } else if (recording.practiceItemId == forPracticeId) {
                        result.append(recording)
                    } else {
                        let practiceName = recording.practiceName
                        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: forPracticeId) {
                            if practiceName == practice.name {
                                result.append(recording)
                            }
                        }
                    }
                }
            }
            return result.sorted(by: { (recording1, recording2) -> Bool in
                let time1 = Date(timeIntervalSince1970: Double(recording1.createdAt) ?? 0)
                let time2 = Date(timeIntervalSince1970: Double(recording2.createdAt) ?? 0)
                return time1.compare(time2) == .orderedDescending
            })
        } else {
            return [Recording]()
        }
    }
    
    func loadRecordings(forPlaylistId: String) -> [Recording] {
        if let recordingIds = self.loadRecordingIds() {
            var result = [Recording]()
            for recordingId in recordingIds {
                if let recording = self.recording(forId: recordingId) {
                    if (recording.playlistId == forPlaylistId) {
                        result.append(recording)
                    }
                }
            }
            return result.sorted(by: { (recording1, recording2) -> Bool in
                let time1 = Date(timeIntervalSince1970: Double(recording1.createdAt) ?? 0)
                let time2 = Date(timeIntervalSince1970: Double(recording2.createdAt) ?? 0)
                return time1.compare(time2) == .orderedDescending
            })
        } else {
            return [Recording]()
        }
    }
    
    func addNewRecording(_ recording:Recording) {
        if var recordingIds = self.loadRecordingIds() {
            recordingIds.append(recording.id)
            self.saveRecordingIds(recordingIds)
        } else {
            self.saveRecordingIds([recording.id])
        }
        
        UserDefaults.standard.set(recording.toJSON(), forKey: "recording-" + recording.id)
        UserDefaults.standard.synchronize()
    }
    
    func signout() {
        UserDefaults.standard.removeObject(forKey: "recording_ids")
        UserDefaults.standard.synchronize()
    }
    
}
