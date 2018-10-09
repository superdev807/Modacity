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
        
        var indecies = [String:[String]]()
        if let old = UserDefaults.standard.object(forKey: "playlist-indecies-\(data.playlistId ?? "")") as? [String:[String]] {
            indecies = old
        }
        
        var idsArrayPerDate = [String]()
        
        if let ids = indecies[data.entryDateString] {
            idsArrayPerDate = ids
        }
        
        var alreadyIncluded = false
        for id in idsArrayPerDate {
            if id == data.entryId {
                alreadyIncluded = true
                break
            }
        }
        
        if !alreadyIncluded {
            idsArrayPerDate.append(data.entryId)
            indecies[data.entryDateString] = idsArrayPerDate
            UserDefaults.standard.set(indecies, forKey: "playlist-indecies-\(data.playlistId ?? "")")
        }
        
        UserDefaults.standard.set(data.toJSON(), forKey: "playlist-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPlaylistPracticing(data)
        }
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
        var indecies = [String:[String]]()
        
        if data.playlistId != nil {
            if let old = UserDefaults.standard.object(forKey: "playlist-indecies-\(data.playlistId ?? "")") as? [String:[String]] {
                indecies = old
            }
        }
        
        var idsArrayPerDate = [String]()
        
        if let ids = indecies[data.entryDateString] {
            idsArrayPerDate = AppUtils.cleanDuplicatedEntries(in: ids)
        }
        idsArrayPerDate.append(data.entryId)
        indecies[data.entryDateString] = idsArrayPerDate
        UserDefaults.standard.set(indecies, forKey: "playlist-indecies-\(data.playlistId ?? "")")
        UserDefaults.standard.set(data.toJSON(), forKey: "playlist-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
    }
    
    func playlistPracticingData(forPlaylistId: String) -> [String:[PracticeDaily]] {
        var data = [String:[PracticeDaily]]()
        if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(forPlaylistId)") as? [String:[String]] {
            for date in ids.keys {
                if let idValues = ids[date] {
                    var found = [String:Bool]()
                    for id in idValues {
                        if let alreadyFound = found[id] {
                            if alreadyFound {
                                continue
                            }
                        }
                        found[id] = true
                        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-\(id)") as? [String:Any] {
                            if let practice = PlaylistDaily(JSON: practiceData) {
                                var entries: [PracticeDaily]? = nil
                                if let old = data[practice.entryDateString] {
                                    entries = old
                                }
                                
                                if let practicesArray = practice.practicesArray() {
                                    if entries == nil {
                                        entries = [PracticeDaily]()
                                    }
                                    entries = entries! + practicesArray
                                }
                                
                                if entries != nil {
                                    data[practice.entryDateString] = entries!
                                }
                            }
                        }
                        
                        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-Optional(\"\(id))\"") as? [String:Any] {
                            if let practice = PlaylistDaily(JSON: practiceData) {
                                var entries: [PracticeDaily]? = nil
                                if let old = data[practice.entryDateString] {
                                    entries = old
                                }
                                
                                if let practicesArray = practice.practicesArray() {
                                    if entries == nil {
                                        entries = [PracticeDaily]()
                                    }
                                    entries = entries! + practicesArray
                                }
                                
                                if entries != nil {
                                    data[practice.entryDateString] = entries!
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
        if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(forPlaylistId)") as? [String:[String]] {
            for date in ids.keys {
                if let idValues = ids[date] {
                    var found = [String:Bool]()
                    for id in idValues {
                        if let alreadyFound = found[id] {
                            if alreadyFound {
                                continue
                            }
                        }
                        found[id] = true
                        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-\(id)") as? [String:Any] {
                            if let practice = PlaylistDaily(JSON: practiceData) {
                                var entries = [PlaylistDaily]()
                                if let old = data[practice.entryDateString] {
                                    entries = old
                                }
                                entries.append(practice)
                                data[practice.entryDateString] = entries
                            }
                        }
                        
                        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-Optional(\"\(id))\"") as? [String:Any] {
                            if let practice = PlaylistDaily(JSON: practiceData) {
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
        
        return data
    }
    
    func findParentIdForPractice(for entryId: String, playlistId: String) -> PlaylistDaily? {
        if playlistId == nil {
            return nil
        }
        if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(playlistId)") as? [String:[String]] {
            for date in ids.keys {
                if let idValues = ids[date] {
                    for id in idValues {
                        if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-\(id)") as? [String:Any] {
                            if let practice = PlaylistDaily(JSON: practiceData) {
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
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("playlist-indecies-") || key.hasPrefix("playlist-data-") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
}
