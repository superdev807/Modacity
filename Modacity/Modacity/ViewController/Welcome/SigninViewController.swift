//
//  SigninViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {

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
    
    func openHome() {
        self.textfieldEmailAddress.text = ""
        self.textfieldPassword.text = ""
        self.spinnerProcessing.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(showHomePage), name: AppConfig.appNotificationHomePageValuesLoaded, object: nil)
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
            NotificationCenter.default.removeObserver(self, name: AppConfig.appNotificationHomePageValuesLoaded, object: nil)
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
            self.viewModel.createAccount(email: self.textfieldEmailAddress.text ?? "", password: self.textfieldPassword.text ?? "")
            ModacityAnalytics.LogStringEvent("Created Email Account", extraParamName: "address", extraParamValue: self.textfieldEmailAddress)
        }
    }
    
    @IBAction func onSignin(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            self.viewModel.signin(email: self.textfieldEmailAddress.text ?? "", password: self.textfieldPassword.text ?? "")
            ModacityAnalytics.LogStringEvent("Login Email", extraParamName: "address", extraParamValue: self.textfieldEmailAddress)
        }
    }
    
    @IBAction func onEditingDidBeginOnFields(_ sender: UITextField) {
        
    }
    
    @IBAction func onEditingDidEndOnFields(_ sender: UITextField) {
        
    }
    
    func processInputValidation() -> Bool {
        if "" == self.textfieldEmailAddress.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter email address.")
            return false
        }
        
        if !self.textfieldEmailAddress.text!.isValidEmail() {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a valid email address.")
            return false
        }
        
        if "" == self.textfieldPassword.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a password.")
            return false
        }
        
        return true
    }

}
