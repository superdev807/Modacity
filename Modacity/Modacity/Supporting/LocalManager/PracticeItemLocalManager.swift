//
//  PracticeItemLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/1/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PracticeItemLocalManager {
    
    static let manager = PracticeItemLocalManager()
    
    private func practiceItemIds() -> [String]? {
        return UserDefaults.standard.object(forKey: "practice_item_ids") as? [String]
    }
    
    private func savePracticeItemsIds(_ itemIds:[String]) {
        UserDefaults.standard.set(itemIds, forKey: "practice_item_ids")
        UserDefaults.standard.synchronize()
    }
    
    func syncWithOlderVersions() {
        
        if let olderVersionPracticeItemNamesSaved = self.loadAllPracticeItemNames() {
            var practiceItems = [PracticeItem]()
            for itemName in olderVersionPracticeItemNamesSaved {
                let practiceItem = PracticeItem()
                practiceItem.id = UUID().uuidString
                practiceItem.name = itemName
                
                if UserDefaults.standard.bool(forKey: "favorite_" + itemName) {
                    self.setFavoritePracticeItem(forItemId: practiceItem.id)
                }
                
                let rating = UserDefaults.standard.double(forKey: "rating-" + itemName)
                if rating > 0 {
                    self.setRatingValue(forItemId: practiceItem.id, rating: rating)
                }
                
                practiceItems.append(practiceItem)
                
                UserDefaults.standard.removeObject(forKey: "favorite_" + itemName)
                UserDefaults.standard.removeObject(forKey: "rating-" + itemName)
            }
            storePracticeItems(practiceItems)
            UserDefaults.standard.removeObject(forKey: "practice_item_names")
            UserDefaults.standard.synchronize()
        }
    }
    
    func searchPracticeItem(byName: String) -> PracticeItem? {
        if let items = self.loadPracticeItems() {
            for item in items {
                if item.name.lowercased() == byName.lowercased() {
                    return item
                }
            }
        }
        return nil
    }
    
    func storePracticeItems(_ items:[PracticeItem]) {
        var ids = [String]()
        for item in items {
            ids.append(item.id)
            UserDefaults.standard.set(item.toJSON(), forKey: "practice:id:" + item.id)
        }
        self.savePracticeItemsIds(ids)
        UserDefaults.standard.synchronize()
    }
    
    func loadPracticeItems() -> [PracticeItem]? {
        if let ids = self.practiceItemIds() {
            var items = [PracticeItem]()
            for id in ids {
                if let string = UserDefaults.standard.object(forKey: "practice:id:" + id) as? [String:Any] {
                    if let item = PracticeItem(JSON: string) {
                        items.append(item)
                    }
                }
            }
            return items
        }
        return nil
    }
    
    func addPracticeItem(_ practiceItem:PracticeItem) {
        if let practiceItemId = practiceItem.id {
            if var itemIds = self.practiceItemIds() {
                itemIds.append(practiceItemId)
                self.savePracticeItemsIds(itemIds)
            } else {
                let itemIds = [practiceItemId]
                self.savePracticeItemsIds(itemIds)
            }
            
            UserDefaults.standard.set(practiceItem.toJSON(), forKey: "practice:id:" + practiceItemId)
            UserDefaults.standard.synchronize()
        }
    }
    
    func removePracticeItem(for item:PracticeItem) {
        UserDefaults.standard.removeObject(forKey: "practice:id:" + item.id)
        UserDefaults.standard.synchronize()
    }
    
    func updatePracticeItem(_ item:PracticeItem) {
        UserDefaults.standard.set(item.toJSON(), forKey: "practice:id:" + item.id)
        UserDefaults.standard.synchronize()
    }
    
    func practiceItem(forId: String) -> PracticeItem? {
        if let string = UserDefaults.standard.object(forKey: "practice:id:" + forId) as? [String:Any] {
            if let item = PracticeItem(JSON: string) {
                return item
            }
        }
        return nil
    }
    
    func loadAllPracticeItemNames() -> [String]? {
        if let practiceItemNamesJSONString = UserDefaults.standard.string(forKey: "practice_item_names") {
            return practiceItemNamesJSONString.toJSON() as? [String]
        }
        return nil
    }
    
    func isFavoritePracticeItem(for item:String) -> Bool {
        return UserDefaults.standard.bool(forKey: "favorite_\(item)")
    }
    
    func ratingValue(for itemId: String) -> Double? {
        if UserDefaults.standard.object(forKey:"rating-" + itemId) == nil {
            return nil
        } else {
            return UserDefaults.standard.double(forKey:"rating-" + itemId)
        }
    }
    
    func setFavoritePracticeItem(forItemId:String) {
        let isFavorite = UserDefaults.standard.bool(forKey: "favorite_\(forItemId)")
        if isFavorite {
            UserDefaults.standard.removeObject(forKey: "favorite_\(forItemId)")
            self.updateFavoriteIds(withRemovingItemId:forItemId)
        } else {
            UserDefaults.standard.set(true, forKey: "favorite_\(forItemId)")
            self.updateFavoriteIds(withNewItemId:forItemId)
        }
        UserDefaults.standard.synchronize()
    }
    
    func setRatingValue(forItemId: String, rating: Double) {
        UserDefaults.standard.set(rating, forKey: "rating-" + forItemId)
        UserDefaults.standard.synchronize()
    }
    
    func updateFavoriteIds(withRemovingItemId: String) {
        if var favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
            for idx in 0..<favoritePracticeItemIds.count {
                let id = favoritePracticeItemIds[idx]
                if id == withRemovingItemId {
                    favoritePracticeItemIds.remove(at: idx)
                    break
                }
            }
            UserDefaults.standard.set(favoritePracticeItemIds, forKey: "favorite_practice_item_ids")
            UserDefaults.standard.synchronize()
        }
    }
    
    func updateFavoriteIds(withNewItemId: String) {
        if var favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
            for id in favoritePracticeItemIds {
                if id == withNewItemId {
                    return
                }
            }
            favoritePracticeItemIds.append(withNewItemId)
            UserDefaults.standard.set(favoritePracticeItemIds, forKey: "favorite_practice_item_ids")
        } else {
            UserDefaults.standard.set([withNewItemId], forKey: "favorite_practice_item_ids")
        }
        
        UserDefaults.standard.synchronize()
    }

    func loadAllFavoritePracticeItems() -> [PracticeItem]? {
        if let favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
            var result = [PracticeItem]()
            for itemId in favoritePracticeItemIds {
                if let practiceItem = self.practiceItem(forId: itemId) {
                    result.append(practiceItem)
                }
            }
            return result
        }
        return nil
    }
}
