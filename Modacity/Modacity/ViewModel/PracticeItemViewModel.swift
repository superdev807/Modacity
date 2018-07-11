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
        return self.sectionedPracticeItems.keys.sorted()
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
        
        var totalResult = selectedPracticeItems
        for search in searchedPracticeItems {
            if !self.isSelected(for: search) {
                totalResult.append(search)
            }
        }
        
        var finalResult = [String:[PracticeItem]]()
        
        totalResult = totalResult.sorted(by: { (item1, item2) -> Bool in
            return item1.name < item2.name
        })
        
        for item in totalResult {
            var firstCharacter: String!
            
            if let result = item.name {
                if result.first == nil || result.lowercased().first! < "a" || result.lowercased().first! > "z" {
                    firstCharacter = "#"
                } else {
                    firstCharacter = "\(result.first!)".uppercased()
                }
                
                if finalResult[firstCharacter] != nil {
                    finalResult[firstCharacter]!.append(item)
                } else {
                    finalResult[firstCharacter] = [item]
                }
            }
        }
        
        self.sectionedPracticeItems = finalResult
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
}
