//
//  PlaylistViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
        self.playlists = PlaylistLocalManager.manager.loadPlaylists() ?? [Playlist]()
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
        PlaylistRemoteManager.manager.removePlaylist(for: playlist.id)
        AmplitudeTracker.LogStringEvent("Deleted Playlist", extraParamName: "name", extraParamValue: playlist.name)
        self.playlists.remove(at: row)
        
        PlaylistLocalManager.manager.storePlaylists(self.playlists)
    }
    
    func isFavorite(_ playlist:Playlist)->Bool {
        return PlaylistLocalManager.manager.isFavoritePlaylist(playlist)
    }
    
    func setFavorite(_ playlist:Playlist) {
        PlaylistLocalManager.manager.setFavoriteToPlaylist(playlist)
    }
    
}
