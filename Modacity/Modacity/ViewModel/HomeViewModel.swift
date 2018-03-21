//
//  HomeViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/12/18.
//  Copyright © 2018 crossover. All rights reserved.
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
    
    func loadRecentPlaylists() {
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
        
        self.totalWorkingSeconds = AppOveralDataManager.manager.totalPracticeSeconds()
        self.totalImprovements = AppOveralDataManager.manager.totalImprovements()
        self.streakDays = AppOveralDataManager.manager.calculateStreakDays()
    }
}
