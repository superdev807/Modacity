//
//  UpdatePracticeEntryViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 20/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import CHGInputAccessoryView

class UpdatePracticeEntryViewController: UIViewController {
    
    var isUpdating = false
    var editingPracticeData: PracticeDaily!
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFirstPanel: UIView!
    @IBOutlet weak var labelTotalTime: UILabel!
    @IBOutlet weak var labelTotalDate: UILabel!
    @IBOutlet weak var viewSecondPanel: UIView!
    @IBOutlet weak var buttonAddEntry: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var buttonCover: UIButton!
    @IBOutlet weak var textfieldTimeInput: UITextField!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelPlaylistCaption: UILabel!
    @IBOutlet weak var viewPlaylistPanel: UIView!
    @IBOutlet weak var labelPlaylist: UILabel!
    @IBOutlet weak var buttonPlaylistSelect: UIButton!
    
    @IBOutlet weak var viewItemNamePanel: UIView!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var labelItemNameCaption: UILabel!
    @IBOutlet weak var buttonItemSelect: UIButton!
    
    @IBOutlet weak var constraintVerticalSpace1: NSLayoutConstraint!
    @IBOutlet weak var constraintVerticalSpace2: NSLayoutConstraint!
    @IBOutlet weak var constraintVeriticalSpace3: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewMain: UIScrollView!
    
    @IBOutlet weak var buttonSubCover: UIButton!
    
    let highlightedColor = Color(hexString: "#5E5F6C")
    var popupView: DatePickerPopupView!
    var selectedDate = Date()
    var dateSelected = false
    
    var fromPlaylist = false
    var playlistItemId: String? = nil
    var practiceItemId: String!
    
    var selectedPracticeItem: PracticeItem? = nil
    
