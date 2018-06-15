//
//  SetReminderViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import UserNotifications

class SetReminderViewController: UIViewController {
    
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var buttonRemindMe: UIButton!
    @IBOutlet weak var labelTimeAndDate: UILabel!
    @IBOutlet weak var buttonPlaylistNamePanel: UIButton!
    
    var playlistParentViewModel: PlaylistContentsViewModel!
    var selectedDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.datePicker.setValue(Color.white, forKey: "textColor")
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        self.datePicker.minimumDate = Date()
        self.labelPlaylistName.text = self.playlistParentViewModel.playlist.name
        self.buttonRemindMe.isEnabled = false
        self.buttonRemindMe.alpha = 0.7
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Reminder Screen Back Button")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onRemindMe(_ sender: Any) {
        setReminder()
    }
    
    @IBAction func onPlaylistNameSelect(_ sender: Any) {
        (sender as! UIButton).backgroundColor = Color.clear
    }
    
    @IBAction func onTouchDownOnPlaylistName(_ sender: Any) {
        (sender as! UIButton).backgroundColor = Color.white.alpha(0.2)
    }
    
    @IBAction func onTouchUpOutsideOnPlaylistName(_ sender: Any) {
        (sender as! UIButton).backgroundColor = Color.clear
    }
    
    @IBAction func onTimeAndDateValueChanged(_ sender: Any) {
        if Date().timeIntervalSince1970 < self.datePicker.date.timeIntervalSince1970 {
            self.labelTimeAndDate.text = self.timeAndDateString()
            self.buttonRemindMe.isEnabled = true
            self.buttonRemindMe.alpha = 1.0
        }
    }
    
    func timeAndDateString() -> String {
        self.selectedDate = self.datePicker.date
        let date = self.datePicker.date
        if date.isToday {
            return "Today " + date.toString(format: "h:mm a")
        } else if date.isTomorrow {
            return "Tomorrow " + date.toString(format: "h:mm a")
        } else {
            if date.year == Date().year {
                return date.toString(format: "MMM d h:mm a")
            } else {
                return date.toString(format: "MMM d, yyyy h:mm a")
            }
        }
    }
    
    func setReminder() {
        
        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = "NOTIFICATION_CATEGORY"
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
        }
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Modacity playlist \(self.labelPlaylistName.text ?? "")"
            content.body = "Time to practice \(self.labelPlaylistName.text ?? "") in Modacity."
            content.categoryIdentifier = "alarm"
            content.sound = UNNotificationSound.default()
            content.userInfo = self.playlistParentViewModel.playlist.toJSON()
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self.selectedDate), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            
        } else {
            
            // ios 9
            let notification = UILocalNotification()
            notification.fireDate = self.selectedDate
            notification.alertBody = "Modacity playlist \(self.labelPlaylistName.text ?? "")"
            notification.alertAction = "Time to practice \(self.labelPlaylistName.text ?? "") in Modacity."
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = self.playlistParentViewModel.playlist.toJSON()
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
        ModacityAnalytics.LogStringEvent("Reminder Set", extraParamName: "when", extraParamValue: self.labelTimeAndDate.text)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
