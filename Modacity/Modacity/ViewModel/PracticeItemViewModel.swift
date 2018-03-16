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
            self.searchResult = self.searchPracticeItems(keyword: keyword)
            self.configureSectionedResult()
        }
    }
    
    private var removing = 0
    
    private var itemNames: [String] = [String]() {
        didSet {
            if let callback = self.callBacks["itemNames"] {
                if oldValue.count > itemNames.count {
                    callback(.deleted, oldValue, itemNames)
                } else if oldValue.count < itemNames.count {
                    callback(.inserted, oldValue, itemNames)
                } else {
                    callback(.simpleChange, oldValue, itemNames)
                }
            }
        }
    }
    
    private var searchResult: [String] = [String]() {
        didSet {
            if let callback = self.callBacks["searchResult"] {
                callback(.simpleChange, oldValue, searchResult)
            }
        }
    }
    
    var selectedItems: [String] = [String]() {
        didSet {
            if let callback = self.callBacks["selectedItems"] {
                if self.removing > 0 {
                    callback(.deleted, oldValue, selectedItems)
                    self.removing = self.removing - 1
                } else {
                    callback(.simpleChange, oldValue, selectedItems)
                }
            }
        }
    }
    
    var sectionedResult: [String: [String]] = [:] {
        didSet {
            if let callback = self.callBacks["sectionedResult"] {
                if self.removing > 0 {
                    callback(.deleted, oldValue, sectionedResult)
                    self.removing = self.removing - 1
                } else {
                    callback(.simpleChange, oldValue, sectionedResult)
                }
            }
        }
    }
    
    func loadItemNames() {
        if let items = PracticeItemLocalManager.manager.loadAllPracticeItemNames() {
            itemNames = items
        } else {
            itemNames = [String]()
        }
        
        self.searchResult = itemNames
        self.configureSectionedResult()
    }
    
    func addItemtoStore(with name:String) {
        itemNames.append(name)
        searchResult = self.searchPracticeItems(keyword: keyword)
        PracticeItemLocalManager.manager.addNewPracticeItem(with: name)
        selectedItems.append(name)
        self.configureSectionedResult()
    }
    
    func searchResultCount() -> Int {
        var selectedSearchResultCount = 0
        for search in self.searchResult {
            if self.isSelected(for: search) {
                selectedSearchResultCount = selectedSearchResultCount + 1
            }
        }
        return searchResult.count + self.selectedItems.count - selectedSearchResultCount
    }
    
    func sortedSectionedResult() -> [String] {
        return self.sectionedResult.keys.sorted()
    }
    
    func sectionedSearchSectionCount() -> Int {
        return self.sectionedResult.keys.count
    }
    
    func sectionedSearchResultCount(in sectionNumber:Int) -> Int {
        let sectionedSortResult = self.sectionedResult.keys.sorted()
        return self.sectionedResult[sectionedSortResult[sectionNumber]]!.count
    }
    
    func sectionResult(section: Int, row: Int) -> String {
        return self.sectionedResult[self.sortedSectionedResult()[section]]![row]
    }
    
    func configureSectionedResult() {
        
        var totalResult = selectedItems
        for search in searchResult {
            if !self.isSelected(for: search) {
                totalResult.append(search)
            }
        }
        
        var finalResult = [String:[String]]()
        
        for result in totalResult.sorted() {
            var firstCharacter: String!
            
            if result.first == nil || result.lowercased().first! < "a" || result.lowercased().first! > "z" {
                firstCharacter = "#"
            } else {
                firstCharacter = "\(result.first!)".uppercased()
            }
            
            if finalResult[firstCharacter] != nil {
                finalResult[firstCharacter]!.append(result)
            } else {
                finalResult[firstCharacter] = [result]
            }
        }
        
        self.sectionedResult = finalResult
    }
    
    func searchResult(at row:Int) -> String {
        var finalResult = selectedItems
        for search in searchResult {
            if !self.isSelected(for: search) {
                finalResult.append(search)
            }
        }
        return finalResult[row]
    }
    
    func removePracticeItem(for item:String) {
        for idx in 0..<self.itemNames.count {
            let itemName = self.itemNames[idx]
            if itemName.lowercased() == item.lowercased() {
                self.itemNames.remove(at: idx)
                break
            }
        }
        
        self.removing = 1
        
        for idx in 0..<self.searchResult.count {
            let itemName = self.searchResult[idx]
            if itemName.lowercased() == item.lowercased() {
                self.searchResult.remove(at: idx)
                break
            }
        }
        
        for idx in 0..<self.selectedItems.count {
            let itemName = self.selectedItems[idx]
            if itemName.lowercased() == item.lowercased() {
                self.removing = self.removing + 1
                self.selectedItems.remove(at: idx)
                break
            }
        }
        
        self.configureSectionedResult()
        PracticeItemLocalManager.manager.replacePracticeItemNames(newValue: itemNames)
    }
    
    func searchPracticeItems(keyword: String) -> [String] {
        if keyword == "" {
            return self.itemNames
        }
        
        var searchResult = [String]()
        for item in self.itemNames {
            if item.lowercased().contains(keyword.lowercased()) {
                searchResult.append(item)
            }
        }
        
        return searchResult
    }
    
    func changeKeyword(to newKeyword: String) {
        self.keyword = newKeyword
    }
    
    func practiceItemContains(itemName: String) -> Bool {
        for item in self.itemNames {
            if itemName.lowercased() == item.lowercased() {
                return true
            }
        }
        
        return false
    }
    
    func selectItem(for item:String) {
        for idx in 0..<self.selectedItems.count {
            let selectedItem = self.selectedItems[idx]
            if selectedItem == item {
                self.selectedItems.remove(at: idx)
                return
            }
        }
        self.selectedItems.append(item)
    }
    
    func isSelected(for name:String) -> Bool {
        for idx in 0..<self.selectedItems.count {
            let selectedItem = self.selectedItems[idx]
            if selectedItem == name {
                return true
            }
        }
        return false
    }
    
    func canReplaceItem(name: String, to: String) -> Bool {
        for idx in 0..<self.itemNames.count {
            let selectedItem = self.itemNames[idx]
            if selectedItem == to {
                return false
            }
        }
        return true
    }
    
    func replaceItem(name: String, to: String) {
        for idx in 0..<self.selectedItems.count {
            let selectedItem = self.selectedItems[idx]
            if selectedItem == name {
                self.selectedItems[idx] = to
                break
            }
        }
        
        for idx in 0..<self.searchResult.count {
            let selectedItem = self.searchResult[idx]
            if selectedItem == name {
                self.searchResult[idx] = to
                break
            }
        }
        
        for idx in 0..<self.itemNames.count {
            let selectedItem = self.itemNames[idx]
            if selectedItem == name {
                self.itemNames[idx] = to
                break
            }
        }
        
        self.configureSectionedResult()
        PracticeItemLocalManager.manager.replacePracticeItemNames(newValue: itemNames)
    }
    
    func ratingValue(forPracticeItem: String) -> Double? {
        return PracticeItemLocalManager.manager.ratingValue(forPracticeItem:forPracticeItem)
    }
}
