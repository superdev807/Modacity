//
//  GuestCacheManager.swift
//  Modacity
//
//  Created by Dream Realizer on 11/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class GuestCacheManager: NSObject {

    static let manager = GuestCacheManager()
    
    var practiceItemIds = [String]()
    var practiceSessionIds = [String]()
    var practiceDataEntryIds = [String]()
    var practiceSessionPracticeDataIds = [String]()
    
    func clearCache() {
        
        for itemId in practiceItemIds {
            if let item = PracticeItemLocalManager.manager.practiceItem(forId: itemId) {
                PracticeItemLocalManager.manager.removePracticeItem(for: item)
            }
        }
        
        for practiceSessionId in practiceSessionIds {
            if let practiceSession = PlaylistLocalManager.manager.loadPlaylist(forId: practiceSessionId) {
                PlaylistLocalManager.manager.deletePlaylist(practiceSession)
            }
        }
        
        for dataId in practiceDataEntryIds {
            if let practiceData = PracticingDailyLocalManager.manager.practicingData(forDataId: dataId) {
                PracticingDailyLocalManager.manager.removeData(practiceData)
            }
        }
        
        for dataId in practiceSessionPracticeDataIds {
            if let data = PlaylistDailyLocalManager.manager.playlistData(for: dataId) {
                PlaylistDailyLocalManager.manager.removeData(for: data)
            }
        }
        
        practiceItemIds = [String]()
        practiceSessionIds = [String]()
        practiceDataEntryIds = [String]()
        practiceSessionPracticeDataIds = [String]()
    }
    
}
