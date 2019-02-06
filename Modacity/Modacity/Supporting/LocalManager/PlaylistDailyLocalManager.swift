//
//  PlaylistDailyLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 19/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PlaylistDailyLocalManager: NSObject {
    
    static let manager = PlaylistDailyLocalManager()
    
    let miscPracticeId = AppConfig.Constants.appConstantMiscPracticeItemId
    let miscPracticeItemName = AppConfig.Constants.appConstantMiscPracticeItemName
    
    func saveNewPlaylistPracticing(_ data: PlaylistDaily) {
        
        var total = self.totalData() ?? [String:Any]()
        
        var playlistTotal = total[data.playlistId] as? [String:Any] ?? [String:Any]()
        
        var practiceDateTotal = playlistTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        playlistTotal[data.entryDateString] = practiceDateTotal
        total[data.playlistId] = playlistTotal
        
        self.storeTotalData(total)
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPlaylistPracticing(data)
        }
        
        if Authorizer.authorizer.isGuestLogin() {
            GuestCacheManager.manager.practiceSessionPracticeDataIds.append(data.entryId)
        }
    }
    
    func removeData(for data: PlaylistDaily) {
        var total = self.totalData() ?? [String:Any]()
        
        if var playlistTotal = total[data.playlistId] as? [String:Any] {
            
            if var practiceDateTotal = playlistTotal[data.entryDateString] as? [String:Any] {
                
                practiceDateTotal.removeValue(forKey: data.entryId)
                
                playlistTotal[data.entryDateString] = practiceDateTotal
                total[data.playlistId] = playlistTotal
                
                self.storeTotalData(total)
            }
            
        }
        
        
        DailyPracticingRemoteManager.manager.removePracticeSessionPracticingDataOnServer(for: data)
    }
    
    func saveManualPracticing(duration: Int, practiceItemId: String?, started: Date, playlistId: String?) {
        
        let playlistData = PlaylistDaily()
        if let playlistId = playlistId {
            playlistData.playlistId = playlistId
        } else {
            playlistData.playlistId = AppConfig.Constants.appConstantTempPlaylistId
        }
        playlistData.started = started.timeIntervalSince1970
        playlistData.practiceTimeInSeconds = duration
        playlistData.entryId = UUID().uuidString
        playlistData.entryDateString = started.toString(format: "yy-MM-dd")
        playlistData.fromTime = started.toString(format: "00:00:00")
        
        let data = PracticeDaily()
        data.startedTime = started.timeIntervalSince1970
        data.playlistId = playlistData.playlistId
        data.playlistPracticeEntryId = "MANUAL"
        data.practiceTimeInSeconds = duration
        data.entryDateString = started.toString(format: "yy-MM-dd")
        data.fromTime = started.toString(format: "HH:mm:ss")
        data.isManual = true
        data.entryId = UUID().uuidString
        data.playlistPracticeDataEntryId = playlistData.entryId
        
        if let practiceItemId = practiceItemId {
            data.practiceItemId = practiceItemId
        } else {
            data.practiceItemId = miscPracticeId
        }
        
        playlistData.practices = [String]()
        playlistData.practices.append(data.entryId)
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
        
        PracticingDailyLocalManager.manager.storePracitingDataToLocal(data)
        saveNewPlaylistPracticing(playlistData)
    }
    
    
    
    func storePlaylistPracitingDataToLocal(_ data: PlaylistDaily) {
        
        var total = self.totalData() ?? [String:Any]()
        
        var playlistTotal = total[data.playlistId] as? [String:Any] ?? [String:Any]()
        
        var practiceDateTotal = playlistTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        playlistTotal[data.entryDateString] = practiceDateTotal
        total[data.playlistId] = playlistTotal
        
        self.storeTotalData(total)
        
    }
    
    func playlistPracticingData(forPlaylistId: String) -> [String:[PracticeDaily]] {
        
        var data = [String:[PracticeDaily]]()
    
        if let total = self.totalData() {
            if let playlistData = total[forPlaylistId] as? [String: Any] {
                for date in playlistData.keys {
                    if let dataPerDate = playlistData[date] as? [String:Any] {
                        for entryId in dataPerDate.keys {
                            if let finalData = dataPerDate[entryId] as? [String:Any] {
                                if let playlistPracticeData = PlaylistDaily(JSON: finalData) {
                                    if let practices = playlistPracticeData.practicesArray() {
                                        for practice in practices {
                                            var entries = [PracticeDaily]()
                                            if let old = data[practice.entryDateString] {
                                                entries = old
                                            }
                                            entries.append(practice)
                                            data[practice.entryDateString] = entries
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return data
    }
    
    func playlistPracticingDataInPlaylistFormat(forPlaylistId: String) -> [String:[PlaylistDaily]] {
        
        var data = [String:[PlaylistDaily]]()
        
        if let total = self.totalData() {
            if let playlistData = total[forPlaylistId] as? [String: Any] {
                for date in playlistData.keys {
                    if let dataPerDate = playlistData[date] as? [String:Any] {
                        for entryId in dataPerDate.keys {
                            if let finalData = dataPerDate[entryId] as? [String:Any] {
                                if let practice = PlaylistDaily(JSON: finalData) {
                                    var entries = [PlaylistDaily]()
                                    if let old = data[practice.entryDateString] {
                                        entries = old
                                    }
                                    entries.append(practice)
                                    data[practice.entryDateString] = entries
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return data
        
    }
    
    func findParentIdForPractice(for entryId: String, playlistId: String) -> PlaylistDaily? {
        
        if let totalData = self.totalData() {
            if let playlistData = totalData[playlistId] as? [String:Any] {
                for date in playlistData.keys {
                    if let dataPerDate = playlistData[date] as? [String:Any] {
                        for id in dataPerDate.keys {
                            if let finalData = dataPerDate[id] as? [String:Any] {
                                if let practice = PlaylistDaily(JSON: finalData) {
                                    if let practiceIds = practice.practices {
                                        for practiceId in practiceIds {
                                            if practiceId == entryId {
                                                return practice
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func playlistData(for entryId: String) -> PlaylistDaily? {
        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-\(entryId)") as? [String:Any] {
            if let practice = PlaylistDaily(JSON: practiceData) {
                return practice
            }
        }
        
        return nil
    }
    
    func updateData(_ entry: PlaylistDaily) {
        UserDefaults.standard.set(entry.toJSON(), forKey: "playlist-data-\(entry.entryId ?? "")")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPlaylistPracticing(entry)
        }
    }
    
    
    func signout() {
        cleanData()
    }
    
    func cleanData() {
        UserDefaults.standard.removeObject(forKey: "total_playlist_practice_data")
        UserDefaults.standard.synchronize()
    }
    
    func storeTotalData(_ data: [String:Any]) {
        UserDefaults.standard.set(data, forKey: "total_playlist_practice_data")
        UserDefaults.standard.synchronize()
    }
    
    func totalData() -> [String:Any]? {
        return UserDefaults.standard.object(forKey: "total_playlist_practice_data") as? [String:Any]
    }
    
}
