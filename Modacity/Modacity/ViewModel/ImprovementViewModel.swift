//
//  ImprovementViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit


// this is super ugly code, let's refactor this ASAP to support reading
// these values from a plist or something.
let hypEmotion = ["Feel stronger emotion","Let the feeling evolve","Visualize a meaningful scene","Tell a story"]
let hypNotes = ["Sing the notes slowly and accurately","Visualize getting right notes before playing","Simplify the passage","Insist on note accuracy"]
let hypRhythm = ["Play with MetroDrone","Sing the rhythm","Slowwwww dowwnnnn","Higher standard for precision"]
let hypEase=["Keep body relaxed","Avoid all trying or effort","Focus on relaxed toes","Improve posture"]
let hypConsistency=["Narrow the focus for consistency","Do it 3-5x the same","Allow it to happen","Clarify today's achievable standard"]
let hypPhrasing=["Clarify high and low points","Sing and conduct","Exaggerate phrasing","Focus on ending well"]
let hypTechnique=["Sense body-sound connection","Isolate and repeat","Strive for perfection","Exaggerate flaws, then avoid them"]
let hypTone=["Imagine the desired sound","Free the body of stiffness","Imagine performing in a bigger space","Breathe more fully"]
let hypEnjoyment=["Have more fun!","Forgive flaws and appreciate reality","Avoid self-judgment and stay present","Smile before and during performance"]

class ImprovementViewModel: ViewModel {

    
    let suggestions = ["Notes", "Rhythm", "Consistency", "Tone", "Emotion", "Phrasing", "Technique", "Enjoyment", "Ease"]
    
    let hypotheses: [String:[String]] = [
        "Notes":hypNotes, "Rhythm":hypRhythm, "Consistency":hypConsistency,
        "Tone":hypTone, "Emotion":hypEmotion, "Phrasing":hypPhrasing, "Technique":hypTechnique,
        "Enjoyment":hypEnjoyment, "Ease":hypEase]
    
    var selectedSuggestion: String = ""
    var selectedHypothesis: String = ""
    
    var userOwnSuggestions = [String]()
    
    var alreadyTried = false {
        didSet {
            if let callback = self.callBacks["alreadyTried"] {
                callback(.simpleChange, oldValue, alreadyTried)
            }
        }
    }
    
    func hypothesisList()->[String] {
        return hypotheses[selectedSuggestion] ?? ["Visualize a perfect outcome", "Perform it as a single gesture", "Simplify the concept"]
    }
    
    func generateImprovement(with playlist: Playlist, practice: PlaylistPracticeEntry) -> Improvement {
        return Improvement(JSON: ["id":UUID().uuidString,
                                  "playlist_id": playlist.id,
                                  "practice_name":practice.name,
                                  "practice_entry_id":practice.entryId,
                                  "suggestion":selectedSuggestion,
                                  "hypothesis":selectedHypothesis,
                                  "created_at":"\(Date().timeIntervalSince1970)",])!
    }
    
}
