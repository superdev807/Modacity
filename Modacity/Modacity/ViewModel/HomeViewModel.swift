//
//  HomeViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class HomeViewModel: ViewModel {
    
    var recentPlaylists: [Playlist] = [Playlist]() {
        didSet {
            self.dashboardPlaylistsCount = recentPlaylists.count + favoriteItems.count
            if let callback = self.callBacks["recentPlaylists"] {
                callback(.simpleChange, oldValue, recentPlaylists)
            }
        }
    }
    
    var favoriteItems = [[String:Any]]() {
        didSet {
            self.dashboardPlaylistsCount = recentPlaylists.count + favoriteItems.count
            if let callback = self.callBacks["favoriteItems"] {
                callback(.simpleChange, oldValue, favoriteItems)
            }
        }
    }
    
    var dashboardPlaylistsCount = 0 {
        didSet {
            if let callback = self.callBacks["dashboardPlaylistsCount"] {
                callback(.simpleChange, oldValue, dashboardPlaylistsCount)
            }
        }
    }
    
    var totalWorkingSeconds = 0 {
        didSet {
            if let callback = self.callBacks["totalWorkingSeconds"] {
                callback(.simpleChange, oldValue, totalWorkingSeconds)
            }
        }
    }
    
    var totalImprovements = 0 {
        didSet {
            if let callback = self.callBacks["totalImprovements"] {
                callback(.simpleChange, oldValue, totalImprovements)
            }
        }
    }
    
    var streakDays = 0 {
        didSet {
            if let callback = self.callBacks["streakDays"] {
                callback(.simpleChange, oldValue, streakDays)
            }
        }
    }
    
    func refreshOverallData() {
        self.totalImprovements = AppOveralDataManager.manager.totalImprovements()
    }
    
    func refreshDashboardValues() {
        DispatchQueue.global(qos:.background).async {
            let data = PracticingDailyLocalManager.manager.statsPracticing()
            self.streakDays = data["streak"]!
            self.totalWorkingSeconds = data["total"]!
        }
    }
    
    func calculateValuesBasedOnPracticeHistory() -> [String:Int] {
        let start = Date()
        
        var practicedDataPerDate = [String:Bool]()
        var totalPracticeTimeInSecond = 0
        
        var playlistIds = [String]()
        var foundFlag = [String:Bool]()
        
        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
            if key.starts(with: "playlist-indecies-") {
                let playlistId = key[("playlist-indecies-".count)..<(key.count)]
                if foundFlag[playlistId] == nil {
                    playlistIds.append(playlistId)
                    foundFlag[playlistId] = true
                }
            }
        }
        
        if foundFlag[AppConfig.appConstantTempPlaylistId] == nil {
            playlistIds.append(AppConfig.appConstantTempPlaylistId)
        }
        
        for playlistId in playlistIds {
            if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(playlistId)") as? [String:[String]] {
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
                                    var totalTime = 0
                                    if practice.practices != nil {
                                        for practiceDataId in practice.practices {
                                            if let practiceData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceDataId) {
                                                totalTime = totalTime + practiceData.practiceTimeInSeconds
                                                totalPracticeTimeInSecond = totalPracticeTimeInSecond + practiceData.practiceTimeInSeconds
                                            }
                                        }
                                    }
                                    
                                    if totalTime > 0 {
                                        practicedDataPerDate[practice.entryDateString] = true
                                        continue
                                    }
                                }
                            }
                            
                            if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-Optional(\"\(id))\"") as? [String:Any] {
                                if let practice = PlaylistDaily(JSON: practiceData) {
                                    var totalTime = 0
                                    if practice.practices != nil {
                                        for practiceDataId in practice.practices {
                                            if let practiceData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceDataId) {
                                                totalTime = totalTime + practiceData.practiceTimeInSeconds
                                                totalPracticeTimeInSecond = totalPracticeTimeInSecond + practiceData.practiceTimeInSeconds
                                            }
                                        }
                                    }
                                    
                                    if totalTime > 0 {
                                        practicedDataPerDate[practice.entryDateString] = true
                                        continue
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var dateString = Date().ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
        var streakDays = 1
        while practicedDataPerDate[dateString] != nil  && practicedDataPerDate[dateString]! == true {
            streakDays = streakDays + 1
            dateString = dateString.date(format: "yy-MM-dd")!.ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
        }
        
        ModacityDebugger.debug("App overall data calculation time - \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)s")
        
        var finalResult = [String:Int]()
        finalResult["streak"] = streakDays
        finalResult["total"] = totalPracticeTimeInSecond
        return finalResult
    }

    
//    func calculateValuesBasedOnPracticeHistory() -> [String:Int] {
//        let start = Date()
//
//        var practicedDataPerDate = [String:Bool]()
//        var totalPracticeTimeInSecond = 0
//
//        var playlistIds = [String]()
//        var foundFlag = [String:Bool]()
//
//        for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
//            if key.starts(with: "playlist-indecies-") {
//                let playlistId = key[("playlist-indecies-".count)..<(key.count)]
//                if foundFlag[playlistId] == nil {
//                    playlistIds.append(playlistId)
//                    foundFlag[playlistId] = true
//                }
//            }
//        }
//
//        if foundFlag[AppConfig.appConstantTempPlaylistId] == nil {
//            playlistIds.append(AppConfig.appConstantTempPlaylistId)
//        }
//
//        for playlistId in playlistIds {
//            if let ids = UserDefaults.standard.object(forKey: "playlist-indecies-\(playlistId)") as? [String:[String]] {
//                for date in ids.keys {
//                    if let idValues = ids[date] {
//                        var found = [String:Bool]()
//
//                        for id in idValues {
//                            if let alreadyFound = found[id] {
//                                if alreadyFound {
//                                    continue
//                                }
//                            }
//
//                            found[id] = true
//                            if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-\(id)") as? [String:Any] {
//                                if let practice = PlaylistDaily(JSON: practiceData) {
//                                    var totalTime = 0
//                                    if practice.practices != nil {
//                                        for practiceDataId in practice.practices {
//                                            if let practiceData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceDataId) {
//                                                totalTime = totalTime + practiceData.practiceTimeInSeconds
//                                                totalPracticeTimeInSecond = totalPracticeTimeInSecond + practiceData.practiceTimeInSeconds
//                                            }
//                                        }
//                                    }
//
//                                    if totalTime > 0 {
//                                        practicedDataPerDate[practice.entryDateString] = true
//                                        continue
//                                    }
//                                }
//                            }
//
//                            if let practiceData = UserDefaults.standard.object(forKey: "playlist-data-Optional(\"\(id))\"") as? [String:Any] {
//                                if let practice = PlaylistDaily(JSON: practiceData) {
//                                    var totalTime = 0
//                                    if practice.practices != nil {
//                                        for practiceDataId in practice.practices {
//                                            if let practiceData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceDataId) {
//                                                totalTime = totalTime + practiceData.practiceTimeInSeconds
//                                                totalPracticeTimeInSecond = totalPracticeTimeInSecond + practiceData.practiceTimeInSeconds
//                                            }
//                                        }
//                                    }
//
//                                    if totalTime > 0 {
//                                        practicedDataPerDate[practice.entryDateString] = true
//                                        continue
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        var dateString = Date().ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
//        var streakDays = 1
//        while practicedDataPerDate[dateString] != nil  && practicedDataPerDate[dateString]! == true {
//            streakDays = streakDays + 1
//            dateString = dateString.date(format: "yy-MM-dd")!.ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
//        }
//
//        ModacityDebugger.debug("App overall data calculation time - \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)s")
//
//        var finalResult = [String:Int]()
//        finalResult["streak"] = streakDays
//        finalResult["total"] = totalPracticeTimeInSecond
//        return finalResult
//    }
    
    func loadRecentPlaylists() {
        
        DispatchQueue.global(qos: .background).async {
            if let playlists = PlaylistLocalManager.manager.recentPlaylists() {
                self.recentPlaylists = playlists
            }
            
            var items = [[String:Any]]()
            if let playlists = PlaylistLocalManager.manager.loadFavoritePlaylists() {
                for playlist in playlists {
                    items.append(["type":"playlist", "data":playlist])
                }
            }
            
            if let practiceItems = PracticeItemLocalManager.manager.loadAllFavoritePracticeItems() {
                for practiceItem in practiceItems {
                    items.append(["type":"practiceitem", "data":practiceItem])
                }
            }
            self.favoriteItems = items.sorted(by: { (item1, item2) -> Bool in
                var itemName1 = ""
                var itemName2 = ""
                if (item1["type"] as? String ?? "") == "playlist" {
                    itemName1 = (item1["data"] as! Playlist).name.lowercased()
                } else if (item1["type"] as? String ?? "") == "practiceitem" {
                    itemName1 = (item1["data"] as! PracticeItem).name.lowercased()
                }
                if (item2["type"] as? String ?? "") == "playlist" {
                    itemName2 = (item2["data"] as! Playlist).name.lowercased()
                } else if (item1["type"] as? String ?? "") == "practiceitem" {
                    itemName2 = (item2["data"] as! PracticeItem).name.lowercased()
                }
                return itemName1 < itemName2
            })
            
            
        }
    }
}
