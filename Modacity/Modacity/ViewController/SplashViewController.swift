//
//  ViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/8/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        AppOveralDataManager.manager.saveStreak()
        if !AppOveralDataManager.manager.beenTutorialRead() {
            self.openTutorial()
        } else {
            if Authorizer.authorizer.isAuthorized() {
                MyProfileRemoteManager.manager.configureMyProfileListener()
                self.openHome()
            } else {
                self.openLogin()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func openHome() {
        let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func openTutorial() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openLogin() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

