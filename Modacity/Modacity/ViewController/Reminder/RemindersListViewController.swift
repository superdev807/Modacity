//
//  RemindersListViewController.swift
//  Modacity
//
//  Created by Software Engineer on 4/11/19.
//  Copyright © 2019 Modacity, Inc. All rights reserved.
//

import UIKit

class RemindersListViewController: UIViewController {

    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewReminders: UITableView!
    @IBOutlet weak var buttonAddNew: UIButton!
    @IBOutlet weak var labelNoReminders: UILabel!
    @IBOutlet weak var imageViewTopLeft: UIImageView!
    
    var reminders: [Reminder]? = nil
    var editingReminder: Reminder!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForHeaderImageViewHeight.constant = 70
        } else {
            self.constraintForHeaderImageViewHeight.constant = 80
        }
        
        self.buttonAddNew.layer.cornerRadius = 28
        ModacityAnalytics.LogStringEvent("Reminders-Opened")
        
        if self.navigationController?.viewControllers.count == 1 {
            self.imageViewTopLeft.image = UIImage(named: "icon_menu")
        } else {
            self.imageViewTopLeft.image = UIImage(named: "icon_arrow_left")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReminders()
    }
    
    @IBAction func onBack(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("reminders-back")
        if self.navigationController?.viewControllers.count == 1 {
            self.sideMenuController?.toggleLeftViewAnimated()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_reminder_edit" {
            let conroller = segue.destination as! SetReminderViewController
            conroller.editingReminder = self.editingReminder
        } else if segue.identifier == "sid_add_new" {
            ModacityAnalytics.LogStringEvent("reminders-press-add-new")
        }
    }
    
    func loadReminders() {
        if let reminders = RemindersManager.manager.loadReminders() {
            if reminders.count > 0 {
                self.labelNoReminders.isHidden = true
            } else {
                self.labelNoReminders.isHidden = false
            }
            self.reminders = reminders.sorted(by: { (reminder1, reminder2) -> Bool in
                let time1 = reminder1.nextScheduledTime()
                let time2 = reminder2.nextScheduledTime()
                
                return time1.timeIntervalSince1970 < time2.timeIntervalSince1970
            })
        } else {
            self.reminders = nil
        }
        
        self.tableViewReminders.reloadData()
    }
}

extension RemindersListViewController: UITableViewDelegate, UITableViewDataSource, ReminderCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reminders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell") as! ReminderCell
        cell.configure(self.reminders![indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func onCellMenu(_ cell: ReminderCell, on button: UIButton, reminder: Reminder) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: button,
                                       rows: [["icon":"icon_pen_white", "text": "Edit"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                
                                                if row == 0 {
                                                    self.openReminderEditPage(reminder)
                                                } else {
                                                    self.deleteReminder(reminder)
                                                }
        }
    }
    
    func openReminderEditPage(_ reminder: Reminder) {
        self.editingReminder = reminder
        self.performSegue(withIdentifier: "sid_reminder_edit", sender: nil)
    }
    
    func deleteReminder(_ reminder: Reminder) {
        let alertController = UIAlertController(title: nil, message: "Are you sure to remove this reminder?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            ModacityAnalytics.LogStringEvent("reminders-deleted")
            RemindersManager.manager.removeReminder(id: reminder.id)
            self.loadReminders()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

protocol ReminderCellDelegate {
    func onCellMenu(_ cell: ReminderCell, on button: UIButton, reminder: Reminder)
}

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var labelRepeats: UILabel!
    @IBOutlet weak var buttonCellMenu: UIButton!
    @IBOutlet weak var labelNextSchedule: UILabel!
    
    var delegate: ReminderCellDelegate?
    
    var reminder: Reminder!
    
    func configure(_ reminder: Reminder) {
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.borderColor = Color(hexString: "#dfdfdf").cgColor
        self.viewContainer.layer.borderWidth = 1
        
        self.reminder = reminder
        
        self.labelPlaylistName.text = "Practice session: \(reminder.practiceSessionDescription())"
        
        
        if reminder.repeatMode == nil || reminder.repeatMode! == 0 {
            self.labelRepeats.text = reminder.repeatDescription()
            self.labelNextSchedule.text = ""
        } else {
            self.labelRepeats.text = "Repeats: \(reminder.repeatDescription())"
            let nextSchedule = reminder.nextScheduledTime()
            if nextSchedule.isToday {
                self.labelNextSchedule.text = "Next scheduled :  Today \(nextSchedule.toString(format: "h:mm a"))"
            } else if nextSchedule.isTomorrow {
                self.labelNextSchedule.text = "Next scheduled :  Tomorrow \(nextSchedule.toString(format: "h:mm a"))"
            } else {
                self.labelNextSchedule.text = "Next scheduled : \(reminder.nextScheduledTime().toString(format: "MMM d, h:mm a"))"
            }
        }
        
    }
    
    @IBAction func onCellMenu(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onCellMenu(self, on: self.buttonCellMenu, reminder: self.reminder)
        }
    }
}
