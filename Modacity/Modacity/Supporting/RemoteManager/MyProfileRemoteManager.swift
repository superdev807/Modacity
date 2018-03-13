//
//  MyProfileManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
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
            self.profileListnerHandler = self.refUser.child(userId).child("profile").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let profile = snapshot.value as? [String:Any] {
                        MyProfileLocalManager.manager.me = Me(JSON: profile)
                        NotificationCenter.default.post(name: AppConfig.appNotificationProfileUpdated, object: nil)
                    }
                }
            }
        }
    }
    
    func signout() {
        if self.profileListnerHandler != nil {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.refUser.child(userId).child("profile").removeObserver(withHandle: self.profileListnerHandler!)
            }
        }
    }
}
