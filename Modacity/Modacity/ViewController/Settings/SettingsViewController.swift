//
//  SettingsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/27/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class SettingsCellWithIconAndSubTitle: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    func configure(icon: String, caption: String, subTitle: String) {
        self.imageViewIcon.image = UIImage(named:icon)
        self.labelTitle.text = caption
        self.labelSubtitle.text = subTitle
    }
    
}

class SettingsCellWithoutIcon: UITableViewCell {
    @IBOutlet weak var labelCaption: UILabel!
    
    func configure(caption: String) {
        self.labelCaption.text = caption
    }
}

class SettingsCellWithIcon: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelCaption: UILabel!
    
    func configure(icon: String, caption: String) {
        self.imageViewIcon.image = UIImage(named: icon)
        self.labelCaption.text = caption
        self.labelCaption.textColor = Color.white
    }
    
}

class SettingsCellAccountType: UITableViewCell {
    
    @IBOutlet weak var labelAccountType: UILabel!
    
    func configure(type: String) {
        self.labelAccountType.text = type
    }
}

protocol SettingsCellTextFieldDelegate {
    func settingsCellTextField(_ cell: SettingsCellTextField, changedValue: String)
}

class SettingsCellTextField: UITableViewCell {
    
    @IBOutlet weak var textfieldInput: UITextField!
    var delegate: SettingsCellTextFieldDelegate?
    
    func configure(value: String) {
        self.textfieldInput.layer.cornerRadius = 5
        self.textfieldInput.text = value
    }
    
    @IBAction func onEditingChanged(_ sender: Any) {
        if let delegate = delegate {
            delegate.settingsCellTextField(self, changedValue: self.textfieldInput.text ?? "")
        }
    }
    
}

protocol SettingsCellWithSwitchDelegate {
    func onSwitchValueChanged(forCaption: String?)
}

class SettingsCellWithSwitch: UITableViewCell {
    
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var buttonSwitch: UIButton!
    
    var delegate: SettingsCellWithSwitchDelegate?
    
    func configure(caption: String, isOn: Bool) {
        self.labelCaption.text = caption
        self.buttonSwitch.isSelected = isOn
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onSwitchValueChanged(forCaption: self.labelCaption.text)
        }
    }
}

class SettingsCellWithDropdown: UITableViewCell {
    
