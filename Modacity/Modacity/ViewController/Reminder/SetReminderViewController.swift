//
//  SetReminderViewController.swift
//  Modacity
//
//  Created by Software Engineer on 4/11/19.
//  Copyright © 2019 Modacity, Inc. All rights reserved.
//

import UIKit

class SetReminderViewController: UIViewController {
    
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTimePanel: UIView!
    @IBOutlet weak var viewRepeatPanel: UIView!
    @IBOutlet weak var viewPracticeSessionPanel: UIView!
    @IBOutlet weak var labelSelectedTime: UILabel!
    @IBOutlet weak var labelRepeat: UILabel!
    @IBOutlet weak var labelPracticeSession: UILabel!
    @IBOutlet weak var labelRepeatCustomDetails: UILabel!
    
    let labelsPlaceholderColor = AppConfig.UI.AppColors.placeholderTextColorGray
    let labelsSelectedColor = Color.black
    
    var timerInputView: TimePickerOverlayView!
    var repeatOptionsPickerBottomSheetView: OptionsPickerBottomSheetView!
    var customRecurrencePickerView: CustomRecurrencePicker!
    
    var editingReminder: Reminder? = nil
    
    var selectedTime: Date? = nil
    var selectedRepeatMode: Int? = nil
    var selectedPlaylistId: String? = nil
    var selectedPlaylist: Playlist? = nil
    var selectedCustom: ReminderCustomRepeatData? = nil
    
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
        
        self.configureViewPanels()
        
        if let editingReminder = self.editingReminder {
            self.selectedTime = editingReminder.getTime()
            self.selectedRepeatMode = editingReminder.repeatMode
            self.selectedPlaylistId = editingReminder.practiceSessionId
            self.selectedCustom = editingReminder.custom
            
            if let playlistId = self.selectedPlaylistId {
                self.selectedPlaylist = PlaylistLocalManager.manager.loadPlaylist(forId: playlistId)
                if let playlist = self.selectedPlaylist {
                    self.labelPracticeSession.text = playlist.name
                    self.labelPracticeSession.textColor = Color.black
                }
            }
        }
        
        self.showSelectedTimeValue()
        self.showSelectedRepeatMode()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    func configureViewPanels() {
        self.viewTimePanel.layer.cornerRadius = 5
        self.viewTimePanel.layer.borderColor = Color(hexString: "#d8d8db").cgColor
        self.viewTimePanel.layer.borderWidth = 1
        
        self.viewRepeatPanel.layer.cornerRadius = 5
        self.viewRepeatPanel.layer.borderColor = Color(hexString: "#d8d8db").cgColor
        self.viewRepeatPanel.layer.borderWidth = 1
        
        self.viewPracticeSessionPanel.layer.cornerRadius = 5
        self.viewPracticeSessionPanel.layer.borderColor = Color(hexString: "#d8d8db").cgColor
        self.viewPracticeSessionPanel.layer.borderWidth = 1
    }
    
    @IBAction func onTime(_ sender: Any) {
        self.showTimeInputBox()
    }
    
    @IBAction func onRepeat(_ sender: Any) {
        self.showRepeatOptionsPickerView()
    }
    
    @IBAction func onPracticeSession(_ sender: Any) {
        let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
        controller.singleSelectionMode = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SetReminderViewController: TimePickerOverlayViewDelegate {
    
    func showTimeInputBox() {
        self.timerInputView = TimePickerOverlayView()
        self.timerInputView.delegate = self
        self.view.addSubview(self.timerInputView)
        self.timerInputView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.timerInputView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20).isActive = true
        self.timerInputView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.timerInputView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        if let time = self.selectedTime {
            self.timerInputView.datePicker.date = time
        }
        
        self.timerInputView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.timerInputView.alpha = 1
        }
    }
    
    func hideTimeInputBox() {
        UIView.animate(withDuration: 0.5, animations: {
            self.timerInputView.alpha = 0
        }) { (finished) in
            self.timerInputView.removeFromSuperview()
        }
    }
    
