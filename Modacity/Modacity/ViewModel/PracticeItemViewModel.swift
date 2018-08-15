//
//  PracticeItemViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/2/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeItemViewModel: ViewModel {
    
    var keyword = "" {
        didSet {
            self.searchedPracticeItems = self.searchPracticeItems(keyword: keyword)
            self.configureSectionedResult()
        }
    }
    
    private var removing = 0
    
    var practiceItems: [PracticeItem] = [PracticeItem]() {
        didSet {
            if let callback = self.callBacks["practiceItems"] {
                if oldValue.count > practiceItems.count {
                    callback(.deleted, oldValue, practiceItems)
                } else if oldValue.count < practiceItems.count {
                    callback(.inserted, oldValue, practiceItems)
                } else {
                    callback(.simpleChange, oldValue, practiceItems)
                }
            }
        }
    }
    
    private var searchedPracticeItems: [PracticeItem] = [PracticeItem]() {
        didSet {
            if let callback = self.callBacks["searchedPracticeItems"] {
                callback(.simpleChange, oldValue, searchedPracticeItems)
            }
        }
    }
    
    var selectedPracticeItems: [PracticeItem] = [PracticeItem]() {
        didSet {
            if let callback = self.callBacks["selectedPracticeItems"] {
                if self.removing > 0 {
                    callback(.deleted, oldValue, selectedPracticeItems)
                    self.removing = self.removing - 1
                } else {
                    callback(.simpleChange, oldValue, selectedPracticeItems)
                }
            }
        }
    }
    
    var sectionedPracticeItems: [String:[PracticeItem]] = [:] {
        didSet {
            if let callback = self.callBacks["sectionedPracticeItems"] {
                if self.removing > 0 {
                    callback(.deleted, oldValue, sectionedPracticeItems)
                    self.removing = self.removing - 1
                } else {
                    callback(.simpleChange, oldValue, sectionedPracticeItems)
                }
            }
        }
    }
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.descending
    
    func initViewModelWithData(key: SortKeyOption,
                               option: SortOption,
                               practiceItems: [PracticeItem],
                               sectionedPracticeItems: [String:[PracticeItem]]) {
        
        self.practiceItems = practiceItems
        self.searchedPracticeItems = practiceItems
        self.sectionedPracticeItems = sectionedPracticeItems
        
    }
    
    func loadItemNames() {
        if let items = PracticeItemLocalManager.manager.loadPracticeItems() {
            practiceItems = items
        } else {
            practiceItems = [PracticeItem]()
        }
        searchedPracticeItems = practiceItems
        self.configureSectionedResult()
    }
    
    func addItemtoStore(with name:String) {
        let practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = name
        
        practiceItems.append(practiceItem)
        searchedPracticeItems = self.searchPracticeItems(keyword: keyword)
        self.selectedPracticeItems.append(practiceItem)
        self.configureSectionedResult()
        
        PracticeItemLocalManager.manager.storePracticeItems(practiceItems)
        PracticeItemRemoteManager.manager.add(item: practiceItem)
    }
    
    func searchResultCount() -> Int {
        var selectedSearchResultCount = 0
        for search in self.searchedPracticeItems {
            if self.isSelected(for: search) {
                selectedSearchResultCount = selectedSearchResultCount + 1
            }
        }
        return searchedPracticeItems.count + self.selectedPracticeItems.count - selectedSearchResultCount
    }
    
    func sortedSectionedResult() -> [String] {
        return self.sectionedPracticeItems.keys.sorted(by: { (key1, key2) -> Bool in
            
            if self.sortKey == .lastPracticedTime {
                let date1 = key1.date(format: "M/d/yy") ?? Date(timeIntervalSince1970: 0)
                let date2 = key2.date(format: "M/d/yy") ?? Date(timeIntervalSince1970: 0)
                return (self.sortOption == .ascending) ? (date1 < date2) : (date1 > date2)
            } else {
                if self.sortOption == .ascending {
                    return key1 < key2
                } else {
                    return key1 > key2
                }
            }
        })
    }
    
    func sectionedSearchSectionCount() -> Int {
        return self.sectionedPracticeItems.keys.count
    }
    
    func sectionedSearchResultCount(in sectionNumber:Int) -> Int {
        return self.sectionedPracticeItems[self.sortedSectionedResult()[sectionNumber]]!.count
    }
    
    func sectionResult(section: Int, row: Int) -> PracticeItem {
        return self.sectionedPracticeItems[self.sortedSectionedResult()[section]]![row]
    }
    
    func configureSectionedResult() {
        
        let time = Date()
        
        var totalResult = selectedPracticeItems
        for search in searchedPracticeItems {
            if !self.isSelected(for: search) {
                totalResult.append(search)
            }
        }
        
        var finalResult = [String:[PracticeItem]]()
        
        for item in totalResult {
            
            var keyString = ""
            switch self.sortKey {
            case .name:
                keyString = item.firstCharacter()
            case .favorites:
                keyString = item.isFavorite == 0 ? "♡" : "♥"
            case .lastPracticedTime:
                keyString = item.lastPracticedDateString()
            case .rating:
                keyString = item.ratingString()
            }
            
            if finalResult[keyString] != nil {
                finalResult[keyString]!.append(item)
            } else {
                finalResult[keyString] = [item]
            }
        }
        
        let sectionNames = Array(finalResult.keys).sorted(by: { (ch1, ch2) -> Bool in
            return (self.sortOption == .ascending) ? (ch1 < ch2) : (ch1 > ch2)
        })
        
        for key in sectionNames {
            if let items = finalResult[key] {
                finalResult[key] = items.sorted(by: { (item1, item2) -> Bool in
                    switch self.sortKey {
                    case .rating:
                        fallthrough
                    case .favorites:
                        fallthrough
                    case .name:
                        return (self.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
                    case .lastPracticedTime:
                        let sortingKey1 = item1.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item1.name
                        let sortingKey2 = item2.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item2.name
                        return (self.sortOption == .ascending) ? (sortingKey1 < sortingKey2) : (sortingKey1 > sortingKey2)
                    }
                })
            }
        }
        
        self.sectionedPracticeItems = finalResult
        print("Sorted time - \(Date().timeIntervalSince1970 - time.timeIntervalSince1970)")
    }
    
    func searchResult(at row:Int) -> PracticeItem {
        var finalResult = selectedPracticeItems
        for search in searchedPracticeItems {
            if !self.isSelected(for: search) {
                finalResult.append(search)
            }
        }
        return finalResult[row]
    }
    
    func removePracticeItem(for item:PracticeItem) {
        for idx in 0..<self.practiceItems.count {
            let practiceItem = self.practiceItems[idx]
            if practiceItem.id == item.id {
                self.practiceItems.remove(at: idx)
                break
            }
        }
        
        self.removing = 1
        
        for idx in 0..<self.searchedPracticeItems.count {
            let practiceItem = self.searchedPracticeItems[idx]
            if practiceItem.id == item.id {
                self.searchedPracticeItems.remove(at: idx)
                break
            }
        }
        
        for idx in 0..<self.selectedPracticeItems.count {
            let practiceItem = self.selectedPracticeItems[idx]
            if practiceItem.id == item.id {
                self.removing = self.removing + 1
                self.selectedPracticeItems.remove(at: idx)
                break
            }
        }
        
        PracticeItemLocalManager.manager.removePracticeItem(for: item)
        PracticeItemLocalManager.manager.storePracticeItems(self.practiceItems)
        
        self.configureSectionedResult()
    }
    
    func searchPracticeItems(keyword: String) -> [PracticeItem] {
        if keyword == "" {
            return self.practiceItems
        }
        
        var searchResult = [PracticeItem]()
        for item in self.practiceItems {
            if item.name.lowercased().contains(keyword.lowercased()) {
                searchResult.append(item)
            }
        }
        
        return searchResult
    }
    
    func changeKeyword(to newKeyword: String) {
        self.keyword = newKeyword
    }
    
    func practiceItemContains(itemName: String) -> Bool {
        for item in self.practiceItems {
            if itemName.lowercased() == item.name.lowercased() {
                return true
            }
        }
        
        return false
    }
    
    func selectItem(for item:PracticeItem) {
        for idx in 0..<self.selectedPracticeItems.count {
            let selectedItem = self.selectedPracticeItems[idx]
            if selectedItem.id == item.id {
                self.selectedPracticeItems.remove(at: idx)
                return
            }
        }
        self.selectedPracticeItems.append(item)
    }
    
    func isSelected(for item:PracticeItem) -> Bool {
        for idx in 0..<self.selectedPracticeItems.count {
            let selectedItem = self.selectedPracticeItems[idx]
            if selectedItem.id == item.id {
                return true
            }
        }
        return false
    }
    
    func canChangeItemName(to: String, forItem: PracticeItem) -> Bool {
        for idx in 0..<self.practiceItems.count {
            let selectedItem = self.practiceItems[idx]
            if selectedItem.id != forItem.id && selectedItem.name == to {
                return false
            }
        }
        return true
    }
    
    func changeItemName(to: String, forItem: PracticeItem) {
        for idx in 0..<self.selectedPracticeItems.count {
            let selectedItem = self.selectedPracticeItems[idx]
            if selectedItem.id == forItem.id {
                selectedItem.name = to
                self.selectedPracticeItems[idx] = selectedItem
                break
            }
        }
        
        for idx in 0..<self.searchedPracticeItems.count {
            let item = self.searchedPracticeItems[idx]
            if item.id == forItem.id {
                item.name = to
                self.searchedPracticeItems[idx] = item
                break
            }
        }
        
        for idx in 0..<self.practiceItems.count {
            let item = self.practiceItems[idx]
            if item.id == forItem.id {
                item.name = to
                self.practiceItems[idx] = item
                PracticeItemRemoteManager.manager.update(item: item)
                break
            }
        }
        
        self.configureSectionedResult()
        PracticeItemLocalManager.manager.storePracticeItems(self.practiceItems)
    }
    
    func ratingValue(forPracticeItem: PracticeItem) -> Double? {
        return PracticeItemLocalManager.manager.ratingValue(for: forPracticeItem.id)
    }
    
    func changeSort(key:SortKeyOption, option: SortOption) {
        self.sortKey = key
        self.sortOption = option
        self.configureSectionedResult()
    }
}
