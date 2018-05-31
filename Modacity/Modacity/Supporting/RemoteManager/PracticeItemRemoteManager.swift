//
//  PracticeItemRemoteManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 4/9/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PracticeItemRemoteManager {
    
    static let manager = PracticeItemRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practices").observeSingleEvent(of: .value) { (snapshot) in
                if (!snapshot.exists()) {
                    self.startUPloadAllPracticeItems()      // sync from local
                } else {
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let practiceItem = data.value as? [String:Any] {
                            if let item = PracticeItem(JSON: practiceItem) {
                                if PracticeItemLocalManager.manager.practiceItem(forId: item.id) == nil {
                                    PracticeItemLocalManager.manager.addPracticeItem(item)
                                }
                            }
                        }
                    }
                    NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPracticeLoadedFromServer))
                }
            }
            
            self.refUser.child(userId).child("favorite_ids").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    var favoriteIds = [String]()
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let id = data.value as? String {
                            favoriteIds.append(id)
                        }
                    }
                    UserDefaults.standard.set(favoriteIds, forKey: "favorite_practice_item_ids")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(Notification(name: AppConfig.appNotificationPracticeLoadedFromServer))
                }
            }
        }
    }
    
    func startUPloadAllPracticeItems() {
        if let userId = MyProfileLocalManager.manager.userId() {
            if let practiceItems = PracticeItemLocalManager.manager.loadPracticeItems() {
                
                print("Uploading all local practice items to backend.")
                
                for practiceItem in practiceItems {
                    refUser.child(userId).child("practices").child(practiceItem.id).setValue(practiceItem.toJSON())
                }
            }
        }
    }
    
    func dbReferenceForPracticeItemds() -> DatabaseReference? {
        if let userId = MyProfileLocalManager.manager.userId() {
            return refUser.child(userId).child("practices")
        }
        
        return nil
    }
    
    func dbReference(for itemId:String) -> DatabaseReference? {
        if let userId = MyProfileLocalManager.manager.userId() {
            return refUser.child(userId).child("practices").child(itemId)
        }
        
        return nil
    }
    
    func removePracticeItem(for itemId:String) {
        if let db = self.dbReference(for: itemId) {
            db.removeValue()
        }
    }
    
    func update(item: PracticeItem) {
        if let db = self.dbReference(for: item.id) {
            db.updateChildValues(item.toJSON())
        }
    }
    
    func add(item: PracticeItem) {
        if let db = self.dbReference(for: item.id) {
            db.setValue(item.toJSON())
        }
    }
    
    func updateFavoriteItemIds(_ itemIds: [String]) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).updateChildValues(["favorite_ids": itemIds])
        }
    }
}
