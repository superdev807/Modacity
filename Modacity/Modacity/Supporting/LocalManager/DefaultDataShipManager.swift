//
//  DefaultDataShipManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 25/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class DefaultDataShipManager {
    
    static let manager = DefaultDataShipManager()
    
    func produceDefaultData() {
        var practiceItems = [PracticeItem]()
        
        
        /*
        let playlist1 = Playlist()
        playlist1.id = UUID().uuidString
        playlist1.name = "This Week's Routine"
        playlist1.playlistPracticeEntries = [PlaylistPracticeEntry]()
        
        let playlist2 = Playlist()
        playlist2.id = UUID().uuidString
        playlist2.name = "Next Audition"
        playlist2.playlistPracticeEntries = [PlaylistPracticeEntry]()
        */
        var playlistPractice = PlaylistPracticeEntry()
        var practiceItem = PracticeItem()
        
        let playlist1 = AddNewPlaylist("This Week's Routine")
        let playlist2 = AddNewPlaylist("Next Audition")
        
        /*
         deleted by marc
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Breathing"
        practiceItem.addNote(text: "Use the breath to get focused")
        practiceItems.append(practiceItem)
        
        playlistPractice.name = "Breathing"
        playlistPractice.countDownDuration = 60
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        */
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Scales - Major"
        practiceItem.updateFavorite(favorite: true)
        practiceItem.addNote(text: "Swipe up to archive notes")
        practiceItems.append(practiceItem)
        
        PracticeItemLocalManager.manager.updateFavoriteIds(withNewItemId: practiceItem.id)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Scales - Major"
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        /*
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Scales - Minor"
        practiceItem.updateFavorite(favorite: true)
        practiceItem.addNote(text: "Swipe up to archive notes")
        practiceItems.append(practiceItem)
        PracticeItemLocalManager.manager.updateFavoriteIds(withNewItemId: practiceItem.id)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Scales - Minor"
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        */
        
        practiceItem = PracticeItem()
        practiceItem.name = "Visualization"
        practiceItem.id = UUID().uuidString
        let visualizationPracticeItemId = practiceItem.id
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Visualization"
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Etude #1"
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Etude #1"
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Visualization"
        playlistPractice.practiceItemId = visualizationPracticeItemId
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Sonata in C"
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Sonata in C"
        playlistPractice.practiceItemId = practiceItem.id
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Stretch, Reflect, Tidy Up"
        let stretchPracticeItemId = practiceItem.id
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Stretch, Reflect, Tidy Up"
        playlistPractice.practiceItemId = practiceItem.id
        playlistPractice.countDownDuration = 300
        playlist1.playlistPracticeEntries.append(playlistPractice)
        
        /*
         
         removed by Marc
         
         practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Audition Binder"
        practiceItems.append(practiceItem)

        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Audition Binder"
        playlistPractice.practiceItemId = practiceItem.id
        playlist2.playlistPracticeEntries.append(playlistPractice)
 */
 
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Visualization"
        playlistPractice.practiceItemId = visualizationPracticeItemId
        playlist2.playlistPracticeEntries.append(playlistPractice)
        
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Ein Heldenleben"
        practiceItem.addNote(text: "Be a hero! Communicate the musical message")
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Ein Heldenleben"
        playlistPractice.practiceItemId = practiceItem.id
        playlist2.playlistPracticeEntries.append(playlistPractice)
        
        /*practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Porgy & Bess"
        practiceItems.append(practiceItem)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Porgy & Bess"
        playlistPractice.practiceItemId = practiceItem.id
        playlist2.playlistPracticeEntries.append(playlistPractice)
        
        practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = "Beethoven 9"
        practiceItem.updateFavorite(favorite: true)
        practiceItems.append(practiceItem)
        PracticeItemLocalManager.manager.updateFavoriteIds(withNewItemId: practiceItem.id)
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Beethoven 9"
        playlistPractice.practiceItemId = practiceItem.id
        playlist2.playlistPracticeEntries.append(playlistPractice)
        */
        
        playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = "Stretch, Reflect, Tidy Up"
        playlistPractice.practiceItemId = stretchPracticeItemId
        playlist2.playlistPracticeEntries.append(playlistPractice)
        
        for item in practiceItems {
            PracticeItemLocalManager.manager.addPracticeItem(item)
        }
        
        PlaylistLocalManager.manager.addPlaylist(playlist: playlist1)
        PlaylistLocalManager.manager.addPlaylist(playlist: playlist2)
        
    }
    
    func AddNewPracticeItem(_ itemName: String, notes: [String] = [])
    -> PracticeItem {
        let practiceItem = PracticeItem()
        practiceItem.name = itemName
        practiceItem.id = UUID().uuidString
       
       
        if (notes.count > 0) {
            for note in notes {
                practiceItem.addNote(text: note)
            }
        }
        PracticeItemLocalManager.manager.addPracticeItem(practiceItem)
        
        return practiceItem
    }
    
    func AddNewPlaylist(_ playlistName: String) -> Playlist {
        let playlist = Playlist()
        playlist.id = UUID().uuidString
        playlist.name = playlistName
        playlist.playlistPracticeEntries = [PlaylistPracticeEntry]()
        
        PlaylistLocalManager.manager.addPlaylist(playlist: playlist)
        
        return playlist
    }
    
    func CreatePlaylistPracticeEntry(fromItem: PracticeItem, timerDuration: Int = 0) -> PlaylistPracticeEntry {
        
        let playlistPractice = PlaylistPracticeEntry()
        playlistPractice.name = fromItem.name
        playlistPractice.practiceItemId = fromItem.id
        playlistPractice.countDownDuration = timerDuration
        
        return playlistPractice
    }
}
