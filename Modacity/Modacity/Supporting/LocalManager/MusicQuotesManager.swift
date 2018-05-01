//
//  MusicQuotesManager.swift
//  Modacity
//
//  Created by BC Engineer on 2/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MusicQuotesManager: NSObject {
    
    static let manager = MusicQuotesManager()
    
    var localQuotes = [["quote":"Mistakes are immensely useful. They show us where we are right now and what we need to do next.", "person": "William Westney"],
                       ["quote":"The world must be filled with unsuccessful musical careers like mine, and it’s probably a good thing. We don’t need a lot of bad musicians filling the air with unnecessary sounds. Some of the professionals are bad enough.", "person": "Andy Rooney"],
                       ["quote":"Life can’t be all bad when for ten dollars you can buy all the Beethoven sonatas and listen to them for ten years.", "person": "William F. Buckley, Jr"],
                       ["quote":"I never had much interest in the piano until I realized that every time I played, a girl would appear on the piano bench to my left and another to my right.", "person": "Duke Ellington"],
                       ["quote":"When I was a little boy, I told my dad, ‘When I grow up, I want to be a musician.’ My dad said: ‘You can’t do both, Son.", "person": "Chet Atkins"]]
    
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
