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
            self.dashboardPlaylistsCount = recentPlaylists.count + favoritePlaylists.count
            if let callback = self.callBacks["recentPlaylists"] {
                callback(.simpleChange, oldValue, recentPlaylists)
            }
        }
    }
    
    var favoritePlaylists: [Playlist] = [Playlist]() {
        didSet {
            self.dashboardPlaylistsCount = recentPlaylists.count + favoritePlaylists.count
            if let callback = self.callBacks["favoritePlaylists"] {
                callback(.simpleChange, oldValue, favoritePlaylists)
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
        
        if let playlists = PlaylistLocalManager.manager.loadFavoritePlaylists() {
            self.favoritePlaylists = playlists
        }
        
        self.totalWorkingSeconds = AppOveralDataManager.manager.totalPracticeSeconds()
        self.totalImprovements = AppOveralDataManager.manager.totalImprovements()
        self.streakDays = AppOveralDataManager.manager.calculateStreakDays()
    }
}
