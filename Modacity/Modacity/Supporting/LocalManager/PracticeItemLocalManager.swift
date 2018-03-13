//
//  PracticeItemLocalManager.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/1/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import ObjectMapper

class PracticeItemLocalManager {
    
    static let manager = PracticeItemLocalManager()
    
    func loadAllPracticeItemNames() -> [String]? {
        if let practiceItemNamesJSONString = UserDefaults.standard.string(forKey: "practice_item_names") {
            return practiceItemNamesJSONString.toJSON() as? [String]
        }
        return nil
    }
    
    func addNewPracticeItem(with name:String) {
        var practiceItemNames = loadAllPracticeItemNames()
        if practiceItemNames == nil {
            practiceItemNames = [String]()
        }
        practiceItemNames!.append(name)
        
        self.replacePracticeItemNames(newValue: practiceItemNames!)
    }
    
    func replacePracticeItemNames(newValue: [String]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newValue, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                UserDefaults.standard.set(JSONString, forKey: "practice_item_names")
                UserDefaults.standard.synchronize()
            }
        } catch {
        }
    }
    
    func isFavoritePracticeItem(for item:String) -> Bool {
        return UserDefaults.standard.bool(forKey: "favorite_\(item)")
    }
    
    func setFavoritePracticeItem(for item:String) {
        let isFavorite = UserDefaults.standard.bool(forKey: "favorite_\(item)")
        if isFavorite {
            UserDefaults.standard.removeObject(forKey: "favorite_\(item)")
        } else {
            UserDefaults.standard.set(true, forKey: "favorite_\(item)")
        }
        UserDefaults.standard.synchronize()
    }
    
    func ratingValue(forPracticeItem: String) -> Double? {
        if UserDefaults.standard.object(forKey:"rating-" + forPracticeItem) == nil {
            return nil
        } else {
            return UserDefaults.standard.double(forKey:"rating-" + forPracticeItem)
        }
    }
    
    func setRatingValue(forPracticeItem: String, rating: Double) {
        UserDefaults.standard.set(rating, forKey: "rating-" + forPracticeItem)
        UserDefaults.standard.synchronize()
    }
}
