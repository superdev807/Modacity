//
//  SigninViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/22/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class SigninViewController: UIViewController {

    @IBOutlet weak var textfieldEmailAddress: UITextField!
    @IBOutlet weak var viewIndicatorEmailAddress: UIView!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var viewIndicatorPassword: UIView!
    @IBOutlet weak var spinerSignIn: UIActivityIndicatorView!
    
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
        self.viewIndicatorEmailAddress.backgroundColor = Color.white.alpha(0.5)
        self.viewIndicatorPassword.backgroundColor = Color.white.alpha(0.5)
        self.textfieldEmailAddress.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.5)])
        self.textfieldPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: Color.white.alpha(0.5)])
        self.spinerSignIn.stopAnimating()
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "authorizing") { (_, _, value) in
            if let value = value as? AuthorizingStatus {
                switch value {
                case .signin:
                    self.view.isUserInteractionEnabled = false
                    self.spinerSignIn.startAnimating()
                default:
                    self.view.isUserInteractionEnabled = true
                    self.spinerSignIn.stopAnimating()
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
        
//        _ = self.viewModel.authorizing.asObservable().subscribe { (event) in
//            if let value = event.element {
//                switch value {
//                case .signin:
//                    self.view.isUserInteractionEnabled = false
//                    self.spinerSignIn.startAnimating()
//                default:
//                    self.view.isUserInteractionEnabled = true
//                    self.spinerSignIn.stopAnimating()
//                }
//
//                if value == .succeeded {
//                    self.openHome()
//                }
//            }
//        }
        
//        _ = self.viewModel.authorizeError.asObservable().subscribe { (event) in
//            if let error = event.element {
//                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
//            }
//        }
        
    }
    
    func openHome() {
        self.textfieldEmailAddress.text = ""
        self.textfieldPassword.text = ""
        let home = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
        self.navigationController?.pushViewController(home, animated: true)
    }
}


extension SigninViewController {     // actions
    
    @IBAction func onCreateAccount(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSignin(_ sender: Any) {
        if self.processInputValidation() {
            self.view.endEditing(true)
            self.viewModel.signin(email: self.textfieldEmailAddress.text ?? "", password: self.textfieldPassword.text ?? "")
        }
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