    var selectedPlaylist: Playlist? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.makeViewsStyles()
        
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderViewHeight.constant = 104
        }
        
        self.viewItemNamePanel.isHidden = true
        self.labelItemNameCaption.isHidden = true
        self.viewPlaylistPanel.isHidden = true
        self.labelPlaylistCaption.isHidden = true
        
        if self.fromPlaylist {
            self.viewItemNamePanel.isHidden = false
            self.labelItemNameCaption.isHidden = false
            
            if self.playlistItemId == nil {
                self.viewPlaylistPanel.isHidden = false
                self.labelPlaylistCaption.isHidden = false
            }
        }
        
        self.attachInputAccessoryView()
        
        if self.isUpdating {
            self.buttonAddEntry.setTitle("Update Entry", for: .normal)
            self.labelTitle.text = "Edit Entry"
            
            self.showUpdatingValues()
        }
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintVerticalSpace1.constant = 10
            self.constraintVerticalSpace2.constant = 10
            self.constraintVeriticalSpace3.constant = 10
        }
        
        self.buttonSubCover.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeViewsStyles() {
        self.viewFirstPanel.styling(cornerRadius: 5, borderColor: Color(hexString: "#D6D6D7"), borderWidth: 1)
        self.viewSecondPanel.styling(cornerRadius: 5, borderColor: Color(hexString: "#D6D6D7"), borderWidth: 1)
        self.viewItemNamePanel.styling(cornerRadius: 5, borderColor: Color(hexString: "#D6D6D7"), borderWidth: 1)
        self.viewPlaylistPanel.styling(cornerRadius: 5, borderColor: Color(hexString: "#D6D6D7"), borderWidth: 1)
        
        self.buttonAddEntry.styling(cornerRadius: 28)
        
        self.buttonAddEntry.isEnabled = false
        self.buttonAddEntry.backgroundColor = Color(hexString: "#9B9B9B")
        self.buttonCover.isHidden = true
    }
    
    @IBAction func onBack(_ sender: Any) {
        if self.isUpdating {
            ModacityAnalytics.LogEvent(.BackFromEditTime)
        } else {
            ModacityAnalytics.LogEvent(.BackFromAddTime)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTimeInput(_ sender: Any) {
        self.textfieldTimeInput.becomeFirstResponder()
    }
    
    @IBAction func onCover(_ sender: Any) {
        self.buttonCover.isHidden = true
        if popupView != nil {
            popupView.removeFromSuperview()
        }
        self.textfieldTimeInput.resignFirstResponder()
        self.viewContainer.bringSubview(toFront: self.buttonCover)
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.scrollViewMain.setContentOffset(CGPoint(x:0, y:0), animated: true)
            self.buttonSubCover.isHidden = true
        }
    }
    
    @IBAction func onDateInput(_ sender: Any) {
        if self.popupView != nil && self.popupView.superview != nil {
            return
        }
        self.showDateInputPicker()
    }
    
    @IBAction func onItemName(_ sender: Any) {
        self.openPracticeItemSelect()
    }
    
    @IBAction func onPlaylist(_ sender: Any) {
        self.openPlaylistItemSelect()
    }
    
    func showUpdatingValues() {
        
        if self.editingPracticeData != nil {
            
            self.selectedDate = self.editingPracticeData.entryDateString.date(format: "yy-MM-dd") ?? Date(timeIntervalSince1970: self.editingPracticeData.startedTime)
            self.labelTotalDate.text = self.selectedDate.toString(format: "MMMM d, yyyy")
            self.dateSelected = true
            self.labelTotalDate.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
            self.labelTotalDate.textColor = highlightedColor
            
            var seconds = self.editingPracticeData.practiceTimeInSeconds ?? 0
            if seconds > 0 {
                var string = ""
                if seconds / 3600 > 0 {
                    string = String(format: "%@%d", string, seconds / 3600)
                } else {
                    string = ""
                }
                
                seconds = seconds % 3600
                if seconds / 60 > 0 {
                    string = String(format: "%@%d", string, seconds / 60)
                } else {
                    if string.count > 0 {
                        string = "\(string)00"
                    } else {
                        string = "\(string)"
                    }
                }
                
                seconds = seconds % 60
                if seconds > 0 {
                    string = String(format: "%@%d", string, seconds)
                } else {
                    if string.count > 0 {
                        string = "\(string)00"
                    } else {
                        string = "\(string)"
                    }
                }
                
                self.textfieldTimeInput.text = string
                self.labelTotalTime.attributedText = self.convertInputStringToTime(string)
            }
            self.processButtonEntry()
            
        }
        
        if self.fromPlaylist {
            if self.editingPracticeData != nil {
                
                if let practiceItemId = self.editingPracticeData.practiceItemId {
                    
                    if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId) {
                        self.selectedPracticeItem = practiceItem
                        self.labelItemName.text = practiceItem.name
                        self.labelItemName.textColor = highlightedColor
                        self.labelItemName.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
                        
                        self.viewItemNamePanel.backgroundColor = Color.black.alpha(0.1)
                        self.buttonItemSelect.isEnabled = false
                        
                        if self.editingPracticeData.playlistId != nil {
                            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.editingPracticeData.playlistId) {
                                self.selectedPlaylist = playlist
                                self.labelPlaylist.text = playlist.name
                                self.labelPlaylist.textColor = highlightedColor
                                self.labelPlaylist.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
                                self.viewPlaylistPanel.backgroundColor = Color.black.alpha(0.1)
                                self.buttonPlaylistSelect.isEnabled = false
                            }
                        }
                        
                        self.processButtonEntry()
                    }
                    
                }
            }
        }
    }
    
}

extension UpdatePracticeEntryViewController: DatePickerPopupViewDelegate {
    
    func showDateInputPicker() {
        popupView = DatePickerPopupView()
        popupView.delegate = self
        self.viewContainer.addSubview(popupView)
        popupView.datePicker.date = self.selectedDate
        self.viewSecondPanel.bottomAnchor.constraint(equalTo: popupView.topAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: DatePickerPopupView.PopupWidth).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: DatePickerPopupView.PopupHeight).isActive = true
        popupView.centerXAnchor.constraint(equalTo: self.viewContainer.centerXAnchor).isActive = true
        
        self.buttonCover.isHidden = false
        self.viewContainer.bringSubview(toFront: self.buttonCover)
        self.viewContainer.bringSubview(toFront: self.viewSecondPanel)
        self.viewContainer.bringSubview(toFront: popupView)
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.scrollViewMain.setContentOffset(CGPoint(x:0, y:100), animated: true)
            self.buttonSubCover.isHidden = false
        }
    }
    
    func selectedDateOnDatePickerPopupView(_ popupView: DatePickerPopupView, date: Date) {
        self.selectedDate = date
        self.dateSelected = true
        self.labelTotalDate.text = date.toString(format: "MMMM d, yyyy")
        self.labelTotalDate.textColor = highlightedColor
        self.labelTotalDate.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
        popupView.removeFromSuperview()
        self.buttonCover.isHidden = true
        self.processButtonEntry()
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.scrollViewMain.setContentOffset(CGPoint(x:0, y:0), animated: true)
            self.buttonSubCover.isHidden = true
        }
    }
    
    func cancelDateOnDatePickerPopupView(_ popupView: DatePickerPopupView) {
        popupView.removeFromSuperview()
        self.buttonCover.isHidden = true
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.scrollViewMain.setContentOffset(CGPoint(x:0, y:0), animated: true)
            self.buttonSubCover.isHidden = true
        }
    }
}