    @IBOutlet weak var labelStorageLimit: UILabel!
    
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    var isBetaVersion: Bool = false // we will use this for beta-only experimental settings
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: AppConfig.appNotificationProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
        ModacityAnalytics.LogStringEvent("Loaded Settings Screen")

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    @objc func refresh() {
        self.tableViewSettings.reloadData()
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return 5
        } else if section == 2 {
            if PremiumDataManager.manager.isPremiumUnlocked() {
                return 5
            } else {
                return 4
            }
        } else if section == 3 {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "MY ACCOUNT"
        } else if section == 2 {
            return "APP SETTINGS"
        } else if section == 3 {
            return "TIMER"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = Color.white.alpha(0.1)
        let header = view as! UITableViewHeaderFooterView
        header.backgroundColor = Color.white.alpha(0.1)
        header.textLabel?.textColor = Color.white
        header.textLabel?.font = UIFont(name: AppConfig.appFontLatoRegular, size: 12)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIconAndSubTitle") as! SettingsCellWithIconAndSubTitle
                cell.configure(icon: "img_profile_placeholder", caption: "DISPLAY NAME", subTitle: MyProfileLocalManager.manager.me?.displayName() ?? "")
                cell.accessoryType = .disclosureIndicator
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIcon") as! SettingsCellWithIcon
                cell.configure(icon: "icon_settings_star", caption: "Rate the App")
                cell.labelCaption.textColor = Color(hexString: "#ffffff")
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIcon") as! SettingsCellWithIcon
                cell.configure(icon: "icon_settings_share", caption: "Share the App")
                cell.labelCaption.textColor = Color(hexString: "#ffffff")
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellAccountType") as! SettingsCellAccountType
                if PremiumDataManager.manager.isPremiumUnlocked() {
                    cell.configure(type: "Premium")
                } else {
                    cell.configure(type: "Free")
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIconAndSubTitle") as! SettingsCellWithIconAndSubTitle
                cell.configure(icon: "icon_settings_email", caption: "EMAIL", subTitle: MyProfileLocalManager.manager.me?.email ?? "")
                cell.accessoryType = .none
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIconAndSubTitle") as! SettingsCellWithIconAndSubTitle
                cell.configure(icon: "icon_settings_password", caption: "PASSWORD", subTitle: "Change Password")
                cell.accessoryType = .disclosureIndicator
                return cell
            } else if indexPath.row == 3 {
                if PremiumDataManager.manager.isPremiumUnlocked() {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithoutIcon") as! SettingsCellWithoutIcon
                    cell.configure(caption: "Manage Subscription")
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIcon") as! SettingsCellWithIcon
                    cell.configure(icon: "icon_settings_premium", caption: "Upgrade to Premium")
                    cell.labelCaption.textColor = Color(hexString: "#908FE6")
                    return cell
                }
            } else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithoutIcon") as! SettingsCellWithoutIcon
                cell.configure(caption: "Subscription Terms")
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = self.tableViewSettings.dequeueReusableCell(withIdentifier: "SettingsCellTextField") as! SettingsCellTextField
                cell.configure(value: String(AppOveralDataManager.manager.tuningStandard()))
                cell.delegate = self
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "Prevent Phone Sleep During Audio Activity", isOn: AppOveralDataManager.manager.settingsPhoneSleepPrevent())
                return cell
            } else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "Disable Auto-Playback", isOn: AppOveralDataManager.manager.settingsDisableAutoPlayback())
                return cell
            }  else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "After Rating Go to Next Item", isOn: AppOveralDataManager.manager.settingsGotoNextItemAfterRating())
                return cell
            } else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithoutIcon") as! SettingsCellWithoutIcon
                cell.configure(caption: "“Take a Break” Reminder")
                return cell
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "Pause Timer During Note Taking", isOn: AppOveralDataManager.manager.settingsTimerPauseDuringNote())
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "Pause Timer During Deliberate Practice", isOn: AppOveralDataManager.manager.settingsTimerPauseDuringImprove())
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.changeDisplayName()
            } else if indexPath.row == 1 {
                self.rateApp()
            } else if indexPath.row == 2 {
                self.shareModacityApp()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 2 {
                self.changePassword()
            } else if indexPath.row == 3 {
                self.openPremiumUpgrade()
            } else if indexPath.row == 4 {
                self.performSegue(withIdentifier: "sid_subscription_terms", sender: nil)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 4 {
                self.openBreakReminderSettingsPage()
            }
        }
        
    }
    
    func changeDisplayName() {
        let alertController = UIAlertController(title: nil, message: "Update your name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter your name"
            textField.autocapitalizationType = .words
            textField.text = MyProfileLocalManager.manager.me?.displayName()
        }
        alertController.addAction(UIAlertAction(title: "Update", style: .default, handler: { (alertAction) in
            if let fields = alertController.textFields {
                if let newName = fields[0].text {
                    if newName != "" {
                        MyProfileRemoteManager.manager.updateDisplayName(to: newName)
                    }
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changePassword() {
        self.performSegue(withIdentifier: "sid_change_password", sender: nil)
    }
    
    func rateApp() {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + AppConfig.appIdOnAppStore) else {
            return
        }
        guard #available(iOS 10, *) else {
            UIApplication.shared.openURL(url)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func shareModacityApp() {
        //asdasdasd REFACTOR ME!!! this is duplicate code from About menu screen!!!
        let textString:String = "I practice with Modacity - Self-recording, MetroDrone, Timers, Deliberate Practice. You can too!\n"
        
        let stringWithLink:String = "https://itunes.apple.com/us/app/modacity-pro-music-practice/id1351617981?ls=1&mt=8"
        
        let activityController = UIActivityViewController(activityItems: [textString, stringWithLink], applicationActivities:nil)
        
        activityController.completionWithItemsHandler = { (nil, completed, _, error)
            in
            if completed {
                ModacityAnalytics.LogStringEvent("Shared Modacity App! Yay!")
            } else {
                ModacityAnalytics.LogStringEvent("Canceled App Share")
            }
        }
        present(activityController, animated: true)
    }
    
    func openBreakReminderSettingsPage() {
        self.performSegue(withIdentifier: "sid_take_break", sender: nil)
    }
}

extension SettingsViewController: SettingsCellWithSwitchDelegate {
    func onSwitchValueChanged(forCaption: String?) {
        if "Prevent Phone Sleep During Audio Activity" == forCaption {
            AppOveralDataManager.manager.changePhoneSleepPrevent()
            self.tableViewSettings.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
        } else if "Disable Auto-Playback" == forCaption {
            AppOveralDataManager.manager.changeDisableAutoPlayback()
            self.tableViewSettings.reloadRows(at: [IndexPath(row: 1, section: 2)], with: .none)
        } else if "Pause Timer During Note Taking" == forCaption {
            AppOveralDataManager.manager.changeSettingsTimerPauseDuringNote()
            self.tableViewSettings.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
        } else if "Pause Timer During Deliberate Practice" == forCaption {
            AppOveralDataManager.manager.changeSettingsTimerPauseDuringImprove()
            self.tableViewSettings.reloadRows(at: [IndexPath(row: 1, section: 3)], with: .none)
        } else if "After Rating Go to Next Item" == forCaption {
            AppOveralDataManager.manager.changeGotoNextItemAfterRating()
            self.tableViewSettings.reloadRows(at: [IndexPath(row:2, section: 2)], with: .none)
        }
    }
}

// MARK:- Premium upgrade
extension SettingsViewController {
    func openPremiumUpgrade() {
        if PremiumDataManager.manager.isPremiumUnlocked() {
            ModacityAnalytics.LogStringEvent("Settings - Manage Subscription")
            if let url = URL(string:"itms-apps://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions") {
                if #available(iOS 10.0, *) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.open(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!, options: [:], completionHandler: nil)
                    }
                } else {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    } else {
                        UIApplication.shared.openURL(URL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")!)
                    }
                }
            }
        } else {
            ModacityAnalytics.LogStringEvent("Settings - Pressed Upgrade")
            let controller = UIStoryboard(name: "premium", bundle: nil).instantiateViewController(withIdentifier: "PremiumUpgradeScene")
            self.present(controller, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: SettingsCellTextFieldDelegate {
    func settingsCellTextField(_ cell: SettingsCellTextField, changedValue: String) {
        if let value = Double(changedValue) {
            AppOveralDataManager.manager.saveTuningStandard(value)
        }
    }
}
