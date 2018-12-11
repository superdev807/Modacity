//
//  CreateAccountViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import GoogleSignIn
import MBProgressHUD

class CreateAccountViewController: ModacityParentViewController {

    @IBOutlet weak var spinnerFacebook: UIActivityIndicatorView!
    @IBOutlet weak var spinnerGoogle: UIActivityIndicatorView!
    @IBOutlet weak var labelWaiting: UILabel!
    @IBOutlet weak var spinnerProcessing: UIActivityIndicatorView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonEmailSignIn: UIButton!
    @IBOutlet weak var buttonSkip: UIButton!
    
    var switchFromGuest = false
    
    let waitingTimeLongLimit: Int = 5
    var waitingTimer: Timer? = nil
    
    var fromSignout = false
    
    private let viewModel = AuthViewModel()
    
    var loadingPanelView: LoadingPanelView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initControls()
        self.bindViewModel()
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if fromSignout || Authorizer.authorizer.isGuestLogin() {
            self.buttonSkip.isHidden = true
        } else {
            self.buttonSkip.isHidden = false
        }
    }
    
    func initControls() {
        
        self.spinnerFacebook.stopAnimating()
        self.spinnerGoogle.stopAnimating()
        self.spinnerProcessing.stopAnimating()
        self.labelWaiting.isHidden = true
        
        if Authorizer.authorizer.isGuestLogin() {
            self.buttonClose.isHidden = false
            self.buttonEmailSignIn.setTitle("Sign up with email", for: .normal)
            self.buttonSkip.isHidden = true
        } else {
            self.buttonClose.isHidden = true
            self.buttonEmailSignIn.setTitle("Sign in with email", for: .normal)
            self.buttonSkip.isHidden = false
        }
        
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "authorizing") { (_, _, value) in
            if let value = value as? AuthorizingStatus {
                switch value {
                case .signup:
                    self.view.isUserInteractionEnabled = false
                case .google:
                    self.view.isUserInteractionEnabled = false
                    self.spinnerGoogle.startAnimating()
                case .facebook:
                    self.view.isUserInteractionEnabled = false
                    self.spinnerFacebook.startAnimating()
                case .succeeded:
                    self.openHome()
                case .guestSucceeded:
                    self.processGuestLoginFinished()
                default:
                    self.view.isUserInteractionEnabled = true
                    self.spinnerGoogle.stopAnimating()
                    self.spinnerFacebook.stopAnimating()
                }
            }
        }
        
        self.viewModel.subscribe(to: "authorizeError") { (_, _, value) in
            if let error = value as? String {
                if error == "FACEBOOK ACCOUNT LINKED" {
                    self.processFacebookAccountLinkingError()
                } else if error == "Google Account Linked" {
                    self.processGoogleAccountLinkingError()
                } else {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
                }
            }
        }
    }
    
    func processFacebookAccountLinkingError() {
        let alertController = UIAlertController(title: nil, message: "You have already joined to Modacity with your Facebook account. Do you want to continue with your existing account and restore your practice data from it?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (_) in
            self.switchFromGuest = true
            self.viewModel.facebookContinue()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.viewModel.facebookLogout()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func processGoogleAccountLinkingError() {
        let alertController = UIAlertController(title: nil, message: "You have already joined to Modacity with your Google account. Do you want to continue with your existing account and restore your practice data from it?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (_) in
            self.switchFromGuest = true
            self.viewModel.googleContinue()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.viewModel.googleLogout()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func processGuestLoginFinished() {
//        AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Your account has been successfully set!", handler: { (_) in
            NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationGuestAccountSwitched))
            self.navigationController?.dismiss(animated: true, completion: nil)
//        })
    }
    
    func openHome() {
        self.spinnerProcessing.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(showHomePage), name: AppConfig.NotificationNames.appNotificationHomePageValuesLoaded, object: nil)
        self.waitingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(waitingTimeLongLimit), target: self, selector: #selector(showWaitingLabel), userInfo: nil, repeats: false)
        AppOveralDataManager.manager.viewModel = HomeViewModel()
        AppOveralDataManager.manager.viewModel!.prepareValues()
    }
    
    @objc func showHomePage() {
        if let timer = self.waitingTimer {
            timer.invalidate()
            self.waitingTimer = nil
        }
        
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.spinnerGoogle.stopAnimating()
            self.spinnerFacebook.stopAnimating()
            self.spinnerProcessing.stopAnimating()
            NotificationCenter.default.removeObserver(self, name: AppConfig.NotificationNames.appNotificationHomePageValuesLoaded, object: nil)
            
            if self.switchFromGuest {
                NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationGuestAccountSwitched))
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @objc func showWaitingLabel() {
        self.labelWaiting.isHidden = false
        self.waitingTimer!.invalidate()
        self.waitingTimer = nil
    }
    
    @IBAction func onClose(_ sender: Any) {
        NotificationCenter.default.post(name: AppConfig.NotificationNames.appNotificationGuestSignUpCanceled, object: nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSkip(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Authorizer.authorizer.guestLogin { (error) in
            if let _ = error {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Sorry, we have encountered problems.  Please try again later")
                }
            } else {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.openHome()
                }
            }
        }
    }
    
}

extension CreateAccountViewController {     // actions
    
    @IBAction func onCreateAccount(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Create Account w/ Email")
        
        if self.processInputValidation() {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func onFacebook(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Facebook Login")
        self.view.endEditing(true)
        
        if Authorizer.authorizer.isGuestLogin() {
            self.viewModel.fbGuestLogin(controller: self)
        } else {
            self.viewModel.fbLogin(controller: self)
        }
    }
    
    @IBAction func onGoogle(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed Google Login")
        self.view.endEditing(true)
        
        self.viewModel.googleLogin()
    }
    
    @IBAction func onSignin(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Pressed 'Sign In for Existing Account'")
        self.performSegue(withIdentifier: "sid_signin", sender: nil)
    }
    
    @IBAction func onEditingDidBeginOnFields(_ sender: UITextField) {
    }
    
    @IBAction func onEditingDidEndOnFields(_ sender: UITextField) {
    }
    
    func processInputValidation() -> Bool {
        return true
    }
}

extension CreateAccountViewController: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
}

extension CreateAccountViewController {
    func startSynchronize() {
        let loadingView = LoadingPanelView()
        self.view.addSubview(loadingView)
        loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        loadingView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.loadingPanelView = loadingView
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSyncStatus), name: AppConfig.NotificationNames.appNotificationSyncStatusUpdated, object: nil)
    }
    
    @objc func refreshSyncStatus() {
        if let view = self.loadingPanelView {
            view.show()
        }
    }
}
