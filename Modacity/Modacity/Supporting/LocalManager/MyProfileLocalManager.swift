//
//  MyProfileLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseAuth

class MyProfileLocalManager {
    
    static let manager = MyProfileLocalManager()
    
    var me:Me? = nil
    
    func userId() -> String? {
        if let myUid = me?.uid {
            return myUid
        } else {
            if Auth.auth().currentUser != nil {
                return Auth.auth().currentUser?.uid
            } else {
                return nil
            }
        }
    }
    
    func signout() {
        me = nil
    }
}
