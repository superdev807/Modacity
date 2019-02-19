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
    
    var isNewHypo = false
    
    var selectedSuggestionData: DeliberatePracticeSuggestion?
    
    var userOwnSuggestions = [String]()
    
    var suggestionsList: [DeliberatePracticeSuggestion] {
        get {
            return DeliberatePracticeManager.manager.suggestionsList()
        }
    }
    
    var alreadyTried = false {
        didSet {
            if let callback = self.callBacks["alreadyTried"] {
                callback(.simpleChange, oldValue, alreadyTried)
            }
        }
    }
    
    func hypothesisList()->[String] {
        if let suggestion = selectedSuggestionData {
            return suggestion.hypos
        } else {
            return DeliberatePracticeManager.manager.loadDefaultHypos()
        }
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
        
        DeliberatePracticeManager.manager.storeCustomDeliberate(isNewSuggestion: (self.selectedSuggestionData == nil),
                                                                newSuggestionName: self.selectedSuggestion,
                                                                suggestionId: (self.selectedSuggestionData == nil) ? nil : self.selectedSuggestionData!.id,
                                                                isNewHypo: isNewHypo,
                                                                newHypoName: self.selectedHypothesis)
        
    }
    
//        let suggestions = DeliberatePracticeManager.manager.suggestionsList()
//        for suggestion in suggestions {
//            if selectedSuggestion.lowercased() == suggestion.lowercased() {
//                return
//            }
//        }
//
//        let customizedSuggestion = DeliberatePracticeSuggestion()
//        customizedSuggestion.isStandard = false
//        customizedSuggestion.suggestion = selectedSuggestion
//        customizedSuggestion.hypos = []
//
//        var alreadyIncluded = false
//
//        if let hypos = DeliberatePracticeManager.manager.defaultHypos {
//            for hypo in hypos {
//                if hypo.lowercased() == selectedHypothesis.lowercased() {
//                    alreadyIncluded = true
//                    break
//                }
//            }
//        }
//
//        if !alreadyIncluded {
//            DeliberatePracticeManager.manager.addCustomizedSuggestion(selectedSuggestion, customizedHypothesis: selectedHypothesis)
//        } else {
//            DeliberatePracticeManager.manager.addCustomizedSuggestion(selectedSuggestion)
//        }
//    }
}
