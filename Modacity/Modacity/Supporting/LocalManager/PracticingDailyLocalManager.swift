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
            idsArrayPerDate = ids
        }
        idsArrayPerDate.append(data.entryId)
        indecies[data.entryDateString] = idsArrayPerDate
        UserDefaults.standard.set(indecies, forKey: "practicing-indecies-\(practiceItemId)")
        UserDefaults.standard.set(data.toJSON(), forKey: "practicing-data-\(data.entryId)")
        UserDefaults.standard.synchronize()
        
        DispatchQueue.global(qos: .background).async {
            DailyPracticingRemoteManager.manager.createPracticing(data)
        }
        
        return data.entryId
        
    }
    
    func practicingData(forPracticeItemId: String) -> [String:[PracticeDaily]] {
        var data = [String:[PracticeDaily]]()
        if let ids = UserDefaults.standard.object(forKey: "practicing-indecies-\(forPracticeItemId)") as? [String:[String]] {
            for id in ids {
                if let practiceData = UserDefaults.standard.object(forKey: "practicing-data-\(id)") as? [String:Any] {
                    if let practice = PracticeDaily(JSON: practiceData) {
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
        return data
    }
    
    func syncFromServer() {
        
    }
    
    func signout() {
        
    }
    
}
