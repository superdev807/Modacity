//
//  Me.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class Me: Mappable {
    
    var uid: String!
    var email: String!
    var createdAt: TimeInterval!
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uid         <- map["uid"]
        email       <- map["email"]
        createdAt   <- map["created_at"]
        name        <- map["name"]
    }
    
    func displayName() -> String {
        if name == nil || name == "" {
            let emailPref = email.components(separatedBy: "@")[0]
            var names = [String]()
            var name = ""
            for idx in 0..<emailPref.count {
                let letter = String(emailPref[emailPref.index(emailPref.startIndex, offsetBy: idx)])
                if letter.lowercased() < "a" || letter.lowercased() > "z" {
                    if name != "" {
                        names.append(name.capitalizingFirstLetter())
                        name = ""
                    }
                } else {
                    name = name + letter
                }
            }
            if name != "" {
                names.append(name)
            }
            return names.joined(separator: " ")
        } else {
            return name!
        }
    }
}