extension UpdatePracticeEntryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if updatedText.count > 6 {
                return false
            } else {
                return self.validateInputText(updatedText)
            }
        }
        return true
    }
    
    @IBAction func onDidEndOnExitOnTimeInputField(_ sender: Any) {
    }
    
    @IBAction func onEditingChangedOnTimeInputField(_ sender: Any) {
        self.labelTotalTime.attributedText = self.convertInputStringToTime(self.textfieldTimeInput.text ?? "")
        self.processButtonEntry()
    }
    
    @IBAction func onEditingDidBeginOnField(_ sender: Any) {
        self.buttonCover.isHidden = false
        self.viewContainer.bringSubview(toFront: self.buttonCover)
        self.viewContainer.bringSubview(toFront: self.viewFirstPanel)
    }
    
    @IBAction func onEditingDidEndOnField(_ sender: Any) {
        self.buttonCover.isHidden = true
        self.viewContainer.bringSubview(toFront: self.buttonCover)
    }
    
    func reversedString(from text:String) -> String {
        let length = text.count
        var string = ""
        for _ in 0..<(6 - length) {
            string = string + "0"
        }
        string = string + text
        return string
    }
    
    func validateInputText(_ text:String) -> Bool {
        
        if text.count > 6 {
            return false
        }

        return true
    }
    
    func convertInputStringToTime(_ inputString: String) -> NSAttributedString {
        
        let reversed = self.reversedString(from: inputString)
        
        var res = ""
        for idx in 0..<6 {
            res = res + reversed[idx..<(idx + 1)]
            if idx == 1 || idx == 3 {
                res = res + ":"
            }
        }
        
        let attributedString = NSMutableAttributedString(string: res)
        let length = [0,1,2,4,5,7,8][inputString.count]
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color(hexString:"#92939B"), range: NSMakeRange(0, res.count))
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: highlightedColor, range: NSMakeRange(8 - length, length))
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: AppConfig.appFontLatoBold, size: 14), range: NSMakeRange(8 - length, length))
        return attributedString
    }
    
    func convertToSeconds(_ text: String) -> Int? {
        let reversed = self.reversedString(from: text)
        
        var idx = 0
        var res = 0
        while idx < 6 {
            if let number = Int(reversed[idx..<(idx + 2)]) {
                if idx == 0 {
                    res = res + number * 3600
                } else if idx == 2 {
                    res = res + number * 60
                } else {
                    res = res + number
                }
            }
            idx = idx + 2
        }
        return res
    }
}

extension UpdatePracticeEntryViewController {
    
    func processButtonEntry() {
        if let _ = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
            if self.dateSelected {
                
                if self.fromPlaylist && self.playlistItemId == nil {
                    if self.selectedPracticeItem == nil && self.selectedPlaylist == nil {
                        self.buttonAddEntry.backgroundColor = Color(hexString: "#9B9B9B")
                        self.buttonAddEntry.isEnabled = false
                        return
                    }
                }
                
                self.buttonAddEntry.isEnabled = true
                self.buttonAddEntry.backgroundColor = Color(hexString: "#5311CA")
                return
            }
        }
        
