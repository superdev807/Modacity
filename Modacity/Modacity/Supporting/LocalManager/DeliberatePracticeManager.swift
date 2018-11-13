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
    
    var suggestions: [String:DeliberatePracticeSuggestion]? = nil
    var defaultHypos: [String]? = nil
    
    func readSuggestionsFromPlist() {
        
        var suggestions = [String:DeliberatePracticeSuggestion]()
        var defaultSuggestions = [String]()
        if let plistURL = Bundle.main.url(forResource: "deliberate_suggestions", withExtension: "plist") {
            if let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] {
                if let list = plist["suggestions"] as? [[String:Any]] {
                    for data in list {
                        if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
                            suggestions[suggestion.suggestion.lowercased()] = suggestion
                        }
                    }
                }
                
                if let array = plist["default_suggestions"] as? [String] {
                    defaultSuggestions = array
                }
            }
        }
        
        self.suggestions = suggestions
        self.defaultHypos = defaultSuggestions
    }
    
    func loadCustomizedSuggestions() -> [String:DeliberatePracticeSuggestion] {
        var customizedSuggestions = [String:DeliberatePracticeSuggestion]()
        if let array = UserDefaults.standard.object(forKey: "customized_suggestions") as? [String:[String:Any]] {
            for key in array.keys {
                if let data = array[key] {
                    if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
                        customizedSuggestions[suggestion.suggestion.lowercased()] = suggestion
                    }
                }
            }
        }
        return customizedSuggestions
    }
    
    func storeCustomizedSuggestions(_ suggestions: [String:DeliberatePracticeSuggestion]) {
        var array = [String:[String:Any]]()
        for key in suggestions.keys {
            array[key] = suggestions[key]?.toJSON()
        }
        UserDefaults.standard.set(array, forKey:"customized_suggestions")
        UserDefaults.standard.synchronize()
    }
    
    func addCustomizedSuggestion(_ suggestion: String, customizedHypothesis: String? = nil) {
        let data = DeliberatePracticeSuggestion()
        data.suggestion = suggestion
        data.isStandard = false
        data.hypos = [String]()
        if let hypo = customizedHypothesis {
            data.hypos.append(hypo)
        }
        
        var suggestions = self.loadCustomizedSuggestions()
        suggestions[suggestion.lowercased()] = data
        storeCustomizedSuggestions(suggestions)
        
        DeliberatePracticeRemoteManager.manager.addDeliberatePractice(data)
    }
    
    func suggestionsList() -> [String] {
        if self.suggestions == nil {
            self.readSuggestionsFromPlist()
        }
        
        var array = [String]()
        for key in self.suggestions!.keys {
            array.append(self.suggestions![key]!.suggestion)
        }
        
        let customizedSuggestions = self.loadCustomizedSuggestions()
        for suggestion in customizedSuggestions.keys {
            array.append(customizedSuggestions[suggestion]!.suggestion)
        }
        
        return array
    }
    
    func hypothesisList(for suggestion:String)->[String] {
        if self.suggestions == nil {
            self.readSuggestionsFromPlist()
        }
        
        if let suggestions = self.suggestions {
            if let suggestion = suggestions[suggestion.lowercased()] {
                return suggestion.hypos
            } else {
                if let suggestion = self.loadCustomizedSuggestions()[suggestion.lowercased()] {
                    var defaultHypos = self.defaultHypos!
                    defaultHypos.append(contentsOf: suggestion.hypos)
                    return defaultHypos
                } else {
                    return self.defaultHypos!
                }
            }
        } else {
            return []
        }
    }
    
    func cleanDeliberatePracticeManager() {
        UserDefaults.standard.removeObject(forKey: "customized_suggestions")
        UserDefaults.standard.synchronize()
    }
    
    func signout() {
        UserDefaults.standard.removeObject(forKey: "customized_suggestions")
        UserDefaults.standard.synchronize()
    }
}
