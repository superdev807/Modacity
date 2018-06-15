//
//  PlaylistDetailsViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/3/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistContentsViewModel: ViewModel {
    
    var playlist = Playlist()
    
    var playlistName = "" {
        didSet {
            self.playlist.name = playlistName
            self.createAndStorePlaylist()
            if let callback = self.callBacks["playlistName"] {
                callback(.simpleChange, oldValue, playlistName)
            }
        }
    }
    
    var playlistPracticeEntries:[PlaylistPracticeEntry] = [PlaylistPracticeEntry]() {
        didSet {
            self.playlist.playlistPracticeEntries = playlistPracticeEntries
            self.storePlaylist()
            if !disableCallbackForRowEditing {
                if let callback = self.callBacks["practiceItems"] {
                    callback(.simpleChange, oldValue, playlistPracticeEntries)
                }
            }
        }
    }
    
    // Playing data
    var timePracticed: [String:Int] = [String:Int]() {
        didSet {
            if let callback = self.callBacks["timePracticed"] {
                callback(.simpleChange, oldValue, timePracticed)
            }
        }
    }
    
    var countDownPlayed: [String: Int] = [String: Int]() {
        didSet {
            if let callback = self.callBacks["count_down_played"] {
                callback(.simpleChange, oldValue, countDownPlayed)
            }
        }
    }
    
    var countdownReseted:[String:Bool] = [String:Bool]()
    
    var editingRow: Int = -1 {
        didSet {
            if !disableCallbackForRowEditing {
                if let callback = self.callBacks["editingRow"] {
                    callback(.simpleChange, oldValue, editingRow)
                }
            }
        }
    }
    
    var totalImprovements: Int = 0 {
        didSet {
            if let callback = self.callBacks["total_improvements"] {
                callback(.simpleChange, oldValue, totalImprovements)
            }
        }
    }
    
    var currentPracticeEntry : PlaylistPracticeEntry! {
        didSet {
            print("current practice entry changed")
        }
    }
    var disableCallbackForRowEditing = false
    var sessionDurationInSecond: Int!
    var sessionCompleted = false
    
    var clockEditingPracticeItemId = "" {
        didSet {
            for practiceItem in self.playlistPracticeEntries {
                if practiceItem.entryId == clockEditingPracticeItemId {
                    self.clockEditingPracticeItem = practiceItem
                    break
                }
            }
        }
    }
    var clockEditingPracticeItem: PlaylistPracticeEntry!
    
    override init() {
        super.init()
        self.playlist.name = playlistName
    }
    
    func totalPracticedTime() -> Int {
        var total = 0
        for entry in self.playlistPracticeEntries {
            total = total + (self.timePracticed[entry.entryId] ?? 0)
        }
        return total
    }
    
    func checkPlaylistForPracticeItemRemoved() {
        var newEntries = [PlaylistPracticeEntry]()
        var changed = false
        for entry in self.playlistPracticeEntries {
            if PracticeItemLocalManager.manager.practiceItemRemoved(forId: entry.practiceItemId) {
                changed = true
                if self.timePracticed[entry.practiceItemId] != nil {
                    self.timePracticed.removeValue(forKey: entry.practiceItemId)
                }
            } else {
                newEntries.append(entry)
            }
        }
        if changed {
            self.playlistPracticeEntries = newEntries
        }
    }
    
    func setPlaylist(_ playlist: Playlist) {
        self.playlist = playlist
        self.playlistName = playlist.name
        self.playlistPracticeEntries = playlist.playlistPracticeEntries
        
        for practiceItem in self.playlistPracticeEntries {
            if let countDownDuration = practiceItem.countDownDuration {
                if countDownDuration > 0 {
                    self.countdownReseted[practiceItem.entryId] = true
                }
            }
        }
    }
    
    func addPracticeItems(_ items: [PracticeItem]) {
        for item in items {
            let practiceItemEntry = PlaylistPracticeEntry()
            practiceItemEntry.practiceItemId = item.id
            self.playlistPracticeEntries.append(practiceItemEntry)
        }
        
        self.playlist.playlistPracticeEntries = self.playlistPracticeEntries
        
        self.createAndStorePlaylist()
    }
    
    func createAndStorePlaylist() {
        if self.playlist.name != "" && self.playlist.playlistPracticeEntries != nil && self.playlist.playlistPracticeEntries.count > 0 {
            if self.playlist.createdAt == "" {
                self.playlist.createdAt = "\(Date().timeIntervalSince1970)"
            }
            
            if self.playlist.id == "" {
                self.playlist.id = UUID().uuidString
                PlaylistRemoteManager.manager.add(item: self.playlist)
            }
            self.storePlaylist()
        }
    }
    
    func isFavoritePracticeItem(forItemId: String) -> Bool {
        return PracticeItemLocalManager.manager.isFavoritePracticeItem(for:forItemId)
    }
    
    func setLikePracticeItem(for item: PracticeItem) {
        PracticeItemLocalManager.manager.setFavoritePracticeItem(forItemId: item.id)
    }
    
    func chaneOrder(source: Int, target: Int) {
        disableCallbackForRowEditing = true
        var tempEditingItemEntryId = ""
        if editingRow != -1 {
            tempEditingItemEntryId = self.playlistPracticeEntries[editingRow].entryId
        }
        let movedObject = self.playlistPracticeEntries[source]
        self.playlistPracticeEntries.remove(at: source)
        self.playlistPracticeEntries.insert(movedObject, at: target)
        if editingRow != -1 {
            for idx in 0..<self.playlistPracticeEntries.count {
                if self.playlistPracticeEntries[idx].entryId == tempEditingItemEntryId {
                    editingRow = idx
                    break
                }
            }
        }
        disableCallbackForRowEditing = false
    }
    
    func changePlaylistName(to name:String) {
        if name != "" {
            self.playlistName = name
        }
    }
    
    func storePlaylist() {
        if self.playlist.id != "" {
            PlaylistLocalManager.manager.storePlaylist(self.playlist)
            PlaylistRemoteManager.manager.update(item: self.playlist)
            NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPlaylistUpdated))
        }
    }
    
    func deletePracticeItem(for practiceItem:PlaylistPracticeEntry) {
        for idx in 0..<self.playlistPracticeEntries.count {
            if practiceItem.entryId == self.playlistPracticeEntries[idx].entryId {
                self.playlistPracticeEntries.remove(at: idx)
                return
            }
        }
    }
    
    func setRating(for practiceItem: PracticeItem, rating: Double) {
        PracticeItemLocalManager.manager.setRatingValue(forItemId: practiceItem.id, rating: rating)
    }
    
    func rating(forPracticeItemId: String) -> Double? {
        return PracticeItemLocalManager.manager.ratingValue(for:forPracticeItemId)
    }
    
    func duration(forPracticeItem entryId: String) -> Int? {
        return self.timePracticed[entryId]
    }
    
    func countDownPlayedTime(forPracticeItem entryId: String) -> Int? {
        return self.countDownPlayed[entryId]
    }
    
    func updateCountDownPlayedTime(forPracticeItem entryId: String, time:Int) {
        self.countDownPlayed[entryId] = time
    }
    
    func updateDuration(forPracticeItem entryId: String, duration: Int) {
        self.timePracticed[entryId] = duration + (self.timePracticed[entryId] ?? 0)
    }
    
    func setDuration(forPracticeItem entryId: String, duration: Int) {
        self.timePracticed[entryId] = duration
    }
    
    func setEditingRow(for item:PlaylistPracticeEntry) {
        for idx in 0..<self.playlistPracticeEntries.count {
            if playlistPracticeEntries[idx].entryId == item.entryId {
                self.editingRow = idx
                return
            }
        }
    }
    
    func changeCountDownDuration(for entryId:String, duration: Int) {

        for idx in 0..<self.playlistPracticeEntries.count {
            if self.playlistPracticeEntries[idx].entryId == entryId {
                let oldCountDownDuration = self.playlistPracticeEntries[idx].countDownDuration ?? 0
                if oldCountDownDuration != duration {
                    self.countdownReseted[entryId] = true
                }
                self.playlistPracticeEntries[idx].countDownDuration = duration
                break
            }
        }
        
        self.playlist.playlistPracticeEntries = self.playlistPracticeEntries
        self.storePlaylist()
        
        if let callback = self.callBacks["practiceItems"] {
            callback(.simpleChange, self.playlistPracticeEntries, playlistPracticeEntries)
        }
    }
    
    func next() -> Bool {
        for idx in 0..<self.playlistPracticeEntries.count {
            if playlistPracticeEntries[idx].entryId == self.currentPracticeEntry.entryId {
                if idx == self.playlistPracticeEntries.count - 1 {
                    return false
                }
                self.currentPracticeEntry = playlistPracticeEntries[idx + 1]
                return true
            }
        }
        return false
    }
    
    func tooltipAlreadyShown() -> Bool {
        return UserDefaults.standard.bool(forKey: "tooltip_shown")
    }
    
    func didTooltipShown() {
        UserDefaults.standard.set(true, forKey: "tooltip_shown")
        UserDefaults.standard.synchronize()
    }
    
    func addPracticeTotalTime(inSec sec:Int) {
        AppOveralDataManager.manager.addPracticeTime(inSec: sec)
    }
    
    func saveCurrentRecording(toFileName: String) {
        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: toFileName, playlistId: self.playlist.id, practiceName: self.currentPracticeEntry.practiceItem()?.name ?? "", practiceEntryId: self.currentPracticeEntry.entryId)
    }
    
    func addNewImprovement(_ improvement: Improvement) {
        self.totalImprovements = self.totalImprovements + 1
        AppOveralDataManager.manager.addImprovementsCount()
    }
    
    func addNoteToPlaylist(_ note:String) {
        self.playlist.addNote(text: note)
    }
    
    func addNote(to: PlaylistPracticeEntry, note:String) {
        to.practiceItem()!.addNote(text: note)
        self.storePlaylist()
    }
    
    func changeNoteTitle(entry: PlaylistPracticeEntry, note:Note, to:String) {
        entry.practiceItem()?.changeNoteTitle(for: note.id, to: to)
    }
    
    func changeArchiveStatusForPlaylistNote(_ noteId:String) {
        self.playlist.archiveNote(for: noteId)
    }
    
    func changeArchiveStatusForNote(noteId:String, for entry:PlaylistPracticeEntry) {
        entry.practiceItem()?.archiveNote(for: noteId)
    }
    
    func deleteNote(_ note:Note, for entry: PlaylistPracticeEntry) {
        entry.practiceItem()?.deleteNote(for: note.id)
    }
    
    func changeNoteTitle(noteId: String, title: String) {
        self.playlist.changeNoteTitle(for: noteId, title: title)
    }
    
    func changeNoteSubTitle(noteId: String, subTitle: String) {
        self.playlist.changeNoteSubTitle(for: noteId, subTitle: subTitle)
    }
    
    func deletePlaylistNote(_ note: Note) {
        self.playlist.deleteNote(for: note.id)
    }
    
    func changePlaylistNoteTitle(note: Note, to: String) {
        self.playlist.changeNoteTitle(for: note.id, to: to)
    }
}