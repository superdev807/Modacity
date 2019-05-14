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
                        if item.practiceItemId == nil {
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
        
        if playlist.id != nil && playlist.id != "" {
            self.removeRecentSession(sessionId: playlist.id)
        }
        
        UserDefaults.standard.set(playlist.toJSON(), forKey: "playlist:id:" + playlist.id)
        UserDefaults.standard.synchronize()
        PlaylistRemoteManager.manager.update(item: playlist)
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
    
    func addPlaylist(playlist: Playlist, isDefault: Bool) {
        var newPlaylists = [Playlist]()
        if let playlists = self.loadPlaylists() {
            newPlaylists = playlists
        }
        newPlaylists.append(playlist)
        self.storePlaylists(newPlaylists)
        
        if !isDefault {
            if Authorizer.authorizer.isGuestLogin() {
                GuestCacheManager.manager.practiceSessionIds.append(playlist.id)
            }
        }
        
        PlaylistRemoteManager.manager.add(item: playlist)
    }
    
    func saveRecentSessions(sessions: [String:String]) {
        UserDefaults.standard.set(sessions, forKey: "recent_sessions")
    }
    
    func storeRecentSession(sessionId: String) {
        var sessionIds = [String:String]()
        if let storedSessionIds = UserDefaults.standard.object(forKey: "recent_sessions") as? [String:String] {
            sessionIds = storedSessionIds
        }
        
        if (sessionIds.keys.count > AppConfig.Constants.appRecentQueueMaxSessionsCount) {
            let sortedIds = sessionIds.keys.sorted { (firstKey, secondKey) -> Bool in
                return sessionIds[firstKey]!.compare(sessionIds[secondKey]!) == .orderedDescending
            }
            
            sessionIds.removeValue(forKey: sortedIds.last!)
            PlaylistRemoteManager.manager.removeRecentSession(sessionId: sessionId)
        }
        
        let value = "\(Date().timeIntervalSince1970)"
        sessionIds[sessionId] = value
        UserDefaults.standard.set(sessionIds, forKey: "recent_sessions")
        
        PlaylistRemoteManager.manager.storeRecentSession(sessionId: sessionId, value: value)
    }
    
    func removeRecentSession(sessionId: String) {
        var sessionIds = [String:String]()
        if let storedSessionIds = UserDefaults.standard.object(forKey: "recent_sessions") as? [String:String] {
            sessionIds = storedSessionIds
        }
        
        if sessionIds[sessionId] != nil {
            sessionIds.removeValue(forKey: sessionId)
            UserDefaults.standard.set(sessionIds, forKey: "recent_sessions")
            PlaylistRemoteManager.manager.removeRecentSession(sessionId: sessionId)
        }
    }
    
    func loadFullRecentSessions() -> [Playlist]? {
        if var recentSessionIds = UserDefaults.standard.object(forKey: "recent_sessions") as? [String:String] {
            
            let sortedIds = recentSessionIds.keys.sorted { (firstKey, secondKey) -> Bool in
                return recentSessionIds[firstKey]!.compare(recentSessionIds[secondKey]!) == .orderedDescending
            }
            
            var result = [Playlist]()
            for sessionId in sortedIds {
                if let session = self.loadPlaylist(forId: sessionId) {
                    result.append(session)
                }
            }
            
            return result
        }
        
        return nil
    }
    
    func checkPlaylistNameAvailable(_ newName: String, _ exceptId: String?) -> Bool {
        if let sessions = self.loadPlaylists() {
            for session in sessions {
                if session.id != exceptId && session.name.lowercased() == newName.lowercased() {
                    return false
                }
            }
        }
        
        return true
    }
    
    func availablePlaylistName(from name: String) -> String {
        var idx = 1
        while (true) {
            let newName = "\(name)_\(idx)"
            if (self.checkPlaylistNameAvailable(newName, nil)) {
                return newName
            }
            idx = idx + 1
        }
    }
    
    func signout() {
        if let playlistIds = loadPlaylistIds() {
            for playlistId in playlistIds {
                UserDefaults.standard.removeObject(forKey: "playlist:id:" + playlistId)
            }
        }
        UserDefaults.standard.removeObject(forKey: "playlist_ids")
        UserDefaults.standard.removeObject(forKey: "recent_playlist_ids")
        UserDefaults.standard.removeObject(forKey: "recent_sessions")
        UserDefaults.standard.removeObject(forKey: "favorite_sessions")
        UserDefaults.standard.synchronize()
    }
}
