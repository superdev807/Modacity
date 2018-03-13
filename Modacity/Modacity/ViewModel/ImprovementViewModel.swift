//
//  ImprovementViewModel.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/13/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class ImprovementViewModel: ViewModel {
    
    let  suggestions = ["Notes", "Rythm", "Dynamic", "Tone", "Emotion", "Phrasing", "Technique", "Enjoyment", "Ease"]
    
    var selectedSuggestion: String = ""
    var selectedHypothesis: String = ""
    
    var alreadyTried = false {
        didSet {
            if let callback = self.callBacks["alreadyTried"] {
                callback(.simpleChange, oldValue, alreadyTried)
            }
        }
    }
    
    func hypothesisList()->[String] {
        return ["Play with metronome.", "Keep focus on the end of the phrase.", "Just relax and enjoy playing.", "Suggestion related to rhythm.", "Another suggestion related to rhythm."]
    }
    
    func generateImprovement(with playlist: Playlist, practice: PracticeItemEntry) -> Improvement {
        return Improvement(JSON: ["id":UUID().uuidString,
                                  "playlist_id": playlist.id,
                                  "practice_name":practice.name,
                                  "practice_entry_id":practice.entryId,
                                  "suggestion":selectedSuggestion,
                                  "hypothesis":selectedHypothesis,
                                  "created_at":"\(Date().timeIntervalSince1970)",])!
    }
    
}
