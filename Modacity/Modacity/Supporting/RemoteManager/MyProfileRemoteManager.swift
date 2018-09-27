//
//  MyProfileManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Crashlytics

class MyProfileRemoteManager {
    
    static let manager = MyProfileRemoteManager()
    
    let refUser = Database.database().reference().child("users")
    
    var profileListnerHandler : UInt?
    
    var listenerPaused = false
    
    func createMyProfile(userId: String, data: [String:Any]) {
        self.refUser.child(userId).child("profile").setValue(data)
    }
    
    func configureMyProfileListener() {
        if let userId = MyProfileLocalManager.manager.userId() {
            ModacityDebugger.debug("user id - \(userId)")
            Crashlytics.sharedInstance().setUserIdentifier(userId)
            
            self.profileListnerHandler = self.refUser.child(userId).child("profile").observe(.value) { (snapshot) in
                if snapshot.exists() {
                    if let profile = snapshot.value as? [String:Any] {
                        MyProfileLocalManager.manager.me = Me(JSON: profile)
                        Crashlytics.sharedInstance().setUserName(MyProfileLocalManager.manager.me?.name ?? "___")
                        Crashlytics.sharedInstance().setUserEmail(MyProfileLocalManager.manager.me?.email ?? "__@__")
                        NotificationCenter.default.post(name: AppConfig.appNotificationProfileUpdated, object: nil)
                    }
                }
            }
            
            DispatchQueue.global(qos: .background).async {
                WalkthroughRemoteManager.manager.syncFirst()
                PracticeItemRemoteManager.manager.syncFirst()
                PlaylistRemoteManager.manager.syncFirst()
                OverallDataRemoteManager.manager.syncFirst()
                MusicQuotesManager.manager.loadQuotesFromServer()
                DailyPracticingRemoteManager.manager.fetchPracticingDataFromServer()
                DailyPracticingRemoteManager.manager.fetchPlaylistPracticingDataFromServer()
                PremiumDataManager.manager.fetchPremiumUpgradeStatus()
                GoalsRemoteManager.manager.fetchGoalsFromServer()
            }
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
                currentUser.reauthenticateAndRetrieveData(with: EmailAuthProvider.credential(withEmail: email, password: current)) { (_, error) in
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
    
    func processOffline() {
        if let listener = self.profileListnerHandler,
            let userId = MyProfileLocalManager.manager.userId() {
            self.refUser.child(userId).child("profile").removeObserver(withHandle: listener)
            self.profileListnerHandler = nil
            listenerPaused = true
        }
    }
    
    func processResumeOnline() {
        if listenerPaused {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.profileListnerHandler = self.refUser.child(userId).child("profile").observe(.value) { (snapshot) in
                    if snapshot.exists() {
                        if let profile = snapshot.value as? [String:Any] {
                            MyProfileLocalManager.manager.me = Me(JSON: profile)
                            Crashlytics.sharedInstance().setUserName(MyProfileLocalManager.manager.me?.name ?? "___")
                            Crashlytics.sharedInstance().setUserEmail(MyProfileLocalManager.manager.me?.email ?? "__@__")
                            NotificationCenter.default.post(name: AppConfig.appNotificationProfileUpdated, object: nil)
                        }
                    }
                }
            }
            listenerPaused = false
        }
    }
    
    func signout() {
        if self.profileListnerHandler != nil {
            if let userId = MyProfileLocalManager.manager.userId() {
                self.refUser.child(userId).child("profile").removeObserver(withHandle: self.profileListnerHandler!)
                self.profileListnerHandler = nil
                listenerPaused = false
            }
        }
    }
}
