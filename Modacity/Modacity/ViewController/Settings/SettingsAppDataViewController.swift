//
//  SettingsAppDataViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 10/30/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsAppDataViewController: ModacityParentViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableViewSettings.tableFooterView = UIView()
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        ModacityAnalytics.LogStringEvent("Loaded App Data Screen")
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsAppDataViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCellWithIcon") as! SettingsCellWithIcon
        if indexPath.row == 0 {
            cell.configure(icon: "icon_sync", caption: "Refresh Practice Data (From Server)")
        } else {
            cell.configure(icon: "icon_clean_data", caption: "Erase All Practice Data")
        }
        cell.labelCaption.textColor = Color(hexString: "#ffffff")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.sync()
        } else if indexPath.row == 1 {
            let alert = UIAlertController(title: "Confirmation", message: "This will erase all your practice items, playlists, history, recordings, and other data. You cannot undo this operation. Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Erase", style: .default, handler: { (_) in
                self.clean()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension SettingsAppDataViewController {
    
    func sync() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Synchronizing practice items..."
        DispatchQueue.global(qos: .background).async {
            PracticeItemRemoteManager.manager.fullSync {
                DispatchQueue.main.async {hud.label.text = "Synchronizing playlist items..."}
                PlaylistRemoteManager.manager.fullSync(completion: {
                    DispatchQueue.main.async {hud.label.text = "Synchronizing deliberate practices..."}
                    DeliberatePracticeRemoteManager.manager.fullSync {
                        DispatchQueue.main.async {hud.label.text = "Synchronizing overall data..."}
                        OverallDataRemoteManager.manager.fullSync(completion: {
                            DispatchQueue.main.async { hud.label.text = "Synchronizing goals..." }
                            GoalsRemoteManager.manager.fullSync(completion: {
                                DispatchQueue.main.async { hud.label.text = "Synchronzing practice data..." }
                                DailyPracticingRemoteManager.manager.syncPlaylistPracticingData {
                                    DailyPracticingRemoteManager.manager.syncPracticeData {
                                        DispatchQueue.main.async {
                                            hud.hide(animated: true)
                                            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Sync Complete - You have the latest data")
                                        }
                                    }
                                }
                            })
                        })
                    }
                })
            }
        }
    }
    
    func clean() {
        ModacityAnalytics.LogStringEvent("Settings-Confirmed-Erase")
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Clean goals data..."
        GoalsRemoteManager.manager.eraseGoals {
            DispatchQueue.main.async {hud.label.text = "Clean practicing data..."}
            DailyPracticingRemoteManager.manager.erasePracticingData {
                DailyPracticingRemoteManager.manager.erasePlaylistPraciticingData {
                    OverallDataRemoteManager.manager.eraseData {
                        DispatchQueue.main.async {hud.label.text = "Clean practice items..."}
                        PracticeItemRemoteManager.manager.eraseData {
                            DispatchQueue.main.async {hud.label.text = "Clean practice items..."}
                            DeliberatePracticeRemoteManager.manager.eraseDeliberatePractices {
                                DispatchQueue.main.async {hud.label.text = "Clean playlist data..."}
                                PlaylistRemoteManager.manager.eraseData {
                                    DispatchQueue.main.async {
                                        hud.hide(animated: true)
                                        AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Clean completed")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
