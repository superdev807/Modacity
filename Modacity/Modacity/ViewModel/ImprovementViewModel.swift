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
    
    var suggestionsList = [DeliberatePracticeSuggestion](){
        didSet {
            if let callback = self.callBacks["suggestions_list"] {
                if oldValue.count > suggestionsList.count {
                    callback(.deleted, oldValue, suggestionsList)
                } else if oldValue.count < suggestionsList.count {
                    callback(.inserted, oldValue, suggestionsList)
                } else {
                    callback(.simpleChange, oldValue, suggestionsList)
                }
            }
        }
    }
    
    var alreadyTried = false {
        didSet {
            if let callback = self.callBacks["alreadyTried"] {
                callback(.simpleChange, oldValue, alreadyTried)
            }
        }
    }
    
    func loadSuggestions() {
        self.suggestionsList = DeliberatePracticeManager.manager.suggestionsList()
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
    
    func suggestionIsDefault(_ suggestion: DeliberatePracticeSuggestion) -> Bool {
        return suggestion.id.count < 4
    }
    
    func hypothesisIsDefault(_ hypothesis: String) -> Bool {
        if let data = self.selectedSuggestionData {
            if data.id.count < 4 {
                if let suggestionsDefaultData = DeliberatePracticeManager.manager.loadSuggestionsFromPlist()[data.id] {
                    return suggestionsDefaultData.hypos.contains(hypothesis)
                } else {
                    return false
                }
            } else {
                return DeliberatePracticeManager.manager.loadDefaultHypos().contains(hypothesis)
            }
        } else {
            return DeliberatePracticeManager.manager.loadDefaultHypos().contains(hypothesis)
        }
    }
    
    func deleteSuggestion(_ suggestion: DeliberatePracticeSuggestion, at row: Int) {
        
        DeliberatePracticeManager.manager.deleteSuggestion(suggestion)
        self.suggestionsList.remove(at: row)
        
    }
    
    func deleteHypothesis(_ hypothesis: String, at row: Int) {
        if let suggestion = self.selectedSuggestionData {
            DeliberatePracticeManager.manager.deleteHypothesis(on:suggestion, hypothesis: hypothesis)
            suggestion.hypos.remove(at: row)
            self.selectedSuggestionData!.hypos = suggestion.hypos
        }
    }
    
}
