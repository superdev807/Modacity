//
//  ViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    let waitingTimeLongLimit: Int = 5
    
    @IBOutlet weak var labelWait: UILabel!
    var waitingTimer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.labelWait.isHidden = true
        if !AppOveralDataManager.manager.beenTutorialRead() {
            self.openTutorial()
        } else {
            if Authorizer.authorizer.isAuthorized() {
                self.openHome()
                DispatchQueue.global(qos: .background).async {
                    MyProfileRemoteManager.manager.configureMyProfileListener()
                }
            } else {
                self.openLogin()
            }
        }
        MetrodroneParameters.instance.setTuningStandardA(Float(AppOveralDataManager.manager.tuningStandard()))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func openHome() {
        NotificationCenter.default.addObserver(self, selector: #selector(showHomePage), name: AppConfig.appNotificationHomePageValuesLoaded, object: nil)
        self.waitingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(waitingTimeLongLimit), target: self, selector: #selector(showWaitingLabel), userInfo: nil, repeats: false)
        AppOveralDataManager.manager.viewModel = HomeViewModel()
        AppOveralDataManager.manager.viewModel!.prepareValues()
    }
    
    @objc func openTutorial() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openLogin() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func showHomePage() {
        if let timer = self.waitingTimer {
            timer.invalidate()
            self.waitingTimer = nil
        }
        NotificationCenter.default.removeObserver(self, name: AppConfig.appNotificationHomePageValuesLoaded, object: nil)
        let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func showWaitingLabel() {
        self.labelWait.isHidden = false
        self.waitingTimer!.invalidate()
        self.waitingTimer = nil
    }
}

