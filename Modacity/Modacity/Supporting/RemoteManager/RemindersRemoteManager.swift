//
//  RemindersRemoteManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 15/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RemindersRemoteManager: NSObject {
    
    static let manager = RemindersRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func addReminder(_ reminder: Reminder) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("reminders").child(reminder.id).setValue(reminder.toJSON())
        }
    }
    
    func removeReminder(id:String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("reminders").child(id).removeValue()
        }
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("reminders").child(reminder.id).updateChildValues(reminder.toJSON())
        }
    }
    
    func eraseReminders(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("reminders").removeValue { (_, _) in
                completion()
            }
        }
        RemindersManager.manager.cleanReminders()
    }
    
    func fetchRemindersFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("reminders").keepSynced(true)
            self.refUser.child(userId).child("reminders").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        
                        var reminders = [String: [String:Any]]()
                        
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                reminders[dataSnapshot.key] = data
                            }
                        }
                        
                        RemindersManager.manager.storeReminders(reminders)
                        RemindersManager.manager.generateFullReminderNotificaitons()
                    }
                }
            }
        }
    }
    
    func fullSync(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            let ref = self.refUser.child(userId).child("reminders")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        RemindersManager.manager.cleanReminders()
                        var reminders = [String: [String:Any]]()
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                reminders[dataSnapshot.key] = data
                            }
                        }
                        
                        RemindersManager.manager.storeReminders(reminders)
                        RemindersManager.manager.generateFullReminderNotificaitons()
                    }
                }
                completion()
            }
        }
    }
    
}
