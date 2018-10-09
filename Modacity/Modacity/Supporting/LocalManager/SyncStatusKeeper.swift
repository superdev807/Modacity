//
//  SyncStatusKeeper.swift
//  Modacity
//
//  Created by BC Engineer on 30/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

enum SyncStatus {
    case loading
    case failed
    case succeeded
}

class SyncStatusKeeper: NSObject {
    
    static let keeper = SyncStatusKeeper()
    
    var statusPracticeItems: SyncStatus = .loading
    var statusPlaylist: SyncStatus = .loading
    var statusOverallData: SyncStatus = .loading {
        didSet {
            if statusOverallData == .succeeded {
                self.statusLabels.append("Loaded settings ✓")
            } else if statusOverallData == .failed {
                self.statusLabels.append("Loaded settings X")
            }
            
            NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationSyncStatusUpdated))
        }
    }
    var statusQuotes: SyncStatus = .loading
    var statusDailyPractice: SyncStatus = .loading
    var statusPlaylistPractice: SyncStatus = .loading
    var statusPremiumStatus: SyncStatus = .loading
    var statusGoals: SyncStatus = .loading
    
    var statusLabels = [String]()
    
    func reset() {
        
    }
    
}
