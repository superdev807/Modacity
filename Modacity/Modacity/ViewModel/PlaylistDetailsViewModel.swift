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
    
    var practiceItems:[PracticeItemEntry] = [PracticeItemEntry]() {
        didSet {
            self.playlist.practiceItems = practiceItems
            self.storePlaylist()
            if !disableCallbackForRowEditing {
                if let callback = self.callBacks["practiceItems"] {
                    callback(.simpleChange, oldValue, practiceItems)
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
    
    var currentPracticeItem : PracticeItemEntry!
    var disableCallbackForRowEditing = false
    var sessionDurationInSecond: Int!
    var sessionCompleted = false
    
    var clockEditingPracticeItemId = "" {
        didSet {
            for practiceItem in self.practiceItems {
                if practiceItem.entryId == clockEditingPracticeItemId {
                    self.clockEditingPracticeItem = practiceItem
                    break
                }
            }
        }
    }
    var clockEditingPracticeItem: PracticeItemEntry!
    
    override init() {
        super.init()
        self.playlist.name = playlistName
    }
    
    func setPlaylist(_ playlist: Playlist) {
        self.playlist = playlist
        self.playlistName = playlist.name
        self.practiceItems = playlist.practiceItems
        
        for practiceItem in self.practiceItems {
            if let countDownDuration = practiceItem.countDownDuration {
                if countDownDuration > 0 {
                    self.countdownReseted[practiceItem.entryId] = true
                }
            }
        }
    }
    
    func addPracticeItems(itemNames: [String]) {
        for item in itemNames {
            self.practiceItems.append(PracticeItemEntry(name: item))
        }
        
        self.playlist.practiceItems = self.practiceItems
        
        if self.playlist.id == "" {
            self.playlist.id = UUID().uuidString
        }
        
        if self.playlist.createdAt == "" {
            self.playlist.createdAt = "\(Date().timeIntervalSince1970)"
        }
        
        self.storePlaylist()
    }
    
    func setLikePracticeItem(for name: String) {
        PracticeItemLocalManager.manager.setFavoritePracticeItem(for: name)
    }
    
    func isFavoritePracticeItem(for name:String) -> Bool {
        return PracticeItemLocalManager.manager.isFavoritePracticeItem(for:name)
    }
    
    func chaneOrder(source: Int, target: Int) {
        disableCallbackForRowEditing = true
        var tempEditingItemEntryId = ""
        if editingRow != -1 {
            tempEditingItemEntryId = self.practiceItems[editingRow].entryId
        }
        let movedObject = self.practiceItems[source]
        self.practiceItems.remove(at: source)
        self.practiceItems.insert(movedObject, at: target)
        if editingRow != -1 {
            for idx in 0..<self.practiceItems.count {
                if self.practiceItems[idx].entryId == tempEditingItemEntryId {
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
    
    func deletePracticeItem(for entryId:String) {
        for idx in 0..<self.practiceItems.count {
            if entryId == self.practiceItems[idx].entryId {
                self.practiceItems.remove(at: idx)
                return
            }
        }
    }
    
    func setRating(forPracticeItem: String, rating: Double) {
        PracticeItemLocalManager.manager.setRatingValue(forPracticeItem: forPracticeItem, rating: rating)
    }
    
    func ratingValue(for practiceItem: String) -> Double? {
        return PracticeItemLocalManager.manager.ratingValue(forPracticeItem:practiceItem)
    }
    
    func duration(forPracticeItem: String) -> Int? {
        return self.timePracticed[forPracticeItem]
    }
    
    func setDuration(forPracticeItem: String, duration: Int) {
        self.timePracticed[forPracticeItem] = duration
    }
    
    func setEditingRow(for entryId:String) {
        for idx in 0..<self.practiceItems.count {
            if practiceItems[idx].entryId == entryId {
                self.editingRow = idx
                return
            }
        }
    }
    
    func changeCountDownDuration(for entryId:String, duration: Int) {

        for idx in 0..<self.practiceItems.count {
            if self.practiceItems[idx].entryId == entryId {
                let oldCountDownDuration = self.practiceItems[idx].countDownDuration ?? 0
                if oldCountDownDuration != duration {
                    self.countdownReseted[entryId] = true
                }
                self.practiceItems[idx].countDownDuration = duration
                break
            }
        }
        
        self.playlist.practiceItems = practiceItems
        self.storePlaylist()
        
        if let callback = self.callBacks["practiceItems"] {
            callback(.simpleChange, practiceItems, practiceItems)
        }
    }
    
    func next() -> Bool {
        for idx in 0..<self.practiceItems.count {
            if practiceItems[idx].entryId == self.currentPracticeItem.entryId {
                if idx == self.practiceItems.count - 1 {
                    return false
                }
                self.currentPracticeItem = practiceItems[idx + 1]
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
        RecordingsLocalManager.manager.saveCurrentRecording(toFileName: toFileName, playlistId: self.playlist.id, practiceName: self.currentPracticeItem.name, practiceEntryId: self.currentPracticeItem.entryId)
    }
    
    func addNewImprovement(_ improvement: Improvement) {
        self.totalImprovements = self.totalImprovements + 1
        AppOveralDataManager.manager.addImprovementsCount()
    }
}
