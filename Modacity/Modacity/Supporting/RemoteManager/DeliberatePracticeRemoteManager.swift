//
//  DeliberatePracticeRemoteManager.swift
//  Modacity
//
//  Created by Dream Realizer on 13/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DeliberatePracticeRemoteManager: NSObject {
    
    static let manager = DeliberatePracticeRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    func fetchDeliberatePractices() {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("deliberate").keepSynced(true)
            self.refUser.child(userId).child("deliberate").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    var suggestions = [String:DeliberatePracticeSuggestion]()
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
                                    suggestions[suggestion.suggestion] = suggestion
                                }
                            }
                        }
                    }
                    DeliberatePracticeManager.manager.storeCustomizedSuggestions(suggestions)
                }
            }
        }
    }
    
    func addDeliberatePractice(_ practice: DeliberatePracticeSuggestion) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("deliberate").child(practice.suggestion.lowercased()).setValue(practice.toJSON())
        }
    }
    
    func eraseDeliberatePractices(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("deliberate").removeValue { (_, _) in
                completion()
            }
        }
        DeliberatePracticeManager.manager.cleanDeliberatePracticeManager()
    }
    
    func fullSync(completion: @escaping ()->()) {
        if let userId = MyProfileLocalManager.manager.userId() {
            let ref = self.refUser.child(userId).child("deliberate")
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    DeliberatePracticeManager.manager.cleanDeliberatePracticeManager()
                    var suggestions = [String:DeliberatePracticeSuggestion]()
                    if let dataSnapshots = snapshot.children.allObjects as? [DataSnapshot] {
                        for dataSnapshot in  dataSnapshots {
                            if let data = dataSnapshot.value as? [String:Any] {
                                if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
                                    suggestions[suggestion.suggestion] = suggestion
                                }
                            }
                        }
                    }
                    DeliberatePracticeManager.manager.storeCustomizedSuggestions(suggestions)
                }
                completion()
            }
        }
    }
}
