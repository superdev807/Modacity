//
//  PracticingDailyLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 19/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PracticingDailyLocalManager: NSObject {
    
    static let manager = PracticingDailyLocalManager()
    
    func saveNewPracticing(practiceItemId: String, started: Date, duration: Int, rating: Double, inPlaylist: String?, forPracticeEntry: String?, improvements: [ImprovedRecord]?, parentId: String? = nil) -> String {
        
        let data = PracticeDaily()
        data.startedTime = started.timeIntervalSince1970
        data.playlistId = inPlaylist ?? ""
        data.playlistPracticeEntryId = forPracticeEntry ?? ""
        data.entryDateString = started.toString(format: "yy-MM-dd")
        data.fromTime = started.toString(format: "HH:mm:ss")
        data.practiceTimeInSeconds = duration
        data.improvements = improvements
        data.practiceItemId = practiceItemId
        data.rating = rating
        data.playlistPracticeDataEntryId = parentId
        
        var total = self.totalData() ?? [String:Any]()
        
        var practiceTotal = total[data.practiceItemId] as? [String:Any] ?? [String:Any]()
        
        var practiceDateTotal = practiceTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        practiceTotal[data.entryDateString] = practiceDateTotal
        total[data.practiceItemId] = practiceTotal
        
        self.storeTotalData(total)
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
        
        if Authorizer.authorizer.isGuestLogin() {
            GuestCacheManager.manager.practiceDataEntryIds.append(data.entryId)
        }
        
        return data.entryId
    }
    
    func updatePracticingData(data: PracticeDaily, oldEntryDate: String, newEntryDate: String, timeChange: Int) {
        
        var total = self.totalData() ?? [String:Any]()
        var practiceTotal = total[data.practiceItemId] as? [String:Any] ?? [String:Any]()
        
        print("old practice - \(practiceTotal)")
        var practiceDateTotal = practiceTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        practiceTotal[data.entryDateString] = practiceDateTotal
        
        if oldEntryDate != newEntryDate {
            if var practiceDateTotal = practiceTotal[oldEntryDate] as? [String:Any] {
                practiceDateTotal.removeValue(forKey: data.entryId)
                practiceTotal[oldEntryDate] = practiceDateTotal
            }
        }
        
        print("new practice - \(practiceTotal)")
        total[data.practiceItemId] = practiceTotal
        
        self.storeTotalData(total)
        
        if timeChange != 0 {
            updateParentPlaylistData(data, timeChange)
        }
        
        DispatchQueue.global(qos: .background).async {
            if oldEntryDate != newEntryDate {
                DailyPracticingRemoteManager.manager.deletePracticing(data)
            }
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
    }
    
    func saveManualPracticing(duration: Int, practiceItemId: String, started: Date) {
        let data = PracticeDaily()
        data.startedTime = started.timeIntervalSince1970
        data.playlistId = ""
        data.playlistPracticeEntryId = ""
        data.practiceItemId = practiceItemId
        data.practiceTimeInSeconds = duration
        data.entryDateString = started.toString(format: "yy-MM-dd")
        data.fromTime = started.toString(format: "HH:mm:ss")
        data.isManual = true
        
        var total = self.totalData() ?? [String:Any]()
        var practiceTotal = total[data.practiceItemId] as? [String:Any] ?? [String:Any]()
        var practiceDateTotal = practiceTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        practiceTotal[data.entryDateString] = practiceDateTotal
        total[data.practiceItemId] = practiceTotal
        
        self.storeTotalData(total)
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
    }
    
    func storePracitingDataToLocal(_ data: PracticeDaily) {
        
        var total = self.totalData() ?? [String:Any]()
        
        var practiceTotal = total[data.practiceItemId] as? [String:Any] ?? [String:Any]()
        
        var practiceDateTotal = practiceTotal[data.entryDateString] as? [String:Any] ?? [String:Any]()
        
        practiceDateTotal[data.entryId] = data.toJSON()
        practiceTotal[data.entryDateString] = practiceDateTotal
        total[data.practiceItemId] = practiceTotal
        
        self.storeTotalData(total)
    }
    
    func practicingData(forPracticeItemId: String) -> [String:[PracticeDaily]] {
        
        var data = [String:[String:PracticeDaily]]()
        
        if let stored = totalData() {
            if let practiceStored = stored[forPracticeItemId] as? [String: Any] {
                for date in practiceStored.keys {
                    if let datePracticeStored = practiceStored[date] as? [String: Any] {
                        for practiceDataItemId in datePracticeStored.keys {
                            if let practiceData = datePracticeStored[practiceDataItemId] as? [String:Any] {
                                if let practice = PracticeDaily(JSON: practiceData) {
                                    var entries = [String:PracticeDaily]()
                                    if let old = data[practice.entryDateString] {
                                        entries = old
                                    }
                                    
                                    if let entry = self.entryContained(entries, practice) {
                                        if entry.practiceTimeInSeconds >= practice.practiceTimeInSeconds {
                                            continue
                                        } else {
                                            entries.removeValue(forKey: entry.entryId)
                                        }
                                    }
                                        
                                    entries[practice.entryId] = practice
                                    data[practice.entryDateString] = entries
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var resultArray = [String:[PracticeDaily]]()
        for key in data.keys {
            if let dict = data[key] {
                var arr = [PracticeDaily]()
                for (_, value) in dict {
                    arr.append(value)
                }
                resultArray[key] = arr
            }
        }
        
        return resultArray
    }
    
    func entryContained(_ entries:[String:PracticeDaily], _ data: PracticeDaily) -> PracticeDaily? {
        
        if entries[data.entryId] != nil {
            return entries[data.entryId]!
        }
        
        for entryId in entries.keys {
            if let entry = entries[entryId] {
                if entry.startedTime == data.startedTime {
                    return entry
                }
            }
        }

        return nil
    }
    
    func practicingData(forDataId: String) -> PracticeDaily? {
        
        if let total = self.totalData() {
            for practiceId in total.keys {
                if let perPractice = total[practiceId] as? [String:Any] {
                    for date in perPractice.keys {
                        if let perDate = perPractice[date] as? [String:Any] {
                            for dataId in perDate.keys {
                                if dataId == forDataId {
                                    if let data = perDate[dataId] as? [String:Any] {
                                        return PracticeDaily(JSON: data)
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
    
    func removeData(_ data: PracticeDaily) {
        if let practiceItemId = data.practiceItemId {
            var total = self.totalData() ?? [String:Any]()
            if var practiceTotal = total[practiceItemId] as? [String:Any] {
                if var practiceDateTotal = practiceTotal[data.entryDateString] as? [String:Any] {
                    practiceDateTotal.removeValue(forKey: data.entryId)
                    practiceTotal[data.entryDateString] = practiceDateTotal
                    total[data.practiceItemId] = practiceTotal
                    self.storeTotalData(total)
                }
            }
            
            if data.playlistId != nil && data.playlistId != "" {
                self.removeParentPlaylistData(data)
            }
            
            DailyPracticingRemoteManager.manager.removePracticingDataOnServer(for: data)
        }
    }
    
    func updateParentPlaylistData(_ data:PracticeDaily, _ time:Int) {
        if let entryId = data.playlistPracticeDataEntryId {
            if let entry = PlaylistDailyLocalManager.manager.playlistData(for: entryId) {
                entry.practiceTimeInSeconds = entry.practiceTimeInSeconds + time
                PlaylistDailyLocalManager.manager.updateData(entry)
                return
            }
        }
        
        if let entry = PlaylistDailyLocalManager.manager.findParentIdForPractice(for: data.entryId, playlistId: data.playlistId) {
            entry.practiceTimeInSeconds = entry.practiceTimeInSeconds + time
            PlaylistDailyLocalManager.manager.updateData(entry)
            return
        }
    }
    
    func removeParentPlaylistData(_ data: PracticeDaily) {
        if let entryId = data.playlistPracticeDataEntryId {
            if let entry = PlaylistDailyLocalManager.manager.playlistData(for: entryId) {
                if let practiceIds = entry.practices {
                    for idx in (0..<practiceIds.count).reversed() {
                        let practiceId = practiceIds[idx]
                        if practiceId == data.entryId {
                            entry.practices.remove(at: idx)
                            entry.practiceTimeInSeconds = entry.practiceTimeInSeconds - data.practiceTimeInSeconds
                            PlaylistDailyLocalManager.manager.updateData(entry)
                            return
                        }
                    }
                }
            }
        } else {
            if let entry = PlaylistDailyLocalManager.manager.findParentIdForPractice(for: data.entryId, playlistId: data.playlistId) {
                if let practiceIds = entry.practices {
                    for idx in (0..<practiceIds.count).reversed() {
                        let practiceId = practiceIds[idx]
                        if practiceId == data.entryId {
                            entry.practices.remove(at: idx)
                            entry.practiceTimeInSeconds = entry.practiceTimeInSeconds - data.practiceTimeInSeconds
                            PlaylistDailyLocalManager.manager.updateData(entry)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func overallPracticeData() -> [String:[PracticeDaily]] {

        var data = [String:[String:PracticeDaily]]()
        
        if let stored = totalData() {
            for practiceItemId in stored.keys {
                if let practiceStored = stored[practiceItemId] as? [String: Any] {
                    for date in practiceStored.keys {
                        if let datePracticeStored = practiceStored[date] as? [String: Any] {
                            for practiceDataItemId in datePracticeStored.keys {
                                if let practiceData = datePracticeStored[practiceDataItemId] as? [String:Any] {
                                    if let practice = PracticeDaily(JSON: practiceData) {
                                        var entries = [String:PracticeDaily]()
                                        if let old = data[practice.entryDateString] {
                                            entries = old
                                        }
                                        
                                        if let entry = entryContained(entries, practice) {
                                            if entry.practiceTimeInSeconds >= practice.practiceTimeInSeconds {
                                                continue
                                            } else {
                                                entries.removeValue(forKey: entry.entryId)
                                            }
                                        }
                                        
                                        entries[practice.entryId] = practice
                                        data[practice.entryDateString] = entries
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var resultArray = [String:[PracticeDaily]]()
        for key in data.keys {
            if let dict = data[key] {
                var arr = [PracticeDaily]()
                for (_, value) in dict {
                    arr.append(value)
                }
                resultArray[key] = arr
            }
        }
        
        return resultArray
    }
    
    func statsPracticing() -> [String: Int] {
        let start = Date()
        
        var practicedDataPerDate = [String:Bool]()
        var totalPracticeTimeInSecond = 0
        
        var data = [String:[String: PracticeDaily]]()

        if let stored = totalData() {
            for practiceItemId in stored.keys {
                if let practiceStored = stored[practiceItemId] as? [String: Any] {
                    for date in practiceStored.keys {
                        if let datePracticeStored = practiceStored[date] as? [String: Any] {
                            for practiceDataItemId in datePracticeStored.keys {
                                if let practiceData = datePracticeStored[practiceDataItemId] as? [String:Any] {
                                    
                                    if let practice = PracticeDaily(JSON: practiceData) {
                                        
                                        var entries = [String:PracticeDaily]()
                                        if let old = data[practice.entryDateString] {
                                            entries = old
                                        }
                                        
                                        if let entry = self.entryContained(entries, practice) {
                                            if entry.practiceTimeInSeconds > practice.practiceTimeInSeconds {
                                                continue
                                            } else {
                                                totalPracticeTimeInSecond = totalPracticeTimeInSecond - entry.practiceTimeInSeconds
                                                entries.removeValue(forKey: entry.entryId)
                                            }
                                        }
                                        
                                        entries[practice.entryId] = practice
                                        data[practice.entryDateString] = entries
                                            
                                        practicedDataPerDate[practice.entryDateString] = true
                                        totalPracticeTimeInSecond = totalPracticeTimeInSecond + practice.practiceTimeInSeconds
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var dateString = Date().ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
        var streakDays = 0
        while practicedDataPerDate[dateString] != nil  && practicedDataPerDate[dateString]! == true {
            streakDays = streakDays + 1
            dateString = dateString.date(format: "yy-MM-dd")!.ago(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0).toString(format: "yy-MM-dd")
        }
        
        let todayString = Date().toString(format: "yy-MM-dd")
        if practicedDataPerDate[todayString] != nil && practicedDataPerDate[todayString]! == true {
            streakDays = streakDays + 1
        }
        
        ModacityDebugger.debug("App overall data calculation time - \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)s")
        
        LocalCacheManager.manager.storeTotalWorkingSecondsToCache(seconds: totalPracticeTimeInSecond)
        LocalCacheManager.manager.storeDayStreaksToCache(days: streakDays)
        
        var finalResult = [String:Int]()
        finalResult["streak"] = streakDays
        finalResult["total"] = totalPracticeTimeInSecond
        
        ModacityDebugger.debug("streak - \(streakDays), total time - \(totalPracticeTimeInSecond)")
        return finalResult
    }
    
    func signout() {
        cleanData()
    }
    
    func cleanData() {
        UserDefaults.standard.removeObject(forKey: "total_practice_data")
        UserDefaults.standard.synchronize()
    }
    
    func storeTotalData(_ data: [String:Any]) {
        UserDefaults.standard.set(data, forKey: "total_practice_data")
        UserDefaults.standard.synchronize()
    }
    
    func totalData() -> [String:Any]? {
        return UserDefaults.standard.object(forKey: "total_practice_data") as? [String:Any]
    }
    
}
