//
//  ResetPasswordViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class ResetPasswordViewController: ModacityParentViewController {

    @IBOutlet weak var viewEmailAddressContainer: UIView!
    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var imageViewIconEmail: UIImageView!
    
    @IBOutlet weak var spinerResetPassword: UIActivityIndicatorView!
    @IBOutlet weak var buttonResetPassword: UIButton!
    
    var deliveryEmailAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initControls() {
        
        self.viewEmailAddressContainer.styling(cornerRadius: AppConfig.UI.AppUIValues.viewPanelCornerRadius, borderColor: AppConfig.UI.AppColors.inputContainerBorderColor, borderWidth: AppConfig.UI.AppUIValues.viewPanelBorderWidth)
        
        self.buttonResetPassword.styling(cornerRadius: AppConfig.UI.AppUIValues.viewPanelCornerRadius)
        
        self.imageViewIconEmail.image = UIImage(named: "icon_email")?.withRenderingMode(.alwaysTemplate)
        self.imageViewIconEmail.tintColor = AppConfig.UI.AppColors.placeholderIconColorGray
        
        self.textfieldEmailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.placeholderTextColorGray])
        
        self.spinerResetPassword.stopAnimating()
        
        self.textfieldEmailAddress.text = self.deliveryEmailAddress
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ResetPasswordViewController {     // actions
    
    @IBAction func onResetPassword(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            ModacityAnalytics.LogStringEvent("Reset Password", extraParamName: "email", extraParamValue: self.textfieldEmailAddress.text ?? "")
            self.view.isUserInteractionEnabled = false
            self.spinerResetPassword.startAnimating()
            Authorizer.authorizer.resetPassword(email: self.textfieldEmailAddress.text ?? "") { (errorString) in
                self.view.isUserInteractionEnabled = true
                self.spinerResetPassword.stopAnimating()
                if let error = errorString {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
                } else {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "We've successfully sent you reset password email.")
                }
            }
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
        
        return true
    }

}
