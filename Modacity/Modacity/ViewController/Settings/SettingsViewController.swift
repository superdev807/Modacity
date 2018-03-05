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

class SettingsCellWithSwitch: UITableViewCell {
    
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var buttonSwitch: UIButton!
    
    func configure(caption: String, isOn: Bool) {
        self.labelCaption.text = caption
        self.buttonSwitch.isSelected = isOn
    }
}

class SettingsCellWithDropdown: UITableViewCell {
    
    @IBOutlet weak var labelStorageLimit: UILabel!
    
    
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else if section == 1 {
            return "APP SETTINGS"
        } else if section == 2 {
            return "NOTIFICATIONS"
        } else {
            return ""
        }
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
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithDropdown") as! SettingsCellWithDropdown
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithSwitch") as! SettingsCellWithSwitch
                cell.configure(caption: "Light Mode", isOn: false)
                return cell
            }
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
}