        self.buttonAddEntry.backgroundColor = Color(hexString: "#9B9B9B")
        self.buttonAddEntry.isEnabled = false
    }
    
    @IBAction func onAddEntry(_ sender: Any) {
        
        if self.isUpdating {
            if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
                if self.dateSelected {
                    ModacityAnalytics.LogEvent(.PressedUpdateTime)
                    let oldEntryDate = self.editingPracticeData.entryDateString ?? ""
                    let oldFromTime = self.editingPracticeData.fromTime ?? ""
                    let oldPracticeTime = self.editingPracticeData.practiceTimeInSeconds ?? 0
                    self.editingPracticeData.practiceTimeInSeconds = totalTime
                    self.editingPracticeData.startedTime = (self.selectedDate.toString(format: "yyyyMMdd") + oldFromTime).date(format: "yyyyMMddHH:mm:ss")?.timeIntervalSince1970 ?? self.selectedDate.timeIntervalSince1970
                    self.editingPracticeData.entryDateString = self.selectedDate.toString(format: "yy-MM-dd")
                    PracticingDailyLocalManager.manager.updatePracticingData(data: self.editingPracticeData,
                                                                             oldEntryDate: oldEntryDate,
                                                                             newEntryDate: self.editingPracticeData.entryDateString ?? "",
                                                                             timeChange: (totalTime - oldPracticeTime))
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            
            if !self.fromPlaylist {
                if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
                    if self.dateSelected {
                        ModacityAnalytics.LogEvent(.PressedAddTime, params: ["type":"is practice item"])
                        PracticingDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: self.practiceItemId, started: self.selectedDate)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                if let playlistId = self.playlistItemId {
                    if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
                        if self.dateSelected {
                            ModacityAnalytics.LogEvent(.PressedAddTime, params: ["type":"is playlist item"])
                            if let practiceItem = self.selectedPracticeItem {
                                PlaylistDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: practiceItem.id, started: self.selectedDate, playlistId: playlistId)
                            } else {
                                PlaylistDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: nil, started: self.selectedDate, playlistId: playlistId)
                            }
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
                        if self.dateSelected {
                            if let playlist = self.selectedPlaylist {
                                if let practiceItem = self.selectedPracticeItem {
                                    PlaylistDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: practiceItem.id, started: self.selectedDate, playlistId: playlist.id)
                                } else {
                                    PlaylistDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: nil, started: self.selectedDate, playlistId: playlist.id)
                                }
                            } else {
                                if let practiceItem = self.selectedPracticeItem {
                                    PracticingDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: practiceItem.id, started: self.selectedDate)
                                }
                            }
                            ModacityAnalytics.LogEvent(.PressedAddTime, params: ["type":"is overview"])
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension UpdatePracticeEntryViewController: PracticeItemListViewControllerDelegate {
    func openPracticeItemSelect() {
        let controller = UIStoryboard(name: "practice_item", bundle: nil).instantiateViewController(withIdentifier: "PracticeItemListViewController") as! PracticeItemListViewController
        controller.delegate = self
        controller.singleSelectMode = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func practiceItemListViewController(_ controller: PracticeItemListViewController, selectedPracticeItem: PracticeItem) {
        self.selectedPracticeItem = selectedPracticeItem
        self.labelItemName.text = selectedPracticeItem.name
        self.labelItemName.textColor = highlightedColor
        self.labelItemName.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
        self.processButtonEntry()
    }
}

extension UpdatePracticeEntryViewController: PlaylistListViewControllerDelegate {
    
    func openPlaylistItemSelect() {
        let controller = UIStoryboard(name: "playlist", bundle: nil).instantiateViewController(withIdentifier: "PlaylistListViewController") as! PlaylistListViewController
        controller.singleSelectionMode = true
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func playlistViewController(_ controller: PlaylistListViewController, selectedPlaylist: Playlist) {
        self.labelPlaylist.text = selectedPlaylist.name
        self.labelPlaylist.textColor = highlightedColor
        self.labelPlaylist.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
        self.selectedPlaylist = selectedPlaylist
        self.processButtonEntry()
    }
}

extension UpdatePracticeEntryViewController: CHGInputAccessoryViewDelegate {
    
    func attachInputAccessoryView() {
        let inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        let flexible = CHGInputAccessoryViewItem.flexibleSpace()!
        let cancel = CHGInputAccessoryViewItem.button(withTitle: "Cancel")!
        cancel.tintColor = Color.black
        cancel.tag = 100
        let done = CHGInputAccessoryViewItem.button(withTitle: "Next")!
        done.tintColor = Color.black
        done.tag = 101
        inputAccessoryView.items = [cancel, flexible, done]
        inputAccessoryView.inputAccessoryViewDelegate = self
        self.textfieldTimeInput.inputAccessoryView = inputAccessoryView
    }
    
    func didTap(_ item: CHGInputAccessoryViewItem!) {
        if item.tag == 100 {
            self.textfieldTimeInput.resignFirstResponder()
        } else if item.tag == 101 {
            self.textfieldTimeInput.resignFirstResponder()
            self.showDateInputPicker()
        }
    }
}
