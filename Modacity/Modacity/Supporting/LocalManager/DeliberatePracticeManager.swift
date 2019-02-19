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
    
    private func loadSuggestionsFromPlist() -> [String: DeliberatePracticeSuggestion] {
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
    

//    var suggestions: [String:DeliberatePracticeSuggestion]? = nil
//    var defaultHypos: [String]? = nil
//
//    func readSuggestionsFromPlist() {
//
//        var suggestions = [String:DeliberatePracticeSuggestion]()
//        var defaultSuggestions = [String]()
//        if let plistURL = Bundle.main.url(forResource: "deliberate_suggestions", withExtension: "plist") {
//            if let plist = NSDictionary(contentsOf: plistURL) as? [String:Any] {
//                if let list = plist["suggestions"] as? [[String:Any]] {
//                    for data in list {
//                        if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
//                            suggestions[suggestion.suggestion.lowercased()] = suggestion
//                        }
//                    }
//                }
//
//                if let array = plist["default_suggestions"] as? [String] {
//                    suggestions = array
//                }
//            }
//        }
//
//        self.suggestions = suggestions
//        self.defaultHypos = defaultSuggestions
//    }
//
//
//
////    func loadCustomizedSuggestions() -> [String:DeliberatePracticeSuggestion] {
////        var customizedSuggestions = [String:DeliberatePracticeSuggestion]()
////        if let data = UserDefaults.standard.object(forKey: "custom_deliberates") as? [String: Any] {
////            for key in data.keys {
////
////            }
////        }
////        if let array = UserDefaults.standard.object(forKey: "customized_suggestions") as? [String:[String:Any]] {
////            for key in array.keys {
////                if let data = array[key] {
////                    if let suggestion = DeliberatePracticeSuggestion(JSON: data) {
////                        customizedSuggestions[suggestion.suggestion.lowercased()] = suggestion
////                    }
////                }
////            }
////        }
////        return customizedSuggestions
////    }
//
//    func storeCustomDeliberates(_ data: [String:DeliberatePracticeSuggestion]) {
//        UserDefaults.standard.set(data, forKey:"custom_deliberates")
//        UserDefaults.standard.synchronize()
//    }
//
//    func storeCustomizedSuggestions(_ suggestions: [String:DeliberatePracticeSuggestion]) {
//        var array = [String:[String:Any]]()
//        for key in suggestions.keys {
//            array[key] = suggestions[key]?.toJSON()
//        }
//        UserDefaults.standard.set(array, forKey:"customized_suggestions")
//        UserDefaults.standard.synchronize()
//    }
//
//    func addCustomizedSuggestion(_ suggestion: String, customizedHypothesis: String? = nil) {
//        let data = DeliberatePracticeSuggestion()
//        data.suggestion = suggestion
//        data.isStandard = false
//        data.hypos = [String]()
//        if let hypo = customizedHypothesis {
//            data.hypos.append(hypo)
//        }
//
//        var suggestions = self.loadCustomizedSuggestions()
//        suggestions[suggestion.lowercased()] = data
//        storeCustomizedSuggestions(suggestions)
//
//        DeliberatePracticeRemoteManager.manager.addDeliberatePractice(data)
//    }
//
//    func suggestionsList() -> [String] {
//        if self.suggestions == nil {
//            self.readSuggestionsFromPlist()
//        }
//
//        var array = [String]()
//        for key in self.suggestions!.keys {
//            array.append(self.suggestions![key]!.suggestion)
//        }
//
//        var customSuggestionsArray = [DeliberatePracticeSuggestion]()
//        if let data = UserDefaults.standard.object(forKey: "custom_deliberates") as? [String: Any] {
//            for key in data.keys {
//                if key.count > 4 {
//                    if let suggestionData = data[key] as? [String:Any] {
//                        if let suggestion = DeliberatePracticeSuggestion(JSON: suggestionData) {
//                            customSuggestionsArray.append(suggestion)
//                        }
//                    }
//                }
//            }
//        }
//
//        customSuggestionsArray.sort { (sugg1, sugg2) -> Bool in
//            return sugg1.createdAt < sugg2.createdAt
//        }
//
//        for suggestion in customSuggestionsArray {
//            array.append(suggestion.suggestion)
//        }
//
//        return array
//    }
//
//    func hypothesisList(for suggestionId:String)->[String] {
//        if self.suggestions == nil {
//            self.readSuggestionsFromPlist()
//        }
//
//        if let suggestions = self.suggestions {
//
////            if let suggestion = suggestions[suggestion.lowercased()] {
////                return suggestion.hypos
////            } else {
////                if let suggestion = self.loadCustomizedSuggestions()[suggestion.lowercased()] {
////                    var defaultHypos = self.defaultHypos!
////                    defaultHypos.append(contentsOf: suggestion.hypos)
////                    return defaultHypos
////                } else {
////                    return self.defaultHypos!
////                }
////            }
//        } else {
//            return []
//        }
//    }
//
//    func cleanDeliberatePracticeManager() {
//        UserDefaults.standard.removeObject(forKey: "custom_deliberates")
//        UserDefaults.standard.removeObject(forKey: "customized_suggestions")
//        UserDefaults.standard.synchronize()
//    }
//
//    func signout() {
//        UserDefaults.standard.removeObject(forKey: "custom_deliberates")
//        UserDefaults.standard.removeObject(forKey: "customized_suggestions")
//        UserDefaults.standard.synchronize()
//    }
}
