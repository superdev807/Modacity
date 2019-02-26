//
//  PracticeItemRemoteManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/9/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PracticeItemRemoteManager {
    
    static let manager = PracticeItemRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func syncFirst() {      // if firebase online backup has not created, yet
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practices").keepSynced(true)
            self.refUser.child(userId).child("practices").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    if (!snapshot.exists()) {
                        self.startUPloadAllPracticeItems()      // sync from local
                    } else {
                        for data in snapshot.children.allObjects as! [DataSnapshot] {
                            if let practiceItem = data.value as? [String:Any] {
                                if let item = PracticeItem(JSON: practiceItem) {
                                    if PracticeItemLocalManager.manager.practiceItem(forId: item.id) == nil {
                                        PracticeItemLocalManager.manager.addPracticeItem(item, isDefault: false)
                                    }
                                }
                            }
                        }
                    }
                    
                    self.setPracticeItemsSynchronized()
                    NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationPracticeLoadedFromServer))
                }
            }
        }
    }
    
    func eraseData(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practices").removeValue { (_, _) in
                completion()
            }
        }
        PracticeItemLocalManager.manager.cleanPracticeItems()
    }
    
    func fullSync(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("practices").observeSingleEvent(of: .value) { (snapshot) in
                DispatchQueue.global(qos: .background).async {
                    PracticeItemLocalManager.manager.cleanPracticeItems()
                    for data in snapshot.children.allObjects as! [DataSnapshot] {
                        if let practiceItem = data.value as? [String:Any] {
                            if let item = PracticeItem(JSON: practiceItem) {
                                if PracticeItemLocalManager.manager.practiceItem(forId: item.id) == nil {
                                    PracticeItemLocalManager.manager.addPracticeItem(item, isDefault: false)
                                }
                            }
                        }
                    }
                    
                    completion()
                }
            }
        }
    }
    
    func practiceItemsSynchronized() -> Bool {
        return UserDefaults.standard.bool(forKey: "practice_items_synchronized")
    }
    
    func setPracticeItemsSynchronized() {
        UserDefaults.standard.set(true, forKey: "practice_items_synchronized")
        UserDefaults.standard.synchronize()
    }
    
    func startUPloadAllPracticeItems() {
        if let userId = MyProfileLocalManager.manager.userId() {
            if let practiceItems = PracticeItemLocalManager.manager.loadPracticeItems() {
                
                ModacityDebugger.debug("Uploading all local practice items to backend.")
                
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
    
//    func updateFavoriteItemIds(_ itemIds: [String]) {
//        if let userId = MyProfileLocalManager.manager.userId() {
//            self.refUser.child(userId).updateChildValues(["favorite_ids": itemIds])
//        }
//    }
    
    
    func storeFavoritePractice(itemId: String, value: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("favorite_practices").child(itemId).setValue(value)
        }
    }
    
    func removeFavoritePractice(itemId: String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("favorite_practices").child(itemId).removeValue()
        }
    }
}
