//
//  AboutViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/27/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class AboutViewController: ModacityParentViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelVersion: UILabel!
    
    let icons = ["icon_share_white", "icon_instagram", "icon_settings_twitter", "icon_settings_facebook", "icon_settings_web"]
    let captions = ["Share the App", "Modacity on Instagram", "Modacity on Twitter", "Modacity on Facebook", "www.modacity.co"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
         ModacityAnalytics.LogStringEvent("Loaded About Screen")
        // Do any additional setup after loading the view.
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"]  as? String {
            ModacityDebugger.debug(text)
        }
        self.labelVersion.text = self.version()
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version)(\(build))"
    }

    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    @IBAction func onAcknowledgement(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.Links.appConfigHomeUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigHomeUrlLink)!)
        }
    }
    
    @IBAction func onPrivacy(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.Links.appConfigPrivacyUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigPrivacyUrlLink)!)
        }
    }
    
    @IBAction func onTerms(_ sender: Any) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:AppConfig.Links.appConfigTermsUrlLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigTermsUrlLink)!)
        }
    }
    
    func shareModacityApp() {
        //asdasdasd REFACTOR ME!!!
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
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell")!
        let imageView = cell.viewWithTag(10) as! UIImageView
        imageView.image = UIImage(named:icons[indexPath.row])
        if indexPath.row == 0 {
            imageView.alpha = 0.4
        } else if indexPath.row == 1 {
            imageView.alpha = 0.3
        } else {
            imageView.alpha = 1
        }
        let labelCaption = cell.viewWithTag(11) as! UILabel
        labelCaption.text = captions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return max((tableView.frame.size.height - 40) / CGFloat(icons.count), 20)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            /*
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:AppConfig.appConfigShareTheAppUrlLink)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(URL(string:AppConfig.appConfigShareTheAppUrlLink)!)
            }*/
            
            
            //AppDelegate.
        } else if indexPath.row == 1 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:AppConfig.Links.appConfigInstagramLink)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigInstagramLink)!)
            }
        } else if indexPath.row == 2 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:AppConfig.Links.appConfigTwitterLink)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigTwitterLink)!)
            }
        } else if indexPath.row == 3 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:AppConfig.Links.appConfigFacebookLink)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigFacebookLink)!)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:AppConfig.Links.appConfigWebsiteLink)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string:AppConfig.Links.appConfigWebsiteLink)!)
            }
        }
    }
}
