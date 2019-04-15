//
//  Reminder.swift
//  Modacity
//
//  Created by Software Engineer on 4/11/19.
//  Copyright © 2019 Modacity, Inc. All rights reserved.
//

import UIKit
import ObjectMapper

class ReminderCustomRepeatData: Mappable {
    
    let weekDayStrings = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thirsday", "Friday", "Saturday"]
    
    var everyMode = 0
    var onWeeks = [Int]()
    var onDays = [Int]()
    var endsMode = 0
    var endsNumber = 1
    var endsUnit = 0
    
    init() {}
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        everyMode <- map["every_mode"]
        onWeeks <- map["on_weeks"]
        onDays <- map["on_days"]
        endsMode <- map["ends"]
        endsNumber <- map["ends_number"]
        endsUnit <- map["ends_unit"]
    }
    
    func customRepeatDescription() -> String {
        var resultString = ""
        if self.everyMode == 0 {
            self.onWeeks.sort()
            if self.onWeeks.count == 0 {
            } else if self.onWeeks.count == 1 {
                resultString = "Every \(self.weekDayStrings[self.onWeeks[0]])"
            } else if self.onWeeks.count == 2 {
                resultString = "Every \(self.weekDayStrings[self.onWeeks[0]]) and \(self.weekDayStrings[self.onWeeks[1]])"
            } else {
                resultString = "Every "
                for idx in 0..<(self.onWeeks.count - 1) {
                    resultString = resultString + self.weekDayStrings[self.onWeeks[idx]]
                    if idx < self.onWeeks.count - 2 {
                        resultString = resultString + ", "
                    }
                }
                
                resultString = resultString + " and " + self.weekDayStrings[self.onWeeks[self.onWeeks.count - 1]]
            }
        } else {
            self.onDays.sort()
            if self.onDays.count == 0 {
            } else {
                resultString = "Every month "
                for idx in 0..<(self.onDays.count - 1) {
                    resultString = "\(resultString)\(self.onDays[idx]), "
                }
                
                resultString = "\(resultString)\(self.onDays[self.onDays.count - 1]) days"
            }
        }
        
        if self.endsMode == 1 {
            if resultString.isEmpty {
                resultString = " Ends after " + "\(self.endsNumber) \(["day", "week", "month"][self.endsUnit])\(self.endsNumber > 1 ? "s" : "")"
            } else {
                resultString = resultString + ", Ends after " + "\(self.endsNumber) \(["day", "week", "month"][self.endsUnit])\(self.endsNumber > 1 ? "s" : "")"
            }
        }
        
        return resultString
    }
}

class Reminder: Mappable {
    
    static let reminderRepeatingModes = ["Does Not Repeat", "Daily", "Weekly on Friday", "Monthly on Frday", "Every Weekday(Monday to Friday)", "Custom"]
    
    
    var id: String!
    var practiceSessionId: String?
    var timeString: String!
    var repeatMode: Int?
    var custom: ReminderCustomRepeatData?
    
    init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        practiceSessionId <- map["practice_session_id"]
        timeString <- map["time_string"]
        repeatMode <- map["repeat_mode"]
        custom <- map["repeat_custom"]
    }
    
    func repeatDescription() -> String {
        if timeString == nil {
            return ""
        }
        let time = timeString.date(format: "HH:mm")!
        let timeFormattedString = time.toString(format: "h:mm a").uppercased()
        if let repeatMode = repeatMode {
            switch repeatMode {
            case 0:
                return "Today at \(timeFormattedString)"
            case 1:
                return "Every day at \(timeFormattedString)"
            case 2:
                return "Every Friday at \(timeFormattedString)"
            case 3:
                return "On First Friday at \(timeFormattedString)"
            case 4:
                return "Every Weekday (Monday to Friday) at \(timeFormattedString)"
            default:
                return "Custom Repeat"
            }
        } else {
            return timeFormattedString
        }
    }
    
    func practiceSessionDescription() -> String {
        if let practiceSessionId = self.practiceSessionId {
            if let practiceSession = PlaylistLocalManager.manager.loadPlaylist(forId: practiceSessionId) {
                return practiceSession.name
            } else {
                return "None"
            }
        } else {
            return "None"
        }
    }
}
