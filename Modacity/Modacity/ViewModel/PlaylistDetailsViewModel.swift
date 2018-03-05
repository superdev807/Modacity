//
//  PlaylistDetailsViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/3/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistDetailsViewModel: ViewModel {
    
    var playlist = Playlist()
    
    var playlistName = "My Playlist" {
        didSet {
            self.playlist.name = playlistName
            if let callback = self.callBacks["playlistName"] {
                callback(.simpleChange, oldValue, playlistName)
            }
        }
    }
    
    var practiceItems:[String] = [String]() {
        didSet {
            self.playlist.practiceItems = practiceItems
            if let callback = self.callBacks["practiceItems"] {
                callback(.simpleChange, oldValue, practiceItems)
            }
        }
    }
}
