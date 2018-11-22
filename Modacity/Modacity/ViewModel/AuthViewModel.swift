//
//  AuthViewModel.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

enum AuthorizingStatus {
    case none
    case signup
    case signin
    case facebook
    case google
    case succeeded
    case guestSucceeded
    case error
}

class AuthViewModel: ViewModel {
    
    var authorizing: AuthorizingStatus = .none {
        didSet {
            if let callback = self.callBacks["authorizing"] {
                callback(.simpleChange, oldValue, authorizing)
            }
        }
    }
    var authorizeError: String? = nil {
        didSet {
            if let callback = self.callBacks["authorizeError"] {
                callback(.simpleChange, oldValue, authorizeError)
            }
        }
    }
    
    func createAccount(email: String, password: String) {
        self.authorizing = .signup
        Authorizer.authorizer.signup(email: email, password: password) { (err) in
            if err == nil {
                self.authorizing = .succeeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func signin(email: String, password: String) {
        authorizing = .signin
        Authorizer.authorizer.signin(email: email, password: password) { (err) in
            if err == nil {
                self.authorizing = .succeeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func fbGuestLogin(controller: UIViewController) {
        authorizing = .facebook
        Authorizer.authorizer.facebookLoginForGuestUser(controller: controller) { (err) in
            if err == nil {
                self.authorizing = .guestSucceeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func fbLogin(controller: UIViewController) {
        authorizing = .facebook
        Authorizer.authorizer.facebookLogin(controller: controller) { (err) in
            if err == nil {
                self.authorizing = .succeeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func facebookLogout() {
        Authorizer.authorizer.facebookLogout()
    }
    
    func facebookContinue() {
        authorizing = .facebook
        AppOveralDataManager.manager.signout(with3rdPartyLogout: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            Authorizer.authorizer.facebookContinue { (err) in
                if let error = err {
                    self.authorizing = .error
                    self.authorizeError = error
                } else {
                    self.authorizing = .succeeded
                }
            }
        }
    }
    
    func googleGuestLogin() {
        authorizing = .google
        Authorizer.authorizer.googleLogin() { (err) in
            if err == nil {
                self.authorizing = .guestSucceeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func googleLogin() {
        authorizing = .google
        Authorizer.authorizer.googleLogin() { (err) in
            if err == nil {
                self.authorizing = .succeeded
            } else {
                self.authorizing = .error
                self.authorizeError = err
            }
        }
    }
    
    func googleLogout() {
        Authorizer.authorizer.googleLogout()
    }
    
    func googleContinue() {
        authorizing = .google
        AppOveralDataManager.manager.signout(with3rdPartyLogout: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            Authorizer.authorizer.googleContinue { (err) in
                if let error = err {
                    self.authorizing = .error
                    self.authorizeError = error
                } else {
                    self.authorizing = .succeeded
                }
            }
        }
    }
}
