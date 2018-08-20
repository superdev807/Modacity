//
//  MusicQuotesManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MusicQuotesManager: NSObject {
    
    static let manager = MusicQuotesManager()
    
    var localQuotes = [["quote":"Mistakes are immensely useful. They show us where we are right now and what we need to do next.", "person": "William Westney"],
                       ["quote":"Adapt what is useful, reject what is useless, and add what is specifically your own.", "person": "Bruce Lee"],
                       ["quote": "Let the path be open to talent.", "person":"Napoleon Bonaparte"],
                       ["quote":"I have no special talent. I am only passionateyl curious", "person": "Albert Einstein"],
                       ["quote":"Practice makes the master.", "person": "Patrick Rothfuss"]]
    
    func randomeQuote() -> [String:String] {
        return self.localQuotes[Int(arc4random_uniform(UInt32(self.localQuotes.count)))]
    }
    
    func loadQuotesFromServer() {
        Database.database().reference().child("quotes").observe(.value) { (snapshot) in
            if snapshot.exists() {
                if let all = snapshot.children.allObjects as? [DataSnapshot] {
                    for data in all {
                        if let newQuote = data.value as? [String:String] {
                            let quoteText = newQuote["quote"] ?? ""
                            var alreadyAdded = false
                            for quote in self.localQuotes {
                                if quoteText == (quote["quote"] ?? "") {
                                    alreadyAdded = true
                                }
                            }
                            if !alreadyAdded {
                                self.localQuotes.append(newQuote)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
