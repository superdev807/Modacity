//
//  AboutViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/27/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    
    let icons = ["icon_share_white", "icon_settings_twitter", "icon_settings_facebook", "icon_settings_web"]
    let captions = ["Share the App", "Modacity on Twitter", "Modacity on Facebook", "www.modacity.co"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onMenu() {
        self.sideMenuController?.showLeftViewAnimated()
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
            imageView.alpha = 0.5
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
            UIApplication.shared.open(URL(string:AppConfig.appConfigShareTheAppUrlLink)!, options: [:], completionHandler: nil)
        } else if indexPath.row == 1 {
            UIApplication.shared.open(URL(string:AppConfig.appConfigTwitterLink)!, options: [:], completionHandler: nil)
        } else if indexPath.row == 2 {
            UIApplication.shared.open(URL(string:AppConfig.appConfigFacebookLink)!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string:AppConfig.appConfigWebsiteLink)!, options: [:], completionHandler: nil)
        }
    }
}
