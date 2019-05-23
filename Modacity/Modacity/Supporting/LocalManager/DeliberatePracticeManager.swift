//
//  DeliberatePracticeManager.swift
//  Modacity
//
//  Created by Benjamin Chris on 13/11/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class DeliberatePracticeManager: NSObject {
    
    static let manager = DeliberatePracticeManager()
    
    func suggestionsList() -> [DeliberatePracticeSuggestion] {
        var fromPlist = self.loadSuggestionsFromPlist()
        let fromCustom = self.loadSuggestionsFromCustom()
        let defaultHypos = self.loadDefaultHypos()
        
        for suggestionId in fromCustom.keys {
            if let suggestion = fromPlist[suggestionId] {
                if let customHypos = fromCustom[suggestionId]?.hypos {
                    suggestion.hypos.append(contentsOf: customHypos)
                    fromPlist[suggestionId] = suggestion
                }
            } else {
                let suggestion = fromCustom[suggestionId]!
                suggestion.hypos.append(contentsOf: defaultHypos)
                fromPlist[suggestionId] = suggestion
            }
        }
        
        var resultArray = [DeliberatePracticeSuggestion]()
        for key in fromPlist.keys {
            resultArray.append(fromPlist[key]!)
        }
        
        return resultArray.sorted(by: { (suggestion1, suggestion2) -> Bool in
            if suggestion1.id.count < 4 && suggestion2.id.count > 4 {
                return true
            } else if suggestion1.id.count > 4 && suggestion2.id.count > 4 {
                return suggestion1.createdAt < suggestion2.createdAt
            } else if suggestion1.id.count > 4 && suggestion2.id.count < 4 {
                return false
            } else {
                return suggestion1.id < suggestion2.id
            }
        })
    }
    
    func isExistingSuggestion(_ suggestionName: String) -> DeliberatePracticeSuggestion? {
        let suggestions = self.suggestionsList()
        for suggestion in suggestions {
            if suggestionName.lowercased() == suggestion.suggestion.lowercased() {
                return suggestion
            }
        }
        return nil
    }
    
    func storeCustomDeliberate(isNewSuggestion: Bool,
                               newSuggestionName: String?,
                               suggestionId: String?,
                               isNewHypo: Bool,
                               newHypoName: String?) {
        
        if !isNewSuggestion && !isNewHypo {
            return
        }
        
        var suggestions = loadSuggestionsFromCustom()
        var newSuggestion: DeliberatePracticeSuggestion?
        
        var isUpdating = false
        
        if isNewSuggestion {
            let newSuggestionId = UUID().uuidString
            newSuggestion = DeliberatePracticeSuggestion()
            newSuggestion!.id = newSuggestionId
            newSuggestion!.suggestion = newSuggestionName!
            newSuggestion!.createdAt = Date().timeIntervalSince1970
            isUpdating = false
        } else {
            if suggestions[suggestionId!] != nil {
                newSuggestion = suggestions[suggestionId!]
                isUpdating = true
            } else {
                newSuggestion = DeliberatePracticeSuggestion()
                newSuggestion!.id = suggestionId!
                isUpdating = false
            }
        }
        
        if isNewHypo && newHypoName != nil {
            newSuggestion!.hypos.append(newHypoName!)
        }
        
        suggestions[newSuggestion!.id] = newSuggestion!
        
        self.storeCustomSuggestions(suggestions)
        DeliberatePracticeRemoteManager.manager.storeNewSuggestion(newSuggestion!, updating: isUpdating)
    }
    
    func storeCustomSuggestions(_ suggestions: [String:DeliberatePracticeSuggestion]) {
        var data = [String:Any]()
        for id in suggestions.keys {
            if let suggestion = suggestions[id] {
                data[id] = suggestion.toJSON()
            }
        }
        UserDefaults.standard.set(data, forKey: "custom_deliberates")
    }
    
    func cleanDeliberatePracticeManager() {
        UserDefaults.standard.removeObject(forKey: "custom_deliberates")
        UserDefaults.standard.removeObject(forKey: "customized_suggestions")
        UserDefaults.standard.synchronize()
    }
    
    func deleteSuggestion(_ suggestion: DeliberatePracticeSuggestion) {
        var suggestions = self.loadSuggestionsFromCustom()
        suggestions.removeValue(forKey: suggestion.id)
        self.storeCustomSuggestions(suggestions)
        
        DeliberatePracticeRemoteManager.manager.deleteSuggestion(suggestion)
    }
    
    func deleteHypothesis(on suggestion: DeliberatePracticeSuggestion, hypothesis: String) {
        var suggestions = self.loadSuggestionsFromCustom()
        if let customSuggestion = suggestions[suggestion.id] {
            for idx in 0..<customSuggestion.hypos.count {
                if customSuggestion.hypos[idx] == hypothesis {
                    customSuggestion.hypos.remove(at: idx)
                    break
                }
            }
            suggestions[suggestion.id] = customSuggestion
            self.storeCustomSuggestions(suggestions)
            DeliberatePracticeRemoteManager.manager.updateHypothesis(on: suggestion, newHypos:customSuggestion.hypos)
        }
    }
    
    func loadSuggestionsFromPlist() -> [String: DeliberatePracticeSuggestion] {
        var suggestions = [String:DeliberatePracticeSuggestion]()
        if let plistURL = Bundle.main.url(forResource: "deliberate_suggestions", withExtension: "plist") {
            if let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] {
                if let list = plist["suggestions"] as? [[String:Any]] {
                    for data in list {
                        if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
                            suggestions[suggestion.id] = suggestion
                        }
                    }
                }
            }
        }
        
        return suggestions
    }
    
    private func loadSuggestionsFromCustom() -> [String: DeliberatePracticeSuggestion] {
        if let data = UserDefaults.standard.object(forKey: "custom_deliberates") as? [String:Any] {
            var suggestions = [String:DeliberatePracticeSuggestion]()
            for key in data.keys {
                if let suggestionJSON = data[key] as? [String:Any] {
                    if let suggestion = DeliberatePracticeSuggestion(JSON: suggestionJSON) {
                        suggestions[key] = suggestion
                    }
                }
            }
            return suggestions
        } else {
            return [String:DeliberatePracticeSuggestion]()
        }
    }
    
    func loadDefaultHypos() -> [String] {
        var defaultSuggestions = [String]()
        if let plistURL = Bundle.main.url(forResource: "deliberate_suggestions", withExtension: "plist") {
            if let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] {
                if let array = plist["default_suggestions"] as? [String] {
                    defaultSuggestions = array
                }
            }
        }
        
        return defaultSuggestions
    }
    
    func signout() {
        self.cleanDeliberatePracticeManager()
    }
    
}
