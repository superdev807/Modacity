//
//  PracticeItemLocalManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/1/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
                        if item.visible {
                            items.append(item)
                        }
                    }
                }
            }
            return items
        }
        return nil
    }
    
    func cleanPracticeItems() {
        if let ids = self.practiceItemIds() {
            for id in ids {
                UserDefaults.standard.removeObject(forKey: "practice:id:" + id)
            }
            UserDefaults.standard.removeObject(forKey: "practice_item_ids")
        }
        UserDefaults.standard.synchronize()
    }
    
    func addPracticeItem(_ practiceItem:PracticeItem, isDefault: Bool) {
        
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
            
            if !isDefault {
                if Authorizer.authorizer.isGuestLogin() {
                    GuestCacheManager.manager.practiceItemIds.append(practiceItemId)
                }
            }
            
            PracticeItemRemoteManager.manager.add(item: practiceItem)
        }
    }
    
    func removePracticeItem(for item:PracticeItem) {
        UserDefaults.standard.removeObject(forKey: "practice:id:" + item.id)
        
        if item.isFavorite != 0 {
            if let favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
                var newFavoriteItemIds = [String]()
                for itemId in favoritePracticeItemIds {
                    if itemId != item.id {
                        newFavoriteItemIds.append(itemId)
                    }
                }
                UserDefaults.standard.set(newFavoriteItemIds, forKey: "favorite_practice_item_ids")
                
                PracticeItemRemoteManager.manager.updateFavoriteItemIds(newFavoriteItemIds)
            }
        }
        
        UserDefaults.standard.synchronize()
        
        PlaylistLocalManager.manager.processPracticeItemRemove(item.id)
        PracticeItemRemoteManager.manager.removePracticeItem(for: item.id)
    }
    
    func updatePracticeItem(_ item:PracticeItem) {
        UserDefaults.standard.set(item.toJSON(), forKey: "practice:id:" + item.id)
        UserDefaults.standard.synchronize()
        PracticeItemRemoteManager.manager.update(item:item)
    }
    
    func practiceItem(forId: String) -> PracticeItem? {
        if let string = UserDefaults.standard.object(forKey: "practice:id:" + forId) as? [String:Any] {
            if let item = PracticeItem(JSON: string) {
                return item
            }
        }
        return nil
    }
    
    func practiceItemRemoved(forId: String) -> Bool {
        return UserDefaults.standard.object(forKey: "practice:id:" + forId) == nil
    }
    
    func loadAllPracticeItemNames() -> [String]? {
        if let practiceItemNamesJSONString = UserDefaults.standard.string(forKey: "practice_item_names") {
            return practiceItemNamesJSONString.toJSON() as? [String]
        }
        return nil
    }
    
    func isFavoritePracticeItem(for item:String) -> Bool {
        if let practice = self.practiceItem(forId: item) {
            return practice.isFavorite == 1
        }
        
        return false
    }
    
    func ratingValue(for itemId: String) -> Double? {
        if let practice = self.practiceItem(forId: itemId) {
            return practice.rating
        }
        
        return nil
    }
    
    func setFavoritePracticeItem(forItemId:String) {
        if let practice = self.practiceItem(forId: forItemId) {
            if practice.isFavorite == 1 {
                practice.updateFavorite(favorite: false)
                self.updateFavoriteIds(withRemovingItemId: forItemId)
            } else {
                practice.updateFavorite(favorite: true)
                self.updateFavoriteIds(withNewItemId: forItemId)
            }
        }
    }
    
    func setRatingValue(forItemId: String, rating: Double) {
        if let practice = self.practiceItem(forId: forItemId) {
            practice.updateRating(rating: rating)
        }
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
        
        if let favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
            PracticeItemRemoteManager.manager.updateFavoriteItemIds(favoritePracticeItemIds)
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
        
        if let favoritePracticeItemIds = UserDefaults.standard.object(forKey: "favorite_practice_item_ids") as? [String] {
            PracticeItemRemoteManager.manager.updateFavoriteItemIds(favoritePracticeItemIds)
        }
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
    
    func signout() {
        
        if let itemIds = self.practiceItemIds() {
            for itemId in itemIds {
                UserDefaults.standard.removeObject(forKey: "practice:id:" + itemId)
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "favorite_practice_item_ids")
        UserDefaults.standard.removeObject(forKey: "practice_item_ids")
        UserDefaults.standard.synchronize()
    }
}
