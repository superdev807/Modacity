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
}
