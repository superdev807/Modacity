//
//  PlaylistLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
    
    func cleanPlaylists() {
        if let playlistIds = self.loadPlaylistIds() {
            for playlistId in playlistIds {
                UserDefaults.standard.removeObject(forKey: "playlist:id:" + playlistId)
            }
        }
        UserDefaults.standard.removeObject(forKey: "playlist_ids")
        UserDefaults.standard.synchronize()
    }
    
    func loadPlaylists() -> [Playlist]? {
        if let playlistIds = self.loadPlaylistIds() {
            var playlists = [Playlist]()
            for playlistId in playlistIds {
                if let playlist = self.loadPlaylist(forId: playlistId) {
                    playlists.append(playlist)
                }
            }
            return playlists.sorted(by: { (playlist1, playlist2) -> Bool in
                return playlist1.name.compare(playlist2.name) == .orderedAscending
            })
        } else {
            return nil
        }
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        playlist.archived = true
        
        if let recentPlaylistIds = UserDefaults.standard.object(forKey: "recent_playlist_ids") as? [String] {
            var recentPlaylists = [Playlist]()
            for playlistId in recentPlaylistIds {
                if playlistId != playlist.id {
                    recentPlaylists.append(playlist)
                }
            }
            UserDefaults.standard.set(recentPlaylistIds, forKey: "recent_playlist_ids")
        }
        
        UserDefaults.standard.set(playlist.toJSON(), forKey: "playlist:id:" + playlist.id)
        UserDefaults.standard.synchronize()
        PlaylistRemoteManager.manager.update(item: playlist)//removePlaylist(for: playlist.id)
    }
    
    func storePlaylists(_ playlists: [Playlist]) {
        var playlistIds = [String]()
        for playlist in playlists {
            storePlaylist(playlist)
            playlistIds.append(playlist.id)
        }
        self.savePlaylistIds(playlistIds)
    }
    
    func loadFavoritePlaylists() -> [Playlist]? {
        if let playlists = self.loadPlaylists() {
            var favoritePlaylists = [Playlist]()
            for playlist in playlists {
                if !playlist.archived && playlist.isFavorite {
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
                    if !playlist.archived {
                        recentPlaylists.append(playlist)
                    }
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
        
        if recentPlaylistIds.count > AppConfig.Constants.appMaxNumberForRecentPlaylists {
            recentPlaylistIds.removeLast()
        }
        
        UserDefaults.standard.set(recentPlaylistIds, forKey: "recent_playlist_ids")
        UserDefaults.standard.synchronize()
    }
    
    func processPracticeItemRemove(_ practiceItemId: String) {
        if let playlists = self.loadPlaylists() {
            for playlist in playlists {
                var updated = false
                if let practiceEntries = playlist.playlistPracticeEntries {
                    var newEntries = [PlaylistPracticeEntry]()
                    for entry in practiceEntries {
                        if entry.practiceItemId != practiceItemId {
                            newEntries.append(entry)
                        } else {
                            updated = true
                        }
                    }
                    playlist.playlistPracticeEntries = newEntries
                }
                if updated {
                    playlist.updateMe()
                }
            }
            self.storePlaylists(playlists)
        }
    }
    
    func addPlaylist(playlist: Playlist) {
        var newPlaylists = [Playlist]()
        if let playlists = self.loadPlaylists() {
            newPlaylists = playlists
        }
        newPlaylists.append(playlist)
        self.storePlaylists(newPlaylists)
        PlaylistRemoteManager.manager.add(item: playlist)
    }
    
    func signout() {
        if let playlistIds = loadPlaylistIds() {
            for playlistId in playlistIds {
                UserDefaults.standard.removeObject(forKey: "playlist:id:" + playlistId)
            }
        }
        UserDefaults.standard.removeObject(forKey: "playlist_ids")
        UserDefaults.standard.removeObject(forKey: "recent_playlist_ids")
        UserDefaults.standard.synchronize()
    }
}