    func showSelectedTimeValue() {
        if let time = self.selectedTime {
            self.labelSelectedTime.textColor = labelsSelectedColor
            if time.isToday {
                self.labelSelectedTime.text = "Today at \(time.toString(format: "h:mm a"))"
            } else {
                self.labelSelectedTime.text = time.toString(format: "h:mm a, MMM d")
            }
            
        } else {
            self.labelSelectedTime.textColor = labelsPlaceholderColor
            self.labelSelectedTime.text = "Time"
        }
    }

    func selectedTimeOnTimePickerPopupView(_ popupView: TimePickerOverlayView, time: Date) {
        self.selectedTime = time
        self.showSelectedTimeValue()
        self.hideTimeInputBox()
    }
    
    func cancelTimeOnTimePickerPopupView(_ popupView: TimePickerOverlayView) {
        self.hideTimeInputBox()
    }
    
}

extension SetReminderViewController: OptionsPickerBottomSheetViewDelegate {
    
    func showRepeatOptionsPickerView() {
        self.repeatOptionsPickerBottomSheetView = OptionsPickerBottomSheetView()
        self.repeatOptionsPickerBottomSheetView.delegate = self
        self.view.addSubview(self.repeatOptionsPickerBottomSheetView)
        self.repeatOptionsPickerBottomSheetView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.repeatOptionsPickerBottomSheetView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20).isActive = true
        self.repeatOptionsPickerBottomSheetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.repeatOptionsPickerBottomSheetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.repeatOptionsPickerBottomSheetView.configureOptions(Reminder.reminderRepeatingModes)
    }
    
    func selectOptionInPickerBottomSheet(_ view: OptionsPickerBottomSheetView, optionIdx: Int, optionValue: String) {
        
        if optionIdx == Reminder.reminderRepeatingModes.count - 1 {     // Custom
            self.repeatOptionsPickerBottomSheetView.tableViewOptions.reloadData()
            self.repeatOptionsPickerBottomSheetView.removeFromSuperview()
            self.showCustomRecurrencePicker()
        } else {
            self.selectedRepeatMode = optionIdx
            self.showSelectedRepeatMode()
        }
    }
    
    func cancelOptionSelectInPickerBottomSheet(_ view: OptionsPickerBottomSheetView) {
        self.repeatOptionsPickerBottomSheetView.removeFromSuperview()
    }
    
    func showSelectedRepeatMode() {
        self.labelRepeatCustomDetails.isHidden = true
        if var mode = self.selectedRepeatMode {
            self.labelRepeat.textColor = labelsSelectedColor
            if mode > Reminder.reminderRepeatingModes.count - 1 {
                mode = Reminder.reminderRepeatingModes.count - 1
            }
            self.labelRepeat.text = Reminder.reminderRepeatingModes[mode]
            
            if mode == Reminder.reminderRepeatingModes.count - 1 {
                self.labelRepeatCustomDetails.isHidden = false
                if let custom = self.selectedCustom {
                    self.labelRepeatCustomDetails.text = custom.customRepeatDescription()
                }
            }
        } else {
            self.labelRepeat.textColor = labelsPlaceholderColor
            self.labelRepeat.text = "Repeat"
        }
    }
    
}

extension SetReminderViewController: PlaylistListViewControllerDelegate {
    
    func playlistViewController(_ controller: PlaylistListViewController, selectedPlaylist: Playlist) {
        self.selectedPlaylistId = selectedPlaylist.id
        self.selectedPlaylist = selectedPlaylist
        self.showSelectedPlaylist()
    }
    
    func showSelectedPlaylist() {
        if let playlistId = self.selectedPlaylistId {
            if let playlist = self.selectedPlaylist {
                self.labelPracticeSession.textColor = labelsSelectedColor
                self.labelPracticeSession.text = playlist.name
            } else {
                self.selectedPlaylist = PlaylistLocalManager.manager.loadPlaylist(forId: playlistId)
                self.labelPracticeSession.textColor = labelsSelectedColor
                self.labelPracticeSession.text = self.selectedPlaylist!.name
            }
        } else {
            self.labelPracticeSession.textColor = labelsPlaceholderColor
            self.labelPracticeSession.text = "Practice Session (Optional)"
        }
    }
    
}

