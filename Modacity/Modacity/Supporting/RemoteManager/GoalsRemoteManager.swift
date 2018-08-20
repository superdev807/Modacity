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
    
}
