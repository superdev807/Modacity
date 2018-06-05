//
//  LeftMenuViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import Intercom

class LeftMenuViewController: UIViewController {
    
//    let menuTitles = ["Home", "Metrodrone", "Playlists", "Recordings", "Pro Boost", "Settings", "Feedback", "About Us", "Sign Out"]
//    let menuIcons = ["icon_menu_home", "icon_menu_metrodrone", "icon_menu_playlist", "icon_menu_recordings", "icon_menu_ask", "icon_menu_settings", "icon_menu_feedback", "icon_menu_about", "icon_menu_signout"]

    let menuTitles = ["Home", "Metrodrone", "Recordings", "Settings", "Feedback", "About Us", "Sign Out"]
    let menuIcons = ["icon_menu_home", "icon_menu_metrodrone", "icon_menu_mic", "icon_menu_settings", "icon_menu_feedbacks_new", "icon_menu_about", "icon_menu_signout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = Color.clear
    }

    func signout() {
        let alert = UIAlertController(title: nil, message: "Are you sure to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.processSignout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func processSignout() {
        AppOveralDataManager.manager.signout()
        
        if let nav = self.sideMenuController?.navigationController {
            for controller in nav.viewControllers {
                if controller is CreateAccountViewController {
                    nav.popToViewController(controller, animated: true)
                    return
                }
            }
            
            var controllers = nav.viewControllers
            let login = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
            controllers.insert(login, at: 0)
            nav.viewControllers = controllers
            nav.popToViewController(login, animated: true)
        }
    }
    
}

extension LeftMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell")
        let label = cell!.viewWithTag(11) as! UILabel
        label.text = menuTitles[indexPath.row]
        let icon = cell!.viewWithTag(10) as! UIImageView
        icon.image = UIImage(named: menuIcons[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.frame.size.height - 20) / CGFloat(menuTitles.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let menuTitles = ["Home", "Metrodrone", "Recordings", "Settings", "Feedback", "About Us", "Sign Out"]
//        let menuIcons = ["icon_menu_home", "icon_menu_metrodrone", "icon_menu_recordings", "icon_menu_settings", "icon_menu_feedback", "icon_menu_about", "icon_menu_signout"]
        if indexPath.row == 6 {
            self.signout()
        } else if indexPath.row == 0 {
            if self.sideMenuController?.rootViewController is TabBarViewController {
                let tabbarController = self.sideMenuController?.rootViewController as! TabBarViewController
                if tabbarController.selectedIndex != 0 {
                    tabbarController.onTabHome()
                }
            } else {
                let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                tabBarViewController.startingTabIndex = 0
                self.sideMenuController?.rootViewController = tabBarViewController
            }
            
            self.sideMenuController?.hideLeftViewAnimated()
        } else if indexPath.row == 1 {
            if !(self.sideMenuController?.rootViewController is MetrodoneViewController) {
                let controllerId = (AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in) ? "MetrodoneViewControllerSmallSizes" : "MetrodoneViewController"
                let controller = UIStoryboard(name: "metrodone", bundle: nil).instantiateViewController(withIdentifier: controllerId) as! MetrodoneViewController
                self.sideMenuController?.rootViewController = controller
            }
            self.sideMenuController?.hideLeftViewAnimated()
//        } else if indexPath.row == 2 {
//            if self.sideMenuController?.rootViewController is TabBarViewController {
//                let tabbarController = self.sideMenuController?.rootViewController as! TabBarViewController
//                if tabbarController.selectedIndex != 1 {
//                    tabbarController.onTabPlaylist()
//                }
//            } else {
//                let tabBarViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//                tabBarViewController.startingTabIndex = 1
//                self.sideMenuController?.rootViewController = tabBarViewController
//            }
//
//            self.sideMenuController?.hideLeftViewAnimated()
        } else if indexPath.row == 2 {
            
            if !(self.sideMenuController?.rootViewController is RecordingViewController) {
                let controller = UIStoryboard(name: "recording", bundle: nil).instantiateViewController(withIdentifier: "RecordingViewController") as! RecordingViewController
                self.sideMenuController?.rootViewController = controller
            }
            self.sideMenuController?.hideLeftViewAnimated()
            
        } else if indexPath.row == 3 {
            if (self.sideMenuController?.rootViewController is UINavigationController)
                && (self.sideMenuController?.rootViewController as! UINavigationController).viewControllers[0] is SettingsViewController {
                
            } else {
                let controller = UIStoryboard(name:"settings", bundle:nil).instantiateViewController(withIdentifier: "settingsscene")
                self.sideMenuController?.rootViewController = controller
            }
            self.sideMenuController?.hideLeftViewAnimated()
        } else if indexPath.row == 4 {
            /*
            if (self.sideMenuController?.rootViewController is UINavigationController)
                && (self.sideMenuController?.rootViewController as! UINavigationController).viewControllers[0] is FeedbackRootViewController {
                let feedbackRootViewController = (self.sideMenuController?.rootViewController as! UINavigationController).viewControllers[0] as! FeedbackRootViewController
                if feedbackRootViewController.pageUIMode == 0 {
                    feedbackRootViewController.changePageUIMode(to: 1)
                }
            } else {
                // open feedback
                let controller = UIStoryboard(name:"feedback", bundle:nil).instantiateViewController(withIdentifier: "feedbackscene") as! UINavigationController
                let feedbackRootViewController = controller.viewControllers[0] as! FeedbackRootViewController
                feedbackRootViewController.pageUIMode = 1
                self.sideMenuController?.rootViewController = controller
            }
 */
            let foo :ICMUserAttributes = ICMUserAttributes.init()
            foo.customAttributes = ["locationfoo" : "feedback"]
            Intercom.updateUser(foo)
            Intercom.presentMessageComposer()
            
            self.sideMenuController?.hideLeftViewAnimated()
        } else if indexPath.row == 5 {
            if (self.sideMenuController?.rootViewController is UINavigationController)
                && (self.sideMenuController?.rootViewController as! UINavigationController).viewControllers[0] is AboutViewController {
            } else {
                let controller = UIStoryboard(name:"about", bundle:nil).instantiateViewController(withIdentifier: "aboutscene")
                self.sideMenuController?.rootViewController = controller
            }
            self.sideMenuController?.hideLeftViewAnimated()
        }
    }
}
