//
//  RemindersManager.swift
//  Modacity
//
//  Created by Software Engineer on 4/12/19.
//  Copyright © 2019 Modacity, Inc. All rights reserved.
//

import UIKit
import UserNotifications

class RemindersManager {
    
    static let manager = RemindersManager()
    
    func loadReminders() -> [Reminder]? {
        if let remindersData = UserDefaults.standard.object(forKey: "reminders") as? [String:[String:Any]] {
            var reminders = [Reminder]()
            for reminderId in remindersData.keys {
                if let reminder = Reminder(JSON: remindersData[reminderId]!) {
                    reminders.append(reminder)
                }
            }
            return reminders
        } else {
            return nil
        }
    }
    
    func storeReminders(_ reminders: [String:[String:Any]]) {
        UserDefaults.standard.set(reminders, forKey: "reminders")
    }
    
    func generateFullReminderNotificaitons() {
        if let reminders = self.loadReminders() {
            for reminder in reminders {
                self.generateLocalNotification(for: reminder)
            }
        }
    }
    
    func reminder(forId: String) -> Reminder? {
        if let remindersData = UserDefaults.standard.object(forKey: "reminders") as? [String:[String:Any]] {
            if let data = remindersData[forId] {
                return Reminder(JSON: data)
            }
        }
        
        return nil
    }
    
    func saveReminder(_ reminder: Reminder) {
        if var remindersData = UserDefaults.standard.object(forKey: "reminders") as? [String:[String:Any]] {
            remindersData[reminder.id] = reminder.toJSON()
            UserDefaults.standard.set(remindersData, forKey: "reminders")
        } else {
            UserDefaults.standard.set([reminder.id: reminder.toJSON()], forKey: "reminders")
        }
        
        self.generateLocalNotification(for: reminder)
        
        RemindersRemoteManager.manager.updateReminder(reminder)
    }
    
