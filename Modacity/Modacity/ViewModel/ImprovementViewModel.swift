//
//  ImprovementViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/13/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ImprovementViewModel: ViewModel {
    
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
        return DeliberatePracticeManager.manager.hypothesisList(for: self.selectedSuggestion)
    }
    
    func suggestionsList() -> [String] {
        return DeliberatePracticeManager.manager.suggestionsList()
    }
    
    func generateImprovement(with playlist: Playlist, practice: PlaylistPracticeEntry) -> Improvement {
        return Improvement(JSON: ["id":UUID().uuidString,
                                  "playlist_id": playlist.id,
                                  "practice_name":practice.practiceItem()?.name ?? "NO PRACTICE ITEM NAME",
                                  "practice_entry_id":practice.entryId,
                                  "suggestion":selectedSuggestion,
                                  "hypothesis":selectedHypothesis,
                                  "created_at":"\(Date().timeIntervalSince1970)",])!
    }
    
    func processSuggestionCustomization() {
        let suggestions = DeliberatePracticeManager.manager.suggestionsList()
        for suggestion in suggestions {
            if selectedSuggestion.lowercased() == suggestion.lowercased() {
                return
            }
        }
        
        let customizedSuggestion = DeliberatePracticeSuggestion()
        customizedSuggestion.isStandard = false
        customizedSuggestion.suggestion = selectedSuggestion
        customizedSuggestion.hypos = []
        
        var alreadyIncluded = false
        
        if let hypos = DeliberatePracticeManager.manager.defaultHypos {
            for hypo in hypos {
                if hypo.lowercased() == selectedHypothesis.lowercased() {
                    alreadyIncluded = true
                    break
                }
            }
        }
        
        if !alreadyIncluded {
            DeliberatePracticeManager.manager.addCustomizedSuggestion(selectedSuggestion, customizedHypothesis: selectedHypothesis)
        } else {
            DeliberatePracticeManager.manager.addCustomizedSuggestion(selectedSuggestion)
        }
    }
}
