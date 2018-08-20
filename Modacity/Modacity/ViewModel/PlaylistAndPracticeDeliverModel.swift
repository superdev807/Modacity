//
//  PlaylistAndPracticeDeliverModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PlaylistAndPracticeDeliverModel: ViewModel {
    
    var deliverPlaylist: Playlist!
    var deliverPracticeItem: PracticeItem!
    
    var sessionTimeStarted: Date?
    var sessionImproved =  [ImprovedRecord]()
    var sessionTime: Int!
}