extension SetReminderViewController: CustomRecurrencePickerDelegate {
    
    func showCustomRecurrencePicker() {
        self.customRecurrencePickerView = CustomRecurrencePicker()
        self.customRecurrencePickerView.delegate = self
        self.view.addSubview(self.customRecurrencePickerView)
        self.customRecurrencePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.customRecurrencePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -20).isActive = true
        self.customRecurrencePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.customRecurrencePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.customRecurrencePickerView.configure(with: self.selectedCustom)
    }
    
    func selectCustomRecurrence(everyMode: Int, onWeeks: [Int], onDays: [Int], endsMode: Int, endsDate: Date?) {
        
        
        if ((everyMode == 0 && onWeeks.count == 0) || (everyMode == 1 && onDays.count == 0)) {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Repeat days setting is empty.")
        }
        
        let custom = ReminderCustomRepeatData()
        custom.everyMode = everyMode
        custom.onWeeks = onWeeks
        custom.onDays = onDays
        custom.endsMode = endsMode
        custom.endsDate = endsDate?.timeIntervalSince1970
        
        self.selectedRepeatMode = Reminder.reminderRepeatingModes.count - 1
        self.showSelectedRepeatMode()
        self.selectedCustom = custom
        self.showSelectedRepeatMode()
        self.customRecurrencePickerView.removeFromSuperview()
    }
    
    func closeCustomRecurrencePickerView(_ view: CustomRecurrencePicker) {
        self.customRecurrencePickerView.removeFromSuperview()
    }
}

extension SetReminderViewController {
    
    @IBAction func onRemindMe(_ sender: Any) {
        
        if self.selectedTime == nil {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Time is missing.")
            return
        }
        
        if self.selectedRepeatMode == nil || self.selectedRepeatMode! == 0 {
            let now = Date()
            
            let time = self.selectedTime!
            
            if time.timeIntervalSince1970 < now.timeIntervalSince1970 {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Reminder time already passed.")
                return
            }
        }
        
        if self.selectedRepeatMode != nil && self.selectedRepeatMode! == Reminder.reminderRepeatingModes.count - 1 {
            if let custom = self.selectedCustom {
                if (custom.everyMode == 0 && custom.onWeeks.count == 0) || (custom.everyMode == 1 && custom.onDays.count == 0) {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Reminder repeat setting is invalid.")
                    return
                }
                
                if custom.calculateSchedulingCount(from: Date()) == 0 {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Reminder repeat setting is invalid.")
                    return
                }
            }
        }
        
        if let selectedTime = self.selectedTime {
        
            if let reminder = self.editingReminder {
                
                reminder.practiceSessionId = self.selectedPlaylistId
                reminder.timeString = selectedTime.toString(format: "yyyy-MM-dd HH:mm z")
                reminder.timeStringFormat = "yyyy-MM-dd HH:mm z"
                if self.selectedRepeatMode == nil {
                    reminder.repeatMode = 0
                } else {
                    reminder.repeatMode  = self.selectedRepeatMode
                }
                reminder.custom = self.selectedCustom
                
                RemindersManager.manager.saveReminder(reminder)
                ModacityAnalytics.LogStringEvent("reminders-edit")
                
            } else {
                
                let reminder = Reminder()
                reminder.id = UUID().uuidString
                reminder.practiceSessionId = self.selectedPlaylistId
                reminder.timeString = selectedTime.toString(format: "yyyy-MM-dd HH:mm z")
                reminder.timeStringFormat = "yyyy-MM-dd HH:mm z"
                reminder.createdAt = Date().timeIntervalSince1970
                if self.selectedRepeatMode == nil {
                    reminder.repeatMode = 0
                } else {
                    reminder.repeatMode  = self.selectedRepeatMode
                }
                reminder.custom = self.selectedCustom
                
                RemindersManager.manager.saveReminder(reminder)
                ModacityAnalytics.LogStringEvent("reminders-scheduled")
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
