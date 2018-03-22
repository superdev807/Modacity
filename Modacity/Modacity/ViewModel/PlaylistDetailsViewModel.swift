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
            self.storePlaylist()
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
    
    var currentPracticeEntry : PlaylistPracticeEntry!
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
        
        if self.playlist.id == "" {
            self.playlist.id = UUID().uuidString
        }
        
        if self.playlist.createdAt == "" {
            self.playlist.createdAt = "\(Date().timeIntervalSince1970)"
        }
        
        self.storePlaylist()
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
    
    func fileNameAutoIncrementedNumber() -> Int {
        let key = "\(Date().toString(format: "yyyyMMdd"))-autoincrement"
        if UserDefaults.standard.object(forKey: key) == nil {
            return 1
        } else {
            return UserDefaults.standard.integer(forKey: key)
        }
    }
    
    func increaseAutoIncrementedNumber() {
        let key = "\(Date().toString(format: "yyyyMMdd"))-autoincrement"
        let value = self.fileNameAutoIncrementedNumber()
        UserDefaults.standard.set(value + 1, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func saveCurrentRecording(toFileName: String) {
        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: toFileName, playlistId: self.playlist.id, practiceName: self.currentPracticeEntry.practiceItem()?.name ?? "", practiceEntryId: self.currentPracticeEntry.entryId)
    }
    
    func addNewImprovement(_ improvement: Improvement) {
        self.totalImprovements = self.totalImprovements + 1
        AppOveralDataManager.manager.addImprovementsCount()
    }
}
