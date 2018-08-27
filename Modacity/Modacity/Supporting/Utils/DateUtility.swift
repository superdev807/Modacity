//
//  DateUtility.swift
//  
//
//  Created by Benjamin Chris on 2017/03/30.
//  Copyright © 2017 crossover. All rights reserved.
//

import UIKit

enum WeekDay: Int {
    case sun = 1, mon, tue, wed, thu, fri, sat
}

extension String {
    func date(format: String) -> Date? {
        DateFormatter.defaultFormatterBehavior = .behavior10_4
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self)
    }
}

extension Date {
    
    func weekDay(for weekday:WeekDay) -> Date {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .weekOfMonth, .weekday], from: self)
        components.weekday = weekday.rawValue
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    var year: Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    var month: Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    var weekDay: Int {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: self)
    }
    
    var day: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from:self)
    }
    
    var isToday: Bool {
        return toString(format: "yyyy-MM-dd") == Date().toString(format: "yyyy-MM-dd")
    }
    
    var isYesterday: Bool {
        return toString(format: "yyyy-MM-dd") == Date().ago(days: 1).toString(format: "yyyy-MM-dd")
    }
    
    var isTomorrow: Bool {
        return toString(format: "yyyy-MM-dd") == Date().advanced(days: 1).toString(format: "yyyy-MM-dd")
    }
    
    func toString(format: String, specifics: Bool = false) -> String {
        
        if specifics {
            if self.isToday {
                return "Today"
            } else if self.isYesterday {
                return "Yesterday"
            } else if self.isTomorrow {
                return "Tomorrow"
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func sundayOfWeek(after: Int) -> Date {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .weekOfMonth, .weekday], from: self)
        
        components.weekday = WeekDay.sun.rawValue
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    func advanced(years: Int? = 0, months:Int? = 0, weeks: Int? = 0, days: Int? = 0, hours:Int? = 0, minutes:Int? = 0, seconds:Int? = 0) -> Date {
        var components = DateComponents()
        components.year = years
        components.month = months
        components.weekOfYear = weeks
        components.day = days
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func ago(years: Int? = 0, months:Int? = 0, weeks: Int? = 0, days: Int? = 0, hours:Int? = 0, minutes:Int? = 0, seconds:Int? = 0) -> Date {
        var components = DateComponents()
        components.year = -(years ?? 0)
        components.month = -(months ?? 0)
        components.weekOfYear = -(weeks ?? 0)
        components.day = -(days ?? 0)
        components.hour = -(hours ?? 0)
        components.minute = -(minutes ?? 0)
        components.second = -(seconds ?? 0)
        
        return Calendar.current.date(byAdding: components, to: self) ?? self
    }
    
    func startOfDate() -> Date {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents([.year, .month, .weekOfMonth, .weekday], from: self)
        
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    func isThisWeek() -> Bool {
        let now = Date()
        if now.weekDay != 1 {
            return self.timeIntervalSince1970 >= now.weekDay(for: .mon).timeIntervalSince1970 && self.timeIntervalSince1970 < now.weekDay(for: .mon).timeIntervalSince1970 + 7 * 24 * 3600
        } else {
            return self.timeIntervalSince1970 >= now.weekDay(for: .mon).timeIntervalSince1970 - 7 * 24 * 3600 && self.timeIntervalSince1970 <= now.weekDay(for: .sun).timeIntervalSince1970
        }
    }
    
    func isLastWeek() -> Bool {
        return self.advanced(years: 0, months: 0, weeks: 1, days: 0, hours: 0, minutes: 0, seconds: 0).isThisWeek()
    }
    
    func isThisMonth() -> Bool {
        let now = Date()
        return now.toString(format: "yy-MM") == self.toString(format: "yy-MM")
    }
    
    func isLastMonth() -> Bool {
        let now = Date()
        return self.year * 12 + self.month == (now.year * 12 + now.month) - 1
    }
    
    func differenceInDays(with date: Date) -> Int {
        let startOfDate1 = (self.toString(format: "yyyy-MM-dd") + "00:00:00").date(format: "yyyy-MM-ddHH:mm:ss") ?? Date()
        let startOfDate2 = (date.toString(format: "yyyy-MM-dd") + "00:00:00").date(format: "yyyy-MM-ddHH:mm:ss") ?? Date()
        let diffInSec = (startOfDate2.timeIntervalSince1970 - startOfDate1.timeIntervalSince1970)
        
        return Int(((diffInSec >= 0 ? diffInSec : -(diffInSec)) / (3600 * 24)))
    }
    
}
