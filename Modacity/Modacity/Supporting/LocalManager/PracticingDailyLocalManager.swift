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
    
    func saveNewPracticing(practiceItemId: String, started: Date, duration: Int, rating: Double, inPlaylist: String?, forPracticeEntry: String?, improvements: [ImprovedRecord]?) -> String {
        
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
        
        var indecies = [String:[String]]()
        if let old = UserDefaults.standard.object(forKey: "practicing-indecies-\(practiceItemId)") as? [String:[String]] {
            indecies = old
        }
        
        var idsArrayPerDate = [String]()
        
        if let ids = indecies[data.entryDateString] {
            idsArrayPerDate = AppUtils.cleanDuplicatedEntries(in: ids)
        }
        idsArrayPerDate.append(data.entryId)
        indecies[data.entryDateString] = idsArrayPerDate
        UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(practiceItemId)")
        UserDefaults.standard.set(data.toJSON(), forKey: "practicing-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
        
        return data.entryId
    }
    
    func updatePracticingData(data: PracticeDaily, oldEntryDate: String, newEntryDate: String) {
        
        UserDefaults.standard.set(data.toJSON(), forKey: "practicing-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
        
        if oldEntryDate != newEntryDate {
            if let practiceItemId = data.practiceItemId {
                var indecies = [String:[String]]()
                if let old = UserDefaults.standard.object(forKey: "practicing-indecies-\(practiceItemId)") as? [String:[String]] {
                    indecies = old
                }
                
                var idsArrayPerDate = [String]()
                
                if let ids = indecies[newEntryDate] {
                    idsArrayPerDate = AppUtils.cleanDuplicatedEntries(in: ids)
                }
                idsArrayPerDate.append(data.entryId)
                indecies[newEntryDate] = idsArrayPerDate
                
                if var idArrayForOldDate = indecies[oldEntryDate] {
                    for idx in 0..<idArrayForOldDate.count {
                        if idArrayForOldDate[idx] == data.entryId {
                            idArrayForOldDate.remove(at: idx)
                            break
                        }
                    }
                    indecies[oldEntryDate] = idArrayForOldDate
                }
                
                UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(practiceItemId)")
                UserDefaults.standard.synchronize()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
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
        
        var indecies = [String:[String]]()
        if let old = UserDefaults.standard.object(forKey: "practicing-indecies-\(practiceItemId)") as? [String:[String]] {
            indecies = old
        }
        
        var idsArrayPerDate = [String]()
        
        if let ids = indecies[data.entryDateString] {
            idsArrayPerDate = AppUtils.cleanDuplicatedEntries(in: ids)
        }
        idsArrayPerDate.append(data.entryId)
        indecies[data.entryDateString] = idsArrayPerDate
        UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(practiceItemId)")
        UserDefaults.standard.set(data.toJSON(), forKey: "practicing-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
    }
    
    func storePracitingDataToLocal(_ data: PracticeDaily) {
        var indecies = [String:[String]]()
        if let old = UserDefaults.standard.object(forKey: "practicing-indecies-\(data.practiceItemId ?? "")") as? [String:[String]] {
            indecies = old
        }
        
        var idsArrayPerDate = [String]()
        
        if let ids = indecies[data.entryDateString] {
            idsArrayPerDate = ids
        }
        idsArrayPerDate.append(data.entryId)
        indecies[data.entryDateString] = idsArrayPerDate
        UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(data.practiceItemId ?? "")")
        UserDefaults.standard.set(data.toJSON(), forKey: "practicing-data-\(data.entryId ?? "")")
        UserDefaults.standard.synchronize()
    }
    
    func practicingData(forPracticeItemId: String) -> [String:[PracticeDaily]] {
        var data = [String:[PracticeDaily]]()
        if let ids = UserDefaults.standard.object(forKey: "practicing-indecies-\(forPracticeItemId)") as? [String:[String]] {
            for date in ids.keys {
                if let idValues = ids[date] {
                    for id in idValues {
                        if let practiceData = UserDefaults.standard.object(forKey: "practicing-data-\(id)") as? [String:Any] {
                            if let practice = PracticeDaily(JSON: practiceData) {
                                var entries = [PracticeDaily]()
                                if let old = data[practice.entryDateString] {
                                    entries = old
                                }
                                if !entryContained(entries, practice) {
                                    entries.append(practice)
                                    data[practice.entryDateString] = entries
                                }
                            }
                        }
                        
                        if let practiceData = UserDefaults.standard.object(forKey: "practicing-data-Optional(\"\(id))\"") as? [String:Any] {
                            if let practice = PracticeDaily(JSON: practiceData) {
                                var entries = [PracticeDaily]()
                                if let old = data[practice.entryDateString] {
                                    entries = old
                                }
                                if !entryContained(entries, practice) {
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
    
    func entryContained(_ entries:[PracticeDaily], _ data: PracticeDaily) -> Bool {
        for entry in entries {
            if entry.startedTime == data.startedTime {
                return true
            }
        }
        
        return false
    }
    
    func practicingData(forDataId: String) -> PracticeDaily? {
        if let practiceData = UserDefaults.standard.object(forKey: "practicing-data-\(forDataId)") as? [String:Any] {
            if let practice = PracticeDaily(JSON: practiceData) {
                return practice
            }
        }
        return nil
    }
    
    func removeData(_ data: PracticeDaily) {
        if let practiceItemId = data.practiceItemId {
            var indecies = [String:[String]]()
            if let old = UserDefaults.standard.object(forKey: "practicing-indecies-\(practiceItemId)") as? [String:[String]] {
                indecies = old
            }
            
            var idsArrayPerDate = [String]()
            
            if let ids = indecies[data.entryDateString] {
                idsArrayPerDate = AppUtils.cleanDuplicatedEntries(in: ids)
            }
            
            for idx in 0..<idsArrayPerDate.count {
                if data.entryId == idsArrayPerDate[idx] {
                    idsArrayPerDate.remove(at: idx)
                    break
                }
            }
            indecies[data.entryDateString] = idsArrayPerDate
            UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(practiceItemId)")
            UserDefaults.standard.removeObject(forKey: "practicing-data-\(data.entryId ?? "")")
            UserDefaults.standard.synchronize()
        }
    }
    
    func signout() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix("practicing-indecies-") || key.hasPrefix("practicing-data-") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
}
