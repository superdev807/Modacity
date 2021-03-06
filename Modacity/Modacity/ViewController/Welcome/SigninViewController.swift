//
//  SigninViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class SigninViewController: ModacityParentViewController {

    @IBOutlet weak var viewEmailAddressContainer: UIView!
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var imageViewIconEmail: UIImageView!
    
    @IBOutlet weak var viewPasswordContainer: UIView!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var imageViewIconPassword: UIImageView!
    
    @IBOutlet weak var spinerSignIn: UIActivityIndicatorView!
    @IBOutlet weak var spinerCreateAccount: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonCreateAnAccount: UIButton!
    
    @IBOutlet weak var labelWaiting: UILabel!
    @IBOutlet weak var spinnerProcessing: UIActivityIndicatorView!
    
    @IBOutlet weak var viewSignIn: UIView!
    @IBOutlet weak var buttonForgotPassword: UIButton!
    
    let waitingTimeLongLimit: Int = 5
    var waitingTimer: Timer? = nil
    
    private let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initControls()
        self.bindViewModel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_reset_password" {
            let controller = segue.destination as! ResetPasswordViewController
            controller.deliveryEmailAddress = self.textfieldEmailAddress.text ?? ""
        }
    }
    
    func initControls() {
        
        self.viewEmailAddressContainer.styling(cornerRadius: AppConfig.UI.AppUIValues.viewPanelCornerRadius, borderColor: AppConfig.UI.AppColors.inputContainerBorderColor, borderWidth: AppConfig.UI.AppUIValues.viewPanelBorderWidth)
        self.viewPasswordContainer.styling(cornerRadius: AppConfig.UI.AppUIValues.viewPanelCornerRadius, borderColor: AppConfig.UI.AppColors.inputContainerBorderColor, borderWidth: AppConfig.UI.AppUIValues.viewPanelBorderWidth)
        
        self.buttonCreateAnAccount.styling(cornerRadius: AppConfig.UI.AppUIValues.viewPanelCornerRadius)
        
        self.imageViewIconEmail.image = UIImage(named: "icon_email")?.withRenderingMode(.alwaysTemplate)
        self.imageViewIconEmail.tintColor = AppConfig.UI.AppColors.placeholderIconColorGray
        self.imageViewIconPassword.image = UIImage(named: "icon_password")?.withRenderingMode(.alwaysTemplate)
        self.imageViewIconPassword.tintColor = AppConfig.UI.AppColors.placeholderIconColorGray
        
        self.textfieldEmailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.placeholderTextColorGray])
        self.textfieldPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.placeholderTextColorGray])
        
        self.spinerCreateAccount.stopAnimating()
        self.spinerSignIn.stopAnimating()
        
        self.spinnerProcessing.stopAnimating()
        self.labelWaiting.isHidden = true
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "authorizing") { (_, _, value) in
            if let value = value as? AuthorizingStatus {
                switch value {
                case .signin:
                    self.view.isUserInteractionEnabled = false
                    self.spinerSignIn.startAnimating()
                case .signup:
                    self.view.isUserInteractionEnabled = false
                    self.spinerCreateAccount.startAnimating()
                case .succeeded:
                    self.openHome()
                case .guestSignupFinished:
                    self.guestSignupFinished()
                default:
                    self.view.isUserInteractionEnabled = true
                    self.spinerSignIn.stopAnimating()
                    self.spinerCreateAccount.stopAnimating()
                }
            }
        }
        
        self.viewModel.subscribe(to: "authorizeError") { (_, _, value) in
            if let error = value as? String {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
            }
        }
        
    }
    
    func guestSignupFinished() {
        self.textfieldEmailAddress.text = ""
        self.textfieldPassword.text = ""
        
//        AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Your account has been successfully set!", handler: { (_) in
            NotificationCenter.default.post(Notification(name: AppConfig.NotificationNames.appNotificationGuestAccountSwitched))
            self.navigationController?.dismiss(animated: true, completion: nil)
//        })
    }
    
    func openHome() {
        self.textfieldEmailAddress.text = ""
        self.textfieldPassword.text = ""
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
            self.spinerSignIn.stopAnimating()
            self.spinerCreateAccount.stopAnimating()
            self.spinnerProcessing.stopAnimating()
            NotificationCenter.default.removeObserver(self, name: AppConfig.NotificationNames.appNotificationHomePageValuesLoaded, object: nil)
            let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func showWaitingLabel() {
        self.labelWaiting.isHidden = false
        self.waitingTimer!.invalidate()
        self.waitingTimer = nil
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SigninViewController {     // actions
    
    @IBAction func onCreateAccount(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            let email = (self.textfieldEmailAddress.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if Authorizer.authorizer.isGuestLogin() {
                self.viewModel.guestCreateAccount(email: email, password: self.textfieldPassword.text ?? "")
            } else {
                self.viewModel.createAccount(email: email, password: self.textfieldPassword.text ?? "")
                ModacityAnalytics.LogStringEvent("Created Email Account", extraParamName: "address", extraParamValue: email)
            }
        }
    }
    
    @IBAction func onSignin(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            
            let email = (self.textfieldEmailAddress.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if Authorizer.authorizer.isGuestLogin() {
                self.viewModel.guestSignIn(email: email, password: self.textfieldPassword.text ?? "")
            } else {
                self.viewModel.signin(email: email, password: self.textfieldPassword.text ?? "")
            }
            ModacityAnalytics.LogStringEvent("Login Email", extraParamName: "address", extraParamValue:email)
        }
    }
    
    @IBAction func onEditingDidBeginOnFields(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditingDidEndOnFields(_ sender: UITextField) {
        
    }
    
    func processInputValidation() -> Bool {
        
        let email = (self.textfieldEmailAddress.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if "" == email {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter email address.")
            return false
        }
        
        if !email.isValidEmail() {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a valid email address.")
            return false
        }
        
        if email.hasSuffix(".con") {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Email address ending in .con is not valid.")
            return false
        }
        
        if "" == self.textfieldPassword.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a password.")
            return false
        }
        
        return true
    }

}
