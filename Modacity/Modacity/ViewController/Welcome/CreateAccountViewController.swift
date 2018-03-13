//
//  CreateAccountViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import GoogleSignIn

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var viewIndicatorEmailAddress: UIView!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var viewIndicatorPassword: UIView!
    @IBOutlet weak var spinnerCreateAccount: UIActivityIndicatorView!
    @IBOutlet weak var spinnerFacebook: UIActivityIndicatorView!
    @IBOutlet weak var spinnerGoogle: UIActivityIndicatorView!
    
    private let viewModel = AuthViewModel()
    
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
    
    func initControls() {
        self.spinnerCreateAccount.stopAnimating()
        self.spinnerFacebook.stopAnimating()
        self.spinnerGoogle.stopAnimating()
        self.viewIndicatorEmailAddress.backgroundColor = Color.white.alpha(0.5)
        self.viewIndicatorPassword.backgroundColor = Color.white.alpha(0.5)
        self.textfieldEmailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.5)])
        self.textfieldPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.5)])
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "authorizing") { (_, _, value) in
            if let value = value as? AuthorizingStatus {
                switch value {
                case .signup:
                    self.view.isUserInteractionEnabled = false
                    self.spinnerCreateAccount.startAnimating()
                case .google:
                    self.view.isUserInteractionEnabled = false
                    self.spinnerGoogle.startAnimating()
                case .facebook:
                    self.view.isUserInteractionEnabled = false
                    self.spinnerFacebook.startAnimating()
                default:
                    self.view.isUserInteractionEnabled = true
                    self.spinnerCreateAccount.stopAnimating()
                    self.spinnerGoogle.stopAnimating()
                    self.spinnerFacebook.stopAnimating()
                }
                
                if value == .succeeded {
                    self.openHome()
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
        let home = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
        self.navigationController?.pushViewController(home, animated: true)
    }
}

extension CreateAccountViewController {     // actions
    
    @IBAction func onCreateAccount(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            self.viewModel.createAccount(email: self.textfieldEmailAddress.text ?? "", password: self.textfieldPassword.text ?? "")
        }
    }
    
    @IBAction func onFacebook(_ sender: Any) {
        self.view.endEditing(true)
        self.viewModel.fbLogin(controller: self)
    }
    
    @IBAction func onGoogle(_ sender: Any) {
        self.view.endEditing(true)
        self.viewModel.googleLogin()
    }
    
    @IBAction func onSignin(_ sender: Any) {
        self.performSegue(withIdentifier: "sid_signin", sender: nil)
    }
    
    @IBAction func onEditingDidBeginOnFields(_ sender: UITextField) {
        if sender == self.textfieldEmailAddress {
            self.viewIndicatorEmailAddress.backgroundColor = Color.white
        } else if sender == self.textfieldPassword {
            self.viewIndicatorPassword.backgroundColor = Color.white
        }
    }
    
    @IBAction func onEditingDidEndOnFields(_ sender: UITextField) {
        if sender == self.textfieldEmailAddress {
            self.viewIndicatorEmailAddress.backgroundColor = Color.white.alpha(0.5)
        } else if sender == self.textfieldPassword {
            self.viewIndicatorPassword.backgroundColor = Color.white.alpha(0.5)
        }
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

extension CreateAccountViewController: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
}