    func removeReminder(id: String) {
        if var remindersData = UserDefaults.standard.object(forKey: "reminders") as? [String:[String:Any]] {
            remindersData.removeValue(forKey: id)
            UserDefaults.standard.set(remindersData, forKey: "reminders")
        }
        
        if let notificationIds = UserDefaults.standard.object(forKey: "reminder notifications for \(id)") as? [String] {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIds)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: notificationIds)
        }
        
        RemindersRemoteManager.manager.removeReminder(id:id)
    }
    
    func cleanReminders() {
        
        let center = UNUserNotificationCenter.current()
        if let remindersData = UserDefaults.standard.object(forKey: "reminders") as? [String:[String:Any]] {
            for reminderId in remindersData.keys {
                if let notificationIds = UserDefaults.standard.object(forKey: "reminder notifications for \(reminderId)") as? [String] {
                    center.removePendingNotificationRequests(withIdentifiers: notificationIds)
                    center.removeDeliveredNotifications(withIdentifiers: notificationIds)
                }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "reminders")
    }
    
    func generateLocalNotification(for reminder: Reminder) {
        
        let center = UNUserNotificationCenter.current()
        
        if let notificationIds = UserDefaults.standard.object(forKey: "reminder notifications for \(reminder.id ?? "")") as? [String] {
            center.removePendingNotificationRequests(withIdentifiers: notificationIds)
            center.removeDeliveredNotifications(withIdentifiers: notificationIds)
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Modacity Practice Reminder"
        if let practiceSessionId = reminder.practiceSessionId {
            if let practiceSession = PlaylistLocalManager.manager.loadPlaylist(forId: practiceSessionId) {
                content.body = "It's time to practice '\(practiceSession.name ?? "")'"
            }
        }
        
        if let repeatMode = reminder.repeatMode {
            
            var notificationIds = [String]()
            
            var date = DateComponents()
            
            if let time = reminder.timeString.date(format: "HH:mm") {
                date.hour = Int(time.toString(format: "HH"))
                date.minute = Int(time.toString(format: "mm"))
                date.second = 0
            }
            
            var requests = [UNNotificationRequest]()
            
            switch (repeatMode) {
            case 0:
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
                requests.append(request)
                notificationIds = [reminder.id]
            case 1:
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
                requests.append(request)
                notificationIds = [reminder.id]
            case 2:
                date.weekday = 6
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
                requests.append(request)
                notificationIds = [reminder.id]
            case 3:
                date.weekday = 6
                date.weekOfMonth = 0
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)
                requests.append(request)
                notificationIds = [reminder.id]
            case 4:
                for wk in 2...6 {
                    date.weekday = wk
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                    let notificationId = "\(reminder.id ?? "")-\(wk)"
                    let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                    requests.append(request)
                    notificationIds.append(notificationId)
                }
            default:
                if let custom = reminder.custom {
                    if custom.endsMode == 0 {
                        if custom.everyMode == 0 {
                            for wk in custom.onWeeks {
                                date.weekday = wk + 1
                                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                                let notificationId = "\(reminder.id ?? "")-\(wk)"
                                let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                                requests.append(request)
                                notificationIds.append(notificationId)
                            }
                        } else {
                            for dm in custom.onDays {
                                date.day = dm + 1
                                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                                let notificationId = "\(reminder.id ?? "")-\(dm)"
                                let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                                requests.append(request)
                                notificationIds.append(notificationId)
                            }
                        }
                    } else {
                        
                        let today = Date()
                        var expireDate: Date!
                        if custom.endsUnit == 0 {
                            expireDate = today.advanced(years: 0, months: 0, weeks: 0, days: custom.endsNumber, hours: 0, minutes: 0, seconds: 0)
                        } else if custom.endsUnit == 1 {
                            expireDate = today.advanced(years: 0, months: 0, weeks: custom.endsNumber, days: 0, hours: 0, minutes: 0, seconds: 0)
                        } else {
                            expireDate = today.advanced(years: 0, months: custom.endsNumber, weeks: 0, days: 0, hours: 0, minutes: 0, seconds: 0)
                        }
                        
                        var dates = [Date]()
                        
                        var date = today.startOfDate()
                        while (date.timeIntervalSince1970 < expireDate.timeIntervalSince1970) {
                            if custom.everyMode == 0 {
                                if custom.onWeeks.contains(date.weekDay - 1) {
                                    dates.append(date)
                                }
                            } else {
                                if custom.onDays.contains(date.day) {
                                    dates.append(date)
                                }
                            }
                            date = date.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
                        }
                        
                        ModacityDebugger.debug("Notification in \(dates.count) dates")
                        var idx = 0
                        for date in dates {
                            var dateCmp = DateComponents()
                            dateCmp.year = date.year
                            dateCmp.month = date.month
                            dateCmp.day = date.day
                            if let time = reminder.timeString.date(format: "HH:mm") {
                                dateCmp.hour = Int(time.toString(format: "HH"))
                                dateCmp.minute = Int(time.toString(format: "mm"))
                            }
                            dateCmp.second = 0
                            
                            ModacityDebugger.debug("\(dateCmp.month!) - \(dateCmp.day!), \(dateCmp.hour!):\(dateCmp.minute!)")
                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCmp, repeats: false)
                            let notificationId = "\(reminder.id ?? "")-\(idx)"
                            let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
                            requests.append(request)
                            notificationIds.append(notificationId)
                            idx = idx + 1
                        }
                    }
                }
            }
            
            ModacityDebugger.debug("notification ids \(notificationIds)")
            
            for request in requests {
                center.add(request) { (err) in
                    if let err = err {
                        ModacityDebugger.debug("Error in Notification request adding: \(err.localizedDescription)")
                    }
                }
            }
            
            UserDefaults.standard.set(notificationIds, forKey: "reminder notifications for \(reminder.id ?? "")")
        }
    }
}
