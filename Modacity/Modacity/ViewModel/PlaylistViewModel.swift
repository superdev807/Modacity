//
//  PlaylistViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PlaylistViewModel: ViewModel {

    private var playlists: [Playlist] = [Playlist]() {
        didSet {
            if let callback = self.callBacks["playlists"] {
                if oldValue.count > playlists.count {
                    callback(.deleted, oldValue, playlists)
                } else if oldValue.count < playlists.count {
                    callback(.inserted, oldValue, playlists)
                } else {
                    callback(.simpleChange, oldValue, playlists)
                }
            }
        }
    }
    
    var detailSelection: Playlist!
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playlistUpdated), name: AppConfig.appNotificationPlaylistUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playlistUpdated() {
        self.loadPlaylists()
    }
    
    func loadPlaylists() {
        let orgPlaylists = PlaylistLocalManager.manager.loadPlaylists() ?? [Playlist]()
        var tempPlaylists = [Playlist]()
        for playlist in orgPlaylists {
            if !playlist.archived {
                tempPlaylists.append(playlist)
            }
        }
        self.playlists = tempPlaylists
    }
    
    func countOfPlaylists() -> Int {
        return self.playlists.count
    }
    
    func playlist(at row:Int) -> Playlist {
        return self.playlists[row]
    }
    
    func deletePlaylist(at row: Int) {
        let playlist = self.playlists[row]
        PlaylistLocalManager.manager.deletePlaylist(playlist)
        ModacityAnalytics.LogStringEvent("Deleted Playlist", extraParamName: "name", extraParamValue: playlist.name)
        self.playlists.remove(at: row)
        
        PlaylistLocalManager.manager.storePlaylists(self.playlists)
    }
    
    func deletePlaylist(for playlist:Playlist) {
        PlaylistLocalManager.manager.deletePlaylist(playlist)
        
        for row in 0..<self.playlists.count {
            if self.playlists[row].id == playlist.id {
                self.playlists.remove(at: row)
                break
            }
        }
        PlaylistLocalManager.manager.storePlaylists(self.playlists)
    }
    
    func isFavorite(_ playlist:Playlist)->Bool {
        return PlaylistLocalManager.manager.isFavoritePlaylist(playlist)
    }
    
    func setFavorite(_ playlist:Playlist) {
        PlaylistLocalManager.manager.setFavoriteToPlaylist(playlist)
    }
    
}
