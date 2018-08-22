//
//  UpdatePracticeEntryViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 20/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

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
    
    let highlightedColor = Color(hexString: "#92939B")
    var popupView: DatePickerPopupView!
    var selectedDate = Date()
    var dateSelected = false
    
    var practiceItemId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderViewHeight.constant = 104
        }
        
        self.viewFirstPanel.layer.cornerRadius = 5
        self.viewFirstPanel.layer.borderColor = Color(hexString: "#D6D6D7").cgColor
        self.viewFirstPanel.layer.borderWidth = 1
        
        self.viewSecondPanel.layer.cornerRadius = 5
        self.viewSecondPanel.layer.borderColor = Color(hexString: "#D6D6D7").cgColor
        self.viewSecondPanel.layer.borderWidth = 1
        
        self.buttonAddEntry.layer.cornerRadius = 28
        self.buttonAddEntry.isEnabled = false
        self.buttonAddEntry.backgroundColor = Color(hexString: "#9B9B9B")
        self.buttonCover.isHidden = true
        
        if self.isUpdating {
            self.buttonAddEntry.setTitle("Update Entry", for: .normal)
            self.labelTitle.text = "Edit Entry"
            
            if self.editingPracticeData != nil {
                self.selectedDate = self.editingPracticeData.entryDateString.date(format: "yy-MM-dd") ?? Date(timeIntervalSince1970: self.editingPracticeData.startedTime)
                self.labelTotalDate.text = self.selectedDate.toString(format: "MMMM d, yyyy")
                self.dateSelected = true
                self.labelTotalDate.textColor = highlightedColor
                
                var seconds = self.editingPracticeData.practiceTimeInSeconds ?? 0
                if seconds > 0 {
                    var string = ""
                    if seconds / 3600 > 0 {
                        string = String(format: "%@%02d", string, seconds / 3600)
                    } else {
                        string = "00"
                    }
                    
                    seconds = seconds % 3600
                    if seconds / 60 > 0 {
                        string = String(format: "%@%02d", string, seconds / 60)
                    } else {
                        string = "\(string)00"
                    }
                    
                    seconds = seconds % 60
                    if seconds > 0 {
                        string = String(format: "%@%02d", string, seconds)
                    } else {
                        string = "\(string)00"
                    }
                    
                    self.textfieldTimeInput.text = string
                    self.labelTotalTime.attributedText = self.convertInputStringToTime(string)
                }
                self.processButtonEntry()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
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
    }
    
    @IBAction func onDateInput(_ sender: Any) {
        self.showDateInputPicker()
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
        self.viewContainer.bringSubview(toFront: popupView)
        
        self.buttonCover.isHidden = false
    }
    
    func selectedDateOnDatePickerPopupView(_ popupView: DatePickerPopupView, date: Date) {
        self.selectedDate = date
        self.dateSelected = true
        self.labelTotalDate.text = date.toString(format: "MMMM d, yyyy")
        self.labelTotalDate.textColor = highlightedColor
        popupView.removeFromSuperview()
        self.buttonCover.isHidden = true
        self.processButtonEntry()
    }
    
    func cancelDateOnDatePickerPopupView(_ popupView: DatePickerPopupView) {
        popupView.removeFromSuperview()
        self.buttonCover.isHidden = true
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
    }
    
    @IBAction func onEditingDidEndOnField(_ sender: Any) {
    }
    
    func validateInputText(_ text:String) -> Bool {
        var idx = 0
        while idx < text.count {
            if let number = Int(text[idx..<(idx+1)]) {
                if number > 5 {
                    return false
                }
            } else {
                return false
            }
            idx = idx + 2
        }
        return true
    }
    
    func convertInputStringToTime(_ inputString: String) -> NSAttributedString {
        if inputString.count > 0 {
            var res = ""
            
            for idx in 0..<6 {
                if inputString.count > idx {
                    res = res + inputString[idx..<(idx + 1)]
                } else {
                    res = res + "0"
                }
                
                if idx == 1 || idx == 3 {
                    res = res + ":"
                }
            }
            
            let attributedString = NSMutableAttributedString(string: res)
            let length = [1,3,4,6,7,8][inputString.count - 1]
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color(hexString:"#C8C9CD"), range: NSMakeRange(0, res.count))
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: highlightedColor, range: NSMakeRange(0, length))
            return attributedString
        } else {
            let string = "00:00:00"
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color(hexString:"#C8C9CD"), range: NSMakeRange(0, string.count))
            return attributedString
        }
    }
    
    func convertToSeconds(_ text: String) -> Int? {
        if text.count == 6 {
            var idx = 0
            var res = 0
            while idx < 6 {
                if let number = Int(text[idx..<(idx + 2)]) {
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
        } else {
            return nil
        }
    }
}

extension UpdatePracticeEntryViewController {
    func processButtonEntry() {
        if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
            if self.dateSelected {
                print("total time - \(totalTime)")
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
                    let oldEntryDate = self.editingPracticeData.entryDateString ?? ""
                    let oldFromTime = self.editingPracticeData.fromTime ?? ""
                    
                    self.editingPracticeData.practiceTimeInSeconds = totalTime
                    self.editingPracticeData.startedTime = (self.selectedDate.toString(format: "yyyyMMdd") + oldFromTime).date(format: "yyyyMMddHH:mm:ss")?.timeIntervalSince1970 ?? self.selectedDate.timeIntervalSince1970
                    self.editingPracticeData.entryDateString = self.selectedDate.toString(format: "yy-MM-dd")
                    PracticingDailyLocalManager.manager.updatePracticingData(data: self.editingPracticeData, oldEntryDate: oldEntryDate, newEntryDate: self.editingPracticeData.entryDateString ?? "")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            if let totalTime = self.convertToSeconds(self.textfieldTimeInput.text ?? "") {
                if self.dateSelected {
                    PracticingDailyLocalManager.manager.saveManualPracticing(duration: totalTime, practiceItemId: self.practiceItemId, started: self.selectedDate)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
