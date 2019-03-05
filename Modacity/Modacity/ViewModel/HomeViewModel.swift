//
//  HomeViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/12/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class HomeViewModel: ViewModel {
    
    var profileName: String = ""
    var recentPlaylists = [Playlist]()
    
    var favoriteItems = [String:[String:Any]]()
    
    var totalPracticeSeconds: Int = 0
    var dayStreakValues: Int = 0
    var totalImprovementsCount: Int = 0
    
    var flags = [String:Bool]()
    
    var alreadyDone = false
    
    override init() {
        flags = [String:Bool]()
    }
    
    func check() {
        if alreadyDone {
            return
        }
        if checkDone() {
            alreadyDone = true
            self.clearNotification()
            NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationHomePageValuesLoaded))
        }
    }
    
    func checkDone() -> Bool {
        let total = flags["total"] ?? false
        let streak = flags["streak"] ?? false
        let improvements = flags["improvements"] ?? false
        let favorites = flags["favorites"] ?? false
        let recents = flags["recents"] ?? false
        let profile = flags["profile"] ?? false
        
        return total && streak && improvements && favorites && recents && profile
    }
    
    func clearNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareValues() {
        prepareProfileDisplayName()
        prepareFavoriteItems()
        prepareTotalImprovementValue()
        prepareTotalSecondsAndStreakValues()
        prepareRecentItems()
    }
    
    @objc func prepareProfileDisplayName() {
        if MyProfileRemoteManager.manager.profileLoaded() {
            flags["profile"] = true
            print("profile flag : DONE")
            check()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(prepareProfileDisplayName), name: AppConfig.NotificationNames.appNotificationProfileUpdated, object: nil)
        }
    }
    
    @objc func prepareTotalImprovementValue() {
        if OverallDataRemoteManager.manager.overallDataSynchronized() {
            self.totalImprovementsCount = AppOveralDataManager.manager.totalImprovements() ?? 0
            flags["improvements"] = true
            print("improvements flag : DONE")
            check()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(prepareTotalImprovementValue), name: AppConfig.NotificationNames.appNotificationOverallAppDataLoadedFromServer, object: nil)
        }
    }
    
    @objc func prepareTotalSecondsAndStreakValues() {
        if DailyPracticingRemoteManager.manager.practicingDataFetched() {
            let data = PracticingDailyLocalManager.manager.statsPracticing()
            self.dayStreakValues = data["streak"] ?? 0
            self.totalPracticeSeconds = data["total"] ?? 0
            
            flags["total"] = true
            flags["streak"] = true
            
            print("total flag : DONE")
            print("streak flag : DONE")
            
            check()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(prepareTotalSecondsAndStreakValues), name: AppConfig.NotificationNames.appNotificationPracticeDataFetched, object: nil)
        }
    }
    
    @objc func prepareFavoriteItems() {
        
        if PlaylistRemoteManager.manager.playlistItemsSynchronized() && PracticeItemRemoteManager.manager.practiceItemsSynchronized() {
            
            let start = Date()
            var items = [String:[String:Any]]()
            if let playlists = PlaylistLocalManager.manager.loadFavoritePlaylists() {
                for playlist in playlists {
                    items[playlist.id] = ["type":"playlist", "data":playlist]
                }
            }

            if let practiceItems = PracticeItemLocalManager.manager.loadFavoritePracticeItems() {
                for practiceItem in practiceItems {
                    items[practiceItem.id] = ["type":"practiceitem", "data":practiceItem]
                }
            }
            
            self.favoriteItems = items
            
            flags["favorites"] = true
            
            print("favorites flag : DONE")
            
            ModacityDebugger.debug("Favorite calculation time - \(Date().timeIntervalSince1970 - start.timeIntervalSince1970)")
            check()
            
        } else {
            
            if !PlaylistRemoteManager.manager.playlistItemsSynchronized() {
                NotificationCenter.default.addObserver(self, selector: #selector(prepareFavoriteItems), name: AppConfig.NotificationNames.appNotificationPlaylistLoadedFromServer, object: nil)
            }
            
            if !PracticeItemRemoteManager.manager.practiceItemsSynchronized() {
                NotificationCenter.default.addObserver(self, selector: #selector(prepareFavoriteItems), name: AppConfig.NotificationNames.appNotificationPracticeLoadedFromServer, object: nil)
            }
            
        }
    }
    
    @objc func prepareRecentItems() {
        if PlaylistRemoteManager.manager.recentSessionsSynchronized() {
            if let playlists = PlaylistLocalManager.manager.loadFullRecentSessions() {
                self.recentPlaylists = playlists
            }
            flags["recents"] = true
            
            print("recents flag : DONE")
            check()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(prepareRecentItems), name: AppConfig.NotificationNames.appNotificationRecentSessionsLoadedFromServer, object: nil)
        }
    }
    
    // Memory cached favorite manager
    
    func favoriteItemsList() -> [[String:Any]] {
        var items = [[String:Any]]()
        for key in self.favoriteItems.keys {
            items.append(self.favoriteItems[key]!)
        }
        
        return items.sorted(by: { (item1, item2) -> Bool in
            var itemName1 = ""
            var itemName2 = ""
            if (item1["type"] as? String ?? "") == "playlist" {
                itemName1 = (item1["data"] as! Playlist).name.lowercased()
            } else if (item1["type"] as? String ?? "") == "practiceitem" {
                itemName1 = (item1["data"] as! PracticeItem).name.lowercased()
            }
            if (item2["type"] as? String ?? "") == "playlist" {
                itemName2 = (item2["data"] as! Playlist).name.lowercased()
            } else if (item2["type"] as? String ?? "") == "practiceitem" {
                itemName2 = (item2["data"] as! PracticeItem).name.lowercased()
            }
            return itemName1.compare(itemName2) == .orderedAscending
        })

    }
    
    func addFavoritePractice(practiceItem: PracticeItem) {
        self.favoriteItems[practiceItem.id] = ["type":"practiceitem", "data": practiceItem]
    }
    
    func removeFavoritePractice(itemId: String) {
        self.favoriteItems.removeValue(forKey: itemId)
    }
    
    func addFavoriteSession(session: Playlist) {
        if session.id != nil && session.id != "" {
            self.favoriteItems[session.id] = ["type":"playlist", "data": session]
        }
    }
    
    func removeFavoriteSession(sessionId: String?) {
        if sessionId != nil && sessionId! != "" {
            self.favoriteItems.removeValue(forKey: sessionId!)
        }
    }
    
}
