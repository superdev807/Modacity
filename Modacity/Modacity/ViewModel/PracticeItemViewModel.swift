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
        }
    }
    
    private var removing = false
    
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
                if self.removing {
                    callback(.deleted, oldValue, searchResult)
                    self.removing = false
                } else {
                    callback(.simpleChange, oldValue, searchResult)
                }
            }
        }
    }
    
    var selectedItems: [String] = [String]() {
        didSet {
            if let callback = self.callBacks["selectedItems"] {
                callback(.simpleChange, oldValue, selectedItems)
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
    }
    
    func addItemtoStore(with name:String) {
        itemNames.append(name)
        searchResult = self.searchPracticeItems(keyword: keyword)
        PracticeItemLocalManager.manager.addNewPracticeItem(with: name)
        selectedItems.append(name)
    }
    
    func searchResultCount() -> Int {
        return searchResult.count
    }
    
    func searchResult(at row:Int) -> String {
        return searchResult[row]
    }
    
    func removePracticeItem(at row:Int) {
        let item = searchResult[row]
        for idx in 0..<self.itemNames.count {
            let itemName = self.itemNames[idx]
            if itemName.lowercased() == item.lowercased() {
                self.itemNames.remove(at: idx)
                break
            }
        }
        self.removing = true
        searchResult.remove(at: row)
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
    
    func selectItem(at row:Int) {
        let item = self.searchResult[row]
        for idx in 0..<self.selectedItems.count {
            let selectedItem = self.selectedItems[idx]
            if selectedItem == item {
                self.selectedItems.remove(at: idx)
                return
            }
        }
        self.selectedItems.append(item)
    }
    
    func isSelected(for row:Int) -> Bool {
        let item = self.searchResult[row]
        for idx in 0..<self.selectedItems.count {
            let selectedItem = self.selectedItems[idx]
            if selectedItem == item {
                return true
            }
        }
        return false
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
        
        PracticeItemLocalManager.manager.replacePracticeItemNames(newValue: itemNames)
    }
}
