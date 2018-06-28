//
//  RecordingsLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/12/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class RecordingsLocalManager: NSObject {
    
    static let manager = RecordingsLocalManager()
    
    func saveCurrentRecording(toFileName: String, playlistId: String, practiceName: String, practiceEntryId: String, practiceItemId:String) {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let sourceUrl = URL(fileURLWithPath: dirPath[0] + "/recording.wav")
        let targetUrl = URL(fileURLWithPath: dirPath[0] + "/" + toFileName + ".wav")
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.copyItem(at: sourceUrl, to: targetUrl)
        } catch let error as NSError {
            print("File copy error: \(error)")
        }
        
        if let recording = Recording(JSON: ["id":UUID().uuidString,
                                         "created_at":"\(Date().timeIntervalSince1970)",
                                         "file_name":toFileName,
                                         "playlist_id":playlistId,
                                         "practice_name":practiceName,
                                         "practiceEntryId":practiceEntryId,
                                         "practiceItemId":practiceItemId]) {
            self.addNewRecording(recording)
        }
    }
    
    func removeRecording(forId: String) {
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
            for recordingId in recordingIds {
                if let recording = self.recording(forId: recordingId) {
                    result.append(recording)
                }
            }
            return result
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
            return result
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
            return result
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
