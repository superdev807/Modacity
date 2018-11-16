//
//  ChangePasswordViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/10/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit


class ChangePasswordViewController: ModacityParentViewController {
    
    @IBOutlet weak var viewCurrentPasswordContainer: UIView!
    @IBOutlet weak var textfieldCurrentPassword: UITextField!
    @IBOutlet weak var viewNewPasswordContainer: UIView!
    @IBOutlet weak var textfieldNewPassword: UITextField!
    @IBOutlet weak var viewConfirmPasswordContainer: UIView!
    @IBOutlet weak var textfieldConfirmPassword: UITextField!
    @IBOutlet weak var buttonUpdatePassword: UIButton!
    @IBOutlet weak var spinnerProcessing: UIActivityIndicatorView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.viewCurrentPasswordContainer.layer.cornerRadius = 10
        self.textfieldCurrentPassword.attributedPlaceholder = NSAttributedString(string: "Current Password", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.7)])
        
        self.viewNewPasswordContainer.layer.cornerRadius = 10
        self.textfieldNewPassword.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.7)])
        
        self.viewConfirmPasswordContainer.layer.cornerRadius = 10
        self.textfieldConfirmPassword.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.7)])
        
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            self.constraintForHeaderImageViewHeight.constant = 88
        }
        
        self.spinnerProcessing.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onUpdatePassword(_ sender: Any) {
        if "" == self.textfieldCurrentPassword.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter your current password!")
            return
        }
        
        if "" == self.textfieldNewPassword.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please enter a new password!")
            return
        }
        
        if self.textfieldNewPassword.text != self.textfieldConfirmPassword.text {
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "New password does not match!")
        }
        
        self.startChangePassword()
    }
    
    func startChangePassword() {
        self.view.isUserInteractionEnabled = false
        self.spinnerProcessing.startAnimating()
        
        MyProfileRemoteManager.manager.updatePassword(current: self.textfieldCurrentPassword.text!, newPassword: self.textfieldNewPassword.text!) { (err) in
            self.view.isUserInteractionEnabled = true
            self.spinnerProcessing.stopAnimating()
            if let error = err {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
            } else {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Successfully updated your password!", handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
}
