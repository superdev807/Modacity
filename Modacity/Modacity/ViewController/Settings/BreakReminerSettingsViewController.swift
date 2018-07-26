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
    @IBOutlet weak var imageViewHeader: UIImageView!
    var premiumLockView: PremiumUpgradeLockView!
    
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
        
        self.updateLockView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLockView), name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension BreakReminerSettingsViewController: UITextFieldDelegate, PremiumUpgradeLockViewDelegate {
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
    
    @objc func updateLockView() {
        if PremiumUpgradeManager.manager.isPremiumUnlocked() {
            if self.premiumLockView != nil {
                self.premiumLockView.removeFromSuperview()
                self.premiumLockView = nil
            }
        } else {
            self.attachLockView()
        }
    }
    
    func attachLockView() {
        if self.premiumLockView == nil {
            self.premiumLockView = PremiumUpgradeLockView()
            self.view.addSubview(self.premiumLockView)
            self.premiumLockView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.premiumLockView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.premiumLockView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.premiumLockView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
            
        }

        self.view.bringSubview(toFront: self.premiumLockView)
        self.premiumLockView.delegate = self
        self.premiumLockView.configureForTakeBreak()
    }
    
    func onFindOutMore() {
        let controller = UIStoryboard(name: "premium", bundle: nil).instantiateViewController(withIdentifier: "PremiumUpgradeScene")
        self.present(controller, animated: true, completion: nil)
    }
}
