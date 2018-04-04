//
//  PlaylistLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistLocalManager: NSObject {
    
    static let manager = PlaylistLocalManager()
    
    func syncWithOlderVersion() {
        if let playlists = self.loadPlaylists() {
            var newPlaylists = [Playlist]()
            for playlist in playlists {
                var newPracticeItems = [PlaylistPracticeEntry]()
                if playlist.playlistPracticeEntries != nil {
                    for item in playlist.playlistPracticeEntries {
                        if item.practiceItemId == nil && item.name != nil && item.name != "" {
                            if let newPracticeItem = PracticeItemLocalManager.manager.searchPracticeItem(byName: item.name) {
                                item.practiceItemId = newPracticeItem.id
                                item.name = ""
                                newPracticeItems.append(item)
                            }
                        } else if item.practiceItemId != nil {
                            newPracticeItems.append(item)
                        }
                    }
                    playlist.playlistPracticeEntries = newPracticeItems
                    newPlaylists.append(playlist)
                }
            }
            self.storePlaylists(newPlaylists)
        }
    }
    
    
    func storePlaylist(_ playlist: Playlist) {
        if playlist.id != "" {
            
            if var playlistIds = self.loadPlaylistIds() {
                if !(playlistIds.contains(playlist.id)) {
                    playlistIds.append(playlist.id)
                    self.savePlaylistIds(playlistIds)
                }
            } else {
                self.savePlaylistIds([playlist.id])
            }
            
            
            UserDefaults.standard.set(playlist.toJSON(), forKey: "playlist:id:" + playlist.id)
            UserDefaults.standard.synchronize()
            
            self.processRecentPlaylist(playlist)
        }
    }
    
    func savePlaylistIds(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: "playlist_ids")
        UserDefaults.standard.synchronize()
    }
    
    func loadPlaylistIds() -> [String]? {
        return UserDefaults.standard.object(forKey: "playlist_ids") as? [String]
    }
    
    func loadPlaylist(forId playlistId:String) -> Playlist? {
        if let string = UserDefaults.standard.object(forKey: "playlist:id:" + playlistId) as? [String:Any] {
            return Playlist(JSON: string)
        }
        return nil
    }
    
    func loadPlaylists() -> [Playlist]? {
        if let playlistIds = self.loadPlaylistIds() {
            var playlists = [Playlist]()
            for playlistId in playlistIds {
                if let playlist = self.loadPlaylist(forId: playlistId) {
                    playlists.append(playlist)
                }
            }
            return playlists
        } else {
            return nil
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        UserDefaults.standard.removeObject(forKey: "playlist:id:" + playlist.id)
        UserDefaults.standard.synchronize()
    }
    
    func storePlaylists(_ playlists: [Playlist]) {
        var playlistIds = [String]()
        for playlist in playlists {
            storePlaylist(playlist)
            playlistIds.append(playlist.id)
        }
        self.savePlaylistIds(playlistIds)
    }
    
    func isFavoritePlaylist(_ playlist: Playlist) -> Bool {
        return UserDefaults.standard.bool(forKey: "favorite-" + playlist.id)
    }
    
    func setFavoriteToPlaylist(_ playlist: Playlist) {
        if self.isFavoritePlaylist(playlist) {
            UserDefaults.standard.removeObject(forKey: "favorite-" + playlist.id)
        } else {
            UserDefaults.standard.set(true, forKey: "favorite-" + playlist.id)
        }
        UserDefaults.standard.synchronize()
    }
    
    func loadFavoritePlaylists() -> [Playlist]? {
        if let playlists = self.loadPlaylists() {
            var favoritePlaylists = [Playlist]()
            for playlist in playlists {
                if self.isFavoritePlaylist(playlist) {
                    favoritePlaylists.append(playlist)
                }
            }
            return favoritePlaylists
        }
        
        return nil
    }
    
    func recentPlaylists() -> [Playlist]? {
        if let recentPlaylistIds = UserDefaults.standard.object(forKey: "recent_playlist_ids") as? [String] {
            var recentPlaylists = [Playlist]()
            for playlistId in recentPlaylistIds {
                if let playlist = self.loadPlaylist(forId: playlistId) {
                    recentPlaylists.append(playlist)
                }
            }
            return recentPlaylists
        }
        return nil
    }
    
    func processRecentPlaylist(_ playlist:Playlist) {
        if var recentPlaylistIds = UserDefaults.standard.object(forKey: "recent_playlist_ids") as? [String] {
            for idx in 0..<recentPlaylistIds.count {
                if recentPlaylistIds[idx] == playlist.id {
                    if idx > 0 {
                        recentPlaylistIds.remove(at: idx)
                        recentPlaylistIds.insert(playlist.id, at: 0)
                        UserDefaults.standard.set(recentPlaylistIds, forKey: "recent_playlist_ids")
                        UserDefaults.standard.synchronize()
                    }
                    return
                }
            }
            self.savePlaylistToRecentQueue(playlist: playlist)
        } else {
            self.savePlaylistToRecentQueue(playlist: playlist)
        }
    }
    
    func savePlaylistToRecentQueue(playlist: Playlist) {
        var recentPlaylistIds = [String]()
        if let savedRecentPlaylistIds = UserDefaults.standard.object(forKey: "recent_playlist_ids") as? [String] {
            recentPlaylistIds = savedRecentPlaylistIds
        }
        recentPlaylistIds.insert(playlist.id, at: 0)
        
        if recentPlaylistIds.count > AppConfig.appMaxNumberForRecentPlaylists {
            recentPlaylistIds.removeLast()
        }
        
        UserDefaults.standard.set(recentPlaylistIds, forKey: "recent_playlist_ids")
        UserDefaults.standard.synchronize()
    }
    
    func processPracticeItemRemove(_ practiceItemId: String) {
        if let playlists = self.loadPlaylists() {
            for playlist in playlists {
                if let practiceEntries = playlist.playlistPracticeEntries {
                    var newEntries = [PlaylistPracticeEntry]()
                    for entry in practiceEntries {
                        if entry.practiceItemId != practiceItemId {
                            newEntries.append(entry)
                        }
                    }
                    playlist.playlistPracticeEntries = newEntries
                }
            }
            
            self.storePlaylists(playlists)
        }
    }
    
    
}
