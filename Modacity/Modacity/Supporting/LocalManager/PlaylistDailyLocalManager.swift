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
    
    func storePlaylistPracitingDataToLocal(_ data: PlaylistDaily) {
        var indecies = [String:[String]]()
        if let old = UserDefaults.standard.object(forKey: "playlist-indecies-\(data.playlistId ?? "")") as? [String:[String]] {
            indecies = old
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
    
    func overallPracticeData() -> [String:[PlaylistDaily]] {
        var data = [String:[PlaylistDaily]]()
        var playlistIds = [String]()
        if let playlists = PlaylistLocalManager.manager.loadPlaylists() {
            for playlist in playlists {
                playlistIds.append(playlist.id ?? "")
            }
        }
        
        playlistIds.append("tempplaylist")
        
        for playlistId in playlistIds {
            if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(playlistId)") as? [String:[String]] {
                for date in ids.keys {
                    if let idValues = ids[date] {
                        for id in idValues {
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
        }
        
        return data
    }
    
    func playlistPracticingData(forPlaylistId: String) -> [String:[PlaylistDaily]] {
        var data = [String:[PlaylistDaily]]()
        if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(forPlaylistId)") as? [String:[String]] {
            for date in ids.keys {
                if let idValues = ids[date] {
                    for id in idValues {
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

    func signout() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("playlist-indecies-") || key.hasPrefix("playlist-data-") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
}
