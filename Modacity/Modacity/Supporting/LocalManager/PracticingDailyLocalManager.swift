//
//  PracticingDailyLocalManager.swift
//  Modacity
//
//  Created by BC Engineer on 19/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
    
    func removePracticingData(forItemId: String) {
//        if let ids = UserDefaults.standard.object(forKey: "practicing-indecies-\(forItemId)") as? [String:[String]] {
//            for date in ids.keys {
//                if let idValues = ids[date] {
//                    for id in idValues {
//                        UserDefaults.standard.removeObject(forKey: "practicing-data-\(id)")
//                    }
//                }
//            }
//            UserDefaults.standard.removeObject(forKey: "practicing-indecies-\(forItemId)")
//            UserDefaults.standard.synchronize()
//        }
//        DailyPracticingRemoteManager.manager
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
