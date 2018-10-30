//
//  GoalsRemoteManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 6/7/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GoalsRemoteManager: NSObject {
    
    static let manager = GoalsRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func addGoal(_ goal: Note) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("goals").child(goal.id).setValue(goal.toJSON())
        }
    }
    
    func removeGoal(_ goal:Note) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("goals").child(goal.id).removeValue()
        }
    }
    
    func updateGoal(_ goal: Note) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("goals").child(goal.id).updateChildValues(goal.toJSON())
        }
    }
    
    func eraseGoals(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("goals").removeValue { (_, _) in
                completion()
            }
        }
        GoalsLocalManager.manager.cleanGoals()
    }
    
    func fetchGoalsFromServer() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("goals").keepSynced(true)
            self.refUser.child(userId).child("goals").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                if let goal = Note(JSON: data) {
                                    GoalsLocalManager.manager.addGoal(goal)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fullSync(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            let ref = self.refUser.child(userId).child("goals")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        GoalsLocalManager.manager.cleanGoals()
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                if let goal = Note(JSON: data) {
                                    GoalsLocalManager.manager.addGoal(goal)
                                }
                            }
                        }
                    }
                }
                completion()
            }
        }
    }
    
}
