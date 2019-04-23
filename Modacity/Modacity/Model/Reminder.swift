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
                    resultString = "\(resultString)\(self.onDays[idx] + 1), "
                }
                
                resultString = "\(resultString)\(self.onDays[self.onDays.count - 1] + 1) days"
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
    
    // from should include HOUR & MINUTE
    func calculateNextScheduleTime(time: Date, from: Date, started: Date) -> Date? {
        
        if self.everyMode == 0 {
            let weekDay = from.weekDay - 1
            if self.onWeeks.contains(weekDay) {
                if from.hourIn24Format * 60 + from.minute < time.hourIn24Format * 60 + time.minute {
                    return (from.toString(format: "yyyy-MM-dd") + " " + time.toString(format: "HH:mm")).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                }
            }
        } else {
            let day = from.day - 1
            if self.onDays.contains(day) {
                if from.hourIn24Format * 60 + from.minute < time.hourIn24Format * 60 + time.minute {
                    return (from.toString(format: "yyyy-MM-dd") + " " + time.toString(format: "HH:mm")).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                }
            }
        }
        
        var expireDate: Date!
        
        if endsMode == 1 {
            
            if endsUnit == 0 {
                expireDate = started.advanced(years: 0, months: 0, weeks: 0, days: endsNumber, hours: 0, minutes: 0, seconds: 0)
            } else if endsUnit == 1 {
                expireDate = started.advanced(years: 0, months: 0, weeks: endsNumber, days: 0, hours: 0, minutes: 0, seconds: 0)
            } else {
                expireDate = started.advanced(years: 0, months: endsNumber, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
            }
        }
        
        var date = from
        while (endsMode == 0 || (date.timeIntervalSince1970 < expireDate.timeIntervalSince1970)) {
            date = date.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
            if everyMode == 0 {
                if onWeeks.contains(date.weekDay - 1) {
                    return (date.toString(format: "yyyy-MM-dd") + " " + time.toString(format: "HH:mm")).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                }
            } else {
                if onDays.contains(date.day - 1) {
                    return (date.toString(format: "yyyy-MM-dd") + " " + time.toString(format: "HH:mm")).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                }
            }
        }
        
        return nil
    }
    
    func calculateSchedulingCount(from today:Date) -> Int {
        
        if endsMode == 0 {
            
            return -1
            
        } else {
            
            var expireDate: Date!
            if endsUnit == 0 {
                expireDate = today.advanced(years: 0, months: 0, weeks: 0, days: endsNumber, hours: 0, minutes: 0, seconds: 0)
            } else if endsUnit == 1 {
                expireDate = today.advanced(years: 0, months: 0, weeks: endsNumber, days: 0, hours: 0, minutes: 0, seconds: 0)
            } else {
                expireDate = today.advanced(years: 0, months: endsNumber, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
            }
            
            var dates = [Date]()
            
            var date = today.startOfDate()
            while (date.timeIntervalSince1970 < expireDate.timeIntervalSince1970) {
                if everyMode == 0 {
                    if onWeeks.contains(date.weekDay - 1) {
                        dates.append(date)
                    }
                } else {
                    if onDays.contains(date.day - 1) {
                        dates.append(date)
                    }
                }
                date = date.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
            }
            
            return dates.count
            
        }
    }
}

class Reminder: Mappable {
    
    static let reminderRepeatingModes = ["Does Not Repeat", "Daily", "Weekly on Friday", "Every Weekday(Monday to Friday)", "Custom"]
    
    var id: String!
    var practiceSessionId: String?
    var timeString: String!
    var repeatMode: Int?
    var custom: ReminderCustomRepeatData?
    var createdAt: TimeInterval?
    
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
        createdAt <- map["created_at"]
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
    
    func isExpired() -> Bool {
        if repeatMode == nil || repeatMode! == 0 {
            let time = timeString.date(format: "HH:mm")
            var created = Date()
            if let createdAt = createdAt {
                created = Date(timeIntervalSince1970: createdAt)
            }
            let now = Date()
            
            if now.toString(format: "yyyy-MM-dd") != created.toString(format: "yyyy-MM-dd") {
                return true
            } else {
                if now.hourIn24Format * 60 + now.minute > time!.hourIn24Format * 60 + time!.minute {
                    return true
                } else {
                    return false
                }
            }
        }
        
        if repeatMode != nil && repeatMode! == Reminder.reminderRepeatingModes.count - 1 {
            if let custom = self.custom {
                if custom.endsMode == 1 {
                    var created = Date()
                    if let createdAt = createdAt {
                        created = Date(timeIntervalSince1970: createdAt)
                    }
                    if custom.calculateNextScheduleTime(time: timeString.date(format: "HH:mm")!, from: Date(), started: created) == nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func nextScheduledTime() -> Date {
        if let repeatMode = self.repeatMode {
            let now = Date()
            let time = timeString.date(format: "HH:mm")
            if repeatMode == 0 {
                return (Date().toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
            } else if repeatMode == 1 {
                if now.hourIn24Format * 60 + now.minute < time!.hourIn24Format * 60 + time!.minute {
                    return (Date().toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                } else {
                    let tomorrow = Date().advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
                    return (tomorrow.toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? tomorrow
                }
            } else if repeatMode == 2 {
                if now.weekDay == 6 {
                    if now.hourIn24Format * 60 + now.minute < time!.hourIn24Format * 60 + time!.minute {
                        return (Date().toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                    }
                }
                
                var date = now
                var seeker = 0
                while (seeker < 7) {
                    date = date.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
                    if date.weekDay == 6 {
                        return (date.toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                    }
                    seeker = seeker + 1
                }
                
                return Date()
            } else if repeatMode == 3 {
                if now.weekDay >= 2 && now.weekDay <= 6  {
                    if now.hourIn24Format * 60 + now.minute < time!.hourIn24Format * 60 + time!.minute {
                        return (Date().toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                    }
                }
                
                var date = now
                var seeker = 0
                while (seeker < 7) {
                    date = date.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
                    if date.weekDay >= 2 && date.weekDay <= 6  {
                        return (date.toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
                    }
                    seeker = seeker + 1
                }
                
                return Date()
            } else {
                if let custom = self.custom {
                    return custom.calculateNextScheduleTime(time: time!, from: Date(), started: Date(timeIntervalSince1970: (createdAt ?? 0)) ) ?? Date()
                } else {
                    return Date()
                }
            }
        } else {
            return (Date().toString(format: "yyyy-MM-dd") + " " + timeString).date(format: "yyyy-MM-dd HH:mm") ?? Date()
        }
    }
}
