//
//  MyProfileManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyProfileRemoteManager {
    
    static let manager = MyProfileRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    var profileListnerHandler : UInt?
    
    func createMyProfile(userId: String, data: [String:Any]) {
        self.refUser.child(userId).child("profile").setValue(data)
    }
    
    func configureMyProfileListener() {
        if let userId = MyProfileLocalManager.manager.userId() {
            print("user id - \(userId)")
            self.profileListnerHandler = self.refUser.child(userId).child("profile").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let profile = snapshot.value as? [String:Any] {
                        MyProfileLocalManager.manager.me = Me(JSON: profile)
                        NotificationCenter.default.post(name: AppConfig.appNotificationProfileUpdated, object: nil)
                    }
                }
            }
            
            PracticeItemRemoteManager.manager.syncFirst()
            PlaylistRemoteManager.manager.syncFirst()
            MusicQuotesManager.manager.loadQuotesFromServer()
        }
    }
    
    func updateDisplayName(to name:String) {
        if let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("profile").updateChildValues(["name": name])
        }
    }
    
    func updatePassword(current: String, newPassword: String, completion: @escaping (String?)->()) {
        if let currentUser = Auth.auth().currentUser {
            if let email = currentUser.email {
                currentUser.reauthenticate(with: EmailAuthProvider.credential(withEmail: email, password: current)) { (error) in
                    if let error = error {
                        completion(error.localizedDescription)
                    } else {
                        currentUser.updatePassword(to: newPassword, completion: { (error) in
                            if let error = error {
                                completion(error.localizedDescription)
                            } else {
                                completion(nil)
                            }
                        })
                    }
                }
                return
            }
        }
        
        completion("Unknown error!")
    }
    
    func signout() {
        if self.profileListnerHandler != nil {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.refUser.child(userId).child("profile").removeObserver(withHandle: self.profileListnerHandler!)
            }
        }
    }
}
