//
//  SettingsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/27/18.
//  Copyright © 2018 crossover. All rights reserved.
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

class SettingsCellWithIcon: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelCaption: UILabel!
    
    func configure(icon: String, caption: String) {
        self.imageViewIcon.image = UIImage(named: icon)
        self.labelCaption.text = caption
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: AppConfig.appNotificationProfileUpdated, object: nil)
         AmplitudeTracker.LogStringEvent("Loaded Settings Screen")
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else if section == 1 {
            return 1
        }
//            return 3
//        } else if section == 2 {
//            return 3
//        } else {
            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "APP SETTINGS"
        }
        
        return ""
//        else if section == 2 {
//            return "NOTIFICATIONS"
//        } else {
//            return ""
//        }
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
            if indexPath.row < 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIconAndSubTitle") as! SettingsCellWithIconAndSubTitle
                if indexPath.row == 0 {
                    cell.configure(icon: "img_profile_placeholder", caption: "DISPLAY NAME", subTitle: MyProfileLocalManager.manager.me?.displayName() ?? "")
                    cell.accessoryType = .disclosureIndicator
                } else if indexPath.row == 1 {
                    cell.configure(icon: "icon_settings_email", caption: "EMAIL", subTitle: MyProfileLocalManager.manager.me?.email ?? "")
                    cell.accessoryType = .none
                } else if indexPath.row == 2 {
                    cell.configure(icon: "icon_settings_password", caption: "PASSWORD", subTitle: "Change Password")
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIcon") as! SettingsCellWithIcon
                cell.configure(icon: "icon_settings_star", caption: "Rate the App")
                return cell
            }
        } else if indexPath.section == 1 {
//            if indexPath.row == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithDropdown") as! SettingsCellWithDropdown
//                return cell
//            } else if indexPath.row == 1 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
//                cell.configure(caption: "Light Mode", isOn: false)
//                return cell
//            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.delegate = self
                cell.configure(caption: "Prevent phone sleep during audio activity", isOn: AppOveralDataManager.manager.settingsPhoneSleepPrevent())
                return cell
//            }
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
            cell.configure(caption: ["Email Notifications", "Push Notifications", "Star Rating Notifications"][indexPath.row], isOn: [false, true, true][indexPath.row])
            return cell
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
            } else if indexPath.row == 2 {
                self.changePassword()
            } else {
                self.rateApp()
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
}

extension SettingsViewController: SettingsCellWithSwitchDelegate {
    func onSwitchValueChanged(forCaption: String?) {
        if "Prevent phone sleep during audio activity" == forCaption {
            AppOveralDataManager.manager.changePhoneSleepPrevent()
            self.tableViewSettings.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        }
    }
}


