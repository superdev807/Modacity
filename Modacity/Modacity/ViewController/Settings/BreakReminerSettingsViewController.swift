//
//  BreakReminerSettingsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 7/16/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class BreakReminerSettingsViewController: UIViewController {
   
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewReminderSettings: UIView!
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var labelMinutes: UILabel!
    @IBOutlet weak var textfieldMinutes: UITextField!
    private var formatter: NumberFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        formatter = NumberFormatter()
        formatter.numberStyle = .decimal//NSNumberFormatterStyle.DecimalStyle
        formatter.minimum = 0
        
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        let practiceBreakTime = AppOveralDataManager.manager.practiceBreakTime()
        if practiceBreakTime > 0 {
            self.buttonSwitch.isSelected = true
            self.viewReminderSettings.alpha = 1.0
            self.viewReminderSettings.isUserInteractionEnabled = true
            self.textfieldMinutes.text = "\(practiceBreakTime)"
        } else {
            self.buttonSwitch.isSelected = false
            self.viewReminderSettings.alpha = 0.5
            self.viewReminderSettings.isUserInteractionEnabled = false
            self.textfieldMinutes.text = "\(10)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        self.buttonSwitch.isSelected = !self.buttonSwitch.isSelected
        if !self.buttonSwitch.isSelected {
            self.viewReminderSettings.alpha = 0.5
            self.viewReminderSettings.isUserInteractionEnabled = false
            AppOveralDataManager.manager.storePracticeBreakTime(0)
        } else {
            self.viewReminderSettings.alpha = 1.0
            self.viewReminderSettings.isUserInteractionEnabled = true
            self.storeTime()
        }
    }
    
    @IBAction func onNumber(_ sender: Any) {
        self.textfieldMinutes.becomeFirstResponder()
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
        self.storeTime()
    }
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        self.storeTime()
    }
    
    func storeTime() {
        if let number = formatter.number(from: self.textfieldMinutes.text ?? "") {
            if number.intValue != 0 {
                AppOveralDataManager.manager.storePracticeBreakTime(number.intValue)
            }
        }
    }
}

extension BreakReminerSettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty { return true }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if replacementText.count > 2 {
            return false
        }

        if let number = formatter.number(from: replacementText) {
            if number.intValue < 100 && number.intValue >= 0 {
                return true
            }
        }

        return false
    }
}
