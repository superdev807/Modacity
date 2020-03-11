//
//  Authorizer.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/22/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn

class Authorizer: NSObject {
    
    static let authorizer = Authorizer()
    
    let database = Database.database().reference()
    
    var completionCallbackForGoogleSignin: ((String?)->())?
    
    func isAuthorized() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func isGuestLogin() -> Bool {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                return true
            }
        }
        
        return false
    }
    
    func isEmailLogin() -> Bool {
        if let user = Auth.auth().currentUser {
            for userInfo in user.providerData {
                if userInfo.providerID == "facebook.com" {
                    return false
                } else if userInfo.providerID == "google.com" {
                    return false
                }
            }
            
            return true
        }
        
        return false
    }
    
    func guestLogin(completion: @escaping (String?) -> ()) {
        Auth.auth().signInAnonymously { (authDataResult, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                if let user = authDataResult?.user {
                    MyProfileRemoteManager.manager.createMyProfile(userId: user.uid,
                                                                   data: ["uid":user.uid,
                                                                          "guest":true,
                                                                          "created":"\(Date().timeIntervalSince1970)"])
                    
                    DispatchQueue.global(qos: .background).async {
                        MyProfileRemoteManager.manager.configureMyProfileListener()
                    }
                    completion(nil)
                }
            }
        }
    }
    
    func guestSignup(email: String, password: String, completion: @escaping (String?) -> ()) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (authDataResult, error) in
            if let error = error {
                let errorCode = UInt((error as NSError).code)
                if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                    completion("Account already registered to \(email)")
                } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                    completion("This email address is already in use with a different service.")
                } else {
                    completion(error.localizedDescription)
                }
            } else {
                if let user = authDataResult?.user {
                    
                    ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                               params: ["by": "email",
                                                        "uid": user.uid,
                                                        "email": email,
                                                        "guest": "yes"])
                    
                    MyProfileRemoteManager.manager.updateMyProfile(userId: user.uid,
                                                                   data: ["email":email, "signedup":"\(Date().timeIntervalSince1970)", "guest": false])
                    
                    DispatchQueue.global(qos: .background).async {
                        MyProfileRemoteManager.manager.configureMyProfileListener()
                    }
                    completion(nil)
                    
                } else {
                    completion("Encountered unexpected problems.  Please try again")
                }
            }
        })
    }
    
    func signup(email: String, password: String, completion: @escaping (String?) ->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                
                ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                           params: ["by": "email",
                                                    "uid": user!.user.uid,
                                                    "email": email,
                                                    "guest": "no"])
                
                MyProfileRemoteManager.manager.createMyProfile(userId: user!.user.uid, data: ["uid":user!.user.uid,
                                                                      "email":email,
                                                                      "created":"\(Date().timeIntervalSince1970)"])
                DispatchQueue.global(qos: .background).async {
                    MyProfileRemoteManager.manager.configureMyProfileListener()
                }
                completion(nil)
                
            } else {
                let errorCode = UInt((error! as NSError).code)
                if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                    completion("Email already in use.")
                } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                    completion("This email address is already in use with a different service.")
                } else {
                    completion(error!.localizedDescription)
                }
            }
        }
    }
    
    func guestSignIn(email: String, password: String, completion: @escaping (String?)->()) {
        
        AppOveralDataManager.manager.signout(with3rdPartyLogout: false)
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(300)) {
            Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
                if let error = error {
                    Auth.auth().signInAnonymously(completion: { (anonAuthData, anonAuthError) in
                        let errorCode = UInt((error as NSError).code)
                        if errorCode == AuthErrorCode.invalidEmail.rawValue || errorCode == AuthErrorCode.userNotFound.rawValue {
                            completion("User not found!")
                        } else if errorCode == AuthErrorCode.invalidCredential.rawValue || errorCode == AuthErrorCode.wrongPassword.rawValue {
                            completion("Password is incorrect.")
                        } else {
                            completion(error.localizedDescription)
                        }
                    })
                } else {
                    DispatchQueue.global(qos: .background).async {
                        MyProfileRemoteManager.manager.configureMyProfileListener()
                    }
                    completion(nil)
                }
            }
        }
    }
    
    func signin(email: String, password: String, completion: @escaping (String?)->()) {
    
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                DispatchQueue.global(qos: .background).async {
                    MyProfileRemoteManager.manager.configureMyProfileListener()
                }
                completion(nil)
            } else {
                let errorCode = UInt((error! as NSError).code)
                if errorCode == AuthErrorCode.invalidEmail.rawValue || errorCode == AuthErrorCode.userNotFound.rawValue {
                    completion("User not found!")
                } else if errorCode == AuthErrorCode.invalidCredential.rawValue || errorCode == AuthErrorCode.wrongPassword.rawValue {
                    completion("Password is incorrect.")
                } else {
                    completion(error!.localizedDescription)
                }
            }
        }
    }
    
    func resetPassword(email:String, completion: @escaping (String?)->()) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    func appleLogin(with idToken: String,
                    nonce: String,
                    email: String,
                    name: String,
                    appleUserId: String,
                    completion: @escaping (String?) ->()) {
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nonce)
        
        Auth.auth().signIn(with: credential) { (authDataResult, error) in
            
            if error == nil {
                let user = authDataResult?.user
                self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        
                        MyProfileRemoteManager.manager.updateMyProfile(userId: user!.uid, data: ["authorizedBy": "apple", "appleId": appleUserId])
                        
                        DispatchQueue.global(qos: .background).async {
                            MyProfileRemoteManager.manager.configureMyProfileListener()
                        }
                        completion(nil)
                    } else {
                        
                        ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                                   params: ["by": "apple",
                                                            "uid": user!.uid,
                                                            "email": email,
                                                            "name": name,
                                                            "appleUserId": appleUserId,
                                                            "guest": "no"])
                        
                        MyProfileRemoteManager.manager.createMyProfile(userId: user!.uid, data:[
                            "uid":user!.uid,
                            "name": name,
                            "email": email,
                            "appleId": appleUserId,
                            "authorizedBy":"apple",
                            "created":"\(Date().timeIntervalSince1970)"])
                        DispatchQueue.global(qos: .background).async {
                            MyProfileRemoteManager.manager.configureMyProfileListener()
                        }
                        completion(nil)
                    }
                })
            } else {
                let errorCode = (error! as NSError).code
                
                if let firebaseError = AuthErrorCode(rawValue: errorCode) {
                    switch firebaseError {
                    case .emailAlreadyInUse:
                        completion("Email already in use.")
                    case .appNotAuthorized:
                        completion("App not authorized.")
                    case .appNotVerified:
                        completion("App not verified")
                    case .accountExistsWithDifferentCredential:
                        completion("Your accont had already been created with different social platform.")
                    case .credentialAlreadyInUse:
                        completion("Credential already in use.")
                    case .internalError:
                        completion("Internal error occured.")
                    default:
                        completion("Firebase error occured. Code - \(firebaseError)")
                    }
                } else {
                    if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                        completion("Email already in use.")
                    } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                        completion("This email address is already in use with a different service.")
                    } else {
                        completion(error!.localizedDescription)
                    }
                }
            }
        }
    }
    
    func facebookLoginForGuestUser(controller: UIViewController, completion: @escaping (String?) ->()) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: controller) { (result, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else if result!.isCancelled {
                completion("Facebook login canceled.")
            } else {
                if result!.grantedPermissions.contains("email"), let accessToken = AccessToken.current?.tokenString {
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                    Auth.auth().currentUser?.link(with: credential, completion: { (authDataResult, error) in
                        if let error = error {
                            let errorCode = UInt((error as NSError).code)
                            print("error code - \(errorCode)")
                            if errorCode == AuthErrorCode.credentialAlreadyInUse.rawValue {
                                completion("FACEBOOK ACCOUNT LINKED")
                            } else {
                                completion(error.localizedDescription)
                            }
                        } else {
                            if let user = authDataResult?.user {
                                GraphRequest(graphPath: "me", parameters: ["fields":"id,name,first_name,last_name,picture.type(large), email"]).start(completionHandler: { (connection, result, error) in
                                    
                                    if error == nil {
                                        if let result = result as? [String:Any] {
                                            var photoUrl = ""
                                            if let pictureData = result["picture"] as? [String:Any] {
                                                if let pictureUrl = pictureData["data"] as? [String:Any] {
                                                    photoUrl = pictureUrl["url"] as? String ?? ""
                                                }
                                            }
                                            let firstName = result["first_name"] as? String ?? ""
                                            let lastName = result["last_name"] as? String ?? ""
                                            
                                            ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                                                       params: ["by": "facebook",
                                                                                "uid": user.uid,
                                                                                "email": result["email"] as? String ?? "",
                                                                                "fbid":result["id"] as? String ?? "",
                                                                                "guest": "yes"])
                                            
                                            MyProfileRemoteManager.manager.updateMyProfile(userId: user.uid, data:[
                                                "name": "\(firstName) \(lastName)",
                                                "email": result["email"] as? String ?? "",
                                                "avatar": photoUrl,
                                                "fbId": result["id"] as? String ?? "",
                                                "authorizedBy":"fb",
                                                "guest": false,
                                                "signedup":"\(Date().timeIntervalSince1970)"])
                                            DispatchQueue.global(qos: .background).async {
                                                MyProfileRemoteManager.manager.configureMyProfileListener()
                                            }
                                            completion(nil)
                                        } else {
                                            loginManager.logOut()
                                            completion("Facebook profile fetch failed.")
                                        }
                                    } else {
                                        loginManager.logOut()
                                        completion("Facebook profile fetch failed. \(error!.localizedDescription)")
                                    }
                                })
                            }
                        }
                    })
                }
            }
        }
    }
    
    func facebookLogout() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
    
    func facebookContinue(completion: @escaping (String?)->()) {
        
        if let currentGuestUserId = Auth.auth().currentUser?.uid {
            self.database.child("users").child(currentGuestUserId).updateChildValues(["closed":"\(Date().timeIntervalSince1970)"])
        }
        
        
        if let accessTokenString = AccessToken.current?.tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
            Auth.auth().signIn(with: credential, completion: { (authDataResult, error) in
                if error == nil {
                    let user = authDataResult?.user
                    self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {
                            DispatchQueue.global(qos: .background).async {
                                MyProfileRemoteManager.manager.configureMyProfileListener()
                            }
                            completion(nil)
                        } else {
                            completion("unknown error")
                        }
                    })
                } else {
                    let errorCode = UInt((error! as NSError).code)
                    if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                        completion("Email already in use.")
                    } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                        completion("This email address is already in use with a different service.")
                    } else {
                        completion(error!.localizedDescription)
                    }
                }
            })
        } else {
            completion("Access token is invalid.")
        }
    }
    
    func facebookLogin(controller: UIViewController, completion: @escaping (String?)->()) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: controller) { (result, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else if result!.isCancelled {
                completion("Facebook login canceled.")
            } else {
                if result!.grantedPermissions.contains("email"), let accessToken = AccessToken.current?.tokenString {
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                    
                    Auth.auth().signIn(with: credential, completion: { (authDataResult, error) in
                        if error == nil {
                            let user = authDataResult?.user
                            self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.exists() {
                                    DispatchQueue.global(qos: .background).async {
                                        MyProfileRemoteManager.manager.configureMyProfileListener()
                                    }
                                    completion(nil)
                                } else {
                                    GraphRequest(graphPath: "me", parameters: ["fields":"id,name,first_name,last_name,picture.type(large), email"]).start(completionHandler: { (connection, result, error) in
                                        
                                        if error == nil {
                                            
                                            
                                            
                                            if let result = result as? [String:Any] {
                                                var photoUrl = ""
                                                if let pictureData = result["picture"] as? [String:Any] {
                                                    if let pictureUrl = pictureData["data"] as? [String:Any] {
                                                        photoUrl = pictureUrl["url"] as? String ?? ""
                                                    }
                                                }
                                                let firstName = result["first_name"] as? String ?? ""
                                                let lastName = result["last_name"] as? String ?? ""
                                                
                                                ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                                                           params: ["by": "facebook",
                                                                                    "uid": user!.uid,
                                                                                    "email": result["email"] as? String ?? "",
                                                                                    "fbId": result["id"] as? String ?? "",
                                                                                    "guest": "no"])
                                                
                                                MyProfileRemoteManager.manager.createMyProfile(userId: user!.uid, data:[
                                                    "uid":user!.uid,
                                                    "name": "\(firstName) \(lastName)",
                                                    "email": result["email"] as? String ?? "",
                                                    "avatar": photoUrl,
                                                    "fbId": result["id"] as? String ?? "",
                                                    "authorizedBy":"fb",
                                                    "created":"\(Date().timeIntervalSince1970)"])
                                                DispatchQueue.global(qos: .background).async {
                                                    MyProfileRemoteManager.manager.configureMyProfileListener()
                                                }
                                                completion(nil)
                                            } else {
                                                loginManager.logOut()
                                                completion("Facebook profile fetch failed.")
                                            }
                                        } else {
                                            loginManager.logOut()
                                            completion("Facebook profile fetch failed. \(error!.localizedDescription)")
                                        }
                                    })
                                }
                            })
                        } else {
                            let errorCode = UInt((error! as NSError).code)
                            if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                                completion("Email already in use.")
                            } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                                completion("This email address is already in use with a different service.")
                            } else {
                                completion(error!.localizedDescription)
                            }
                        }
                    })
                } else {
                    completion("Facebook login failed because of Email permission.")
                }
            }
        }
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    func googleLogin(completion: @escaping (String?)->()){
        self.completionCallbackForGoogleSignin = completion
        do {
            try GIDSignIn.sharedInstance().signIn()
        } catch let error {
            print("Error in google sign in : \(error)")
        }
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func guestGoogleConnect(with credential: AuthCredential, googleUser: GIDGoogleUser) {
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (authDataResult, error) in
            if error == nil {
                if let user = authDataResult?.user {
                    var avatarUrl = ""
                    if googleUser.profile.hasImage {
                        let dimension = UInt(round(100 * UIScreen.main.scale))
                        avatarUrl = googleUser.profile.imageURL(withDimension: dimension).absoluteString
                    }
                    
                    ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                               params: ["by": "google",
                                                        "uid": user.uid,
                                                        "email": googleUser.profile.email,
                                                        "googleId":googleUser.userID,
                                                        "guest": "yes"])
                    
                    MyProfileRemoteManager.manager.updateMyProfile(userId: user.uid, data:[
                        "name": googleUser.profile.name,
                        "email": googleUser.profile.email,
                        "avatar": avatarUrl,
                        "googleId": googleUser.userID,
                        "authorizedBy":"google",
                        "guest": false,
                        "signedup":"\(Date().timeIntervalSince1970)"])
                    DispatchQueue.global(qos: .background).async {
                        MyProfileRemoteManager.manager.configureMyProfileListener()
                    }
                    self.completionCallbackForGoogleSignin?(nil)
                }
            } else {
                let errorCode = UInt((error! as NSError).code)
                if errorCode == AuthErrorCode.credentialAlreadyInUse.rawValue {
                    self.completionCallbackForGoogleSignin?("Google Account Linked")
                } else {
                    self.completionCallbackForGoogleSignin?(error!.localizedDescription)
                }
            }
        })
    }
    
    func googleSignIn(with credential: AuthCredential!, googleUser: GIDGoogleUser!) {
        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in
            if error == nil {
                let user = authDataResult?.user
                self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        DispatchQueue.global(qos: .background).async {
                            MyProfileRemoteManager.manager.configureMyProfileListener()
                        }
                        self.completionCallbackForGoogleSignin!(nil)
                    } else {
                        var avatarUrl = ""
                        if googleUser.profile.hasImage {
                            let dimension = UInt(round(100 * UIScreen.main.scale))
                            avatarUrl = googleUser.profile.imageURL(withDimension: dimension).absoluteString
                        }
                        
                        ModacityAnalytics.LogEvent(ModacityEvent.CreatedAccount,
                                                   params: ["by": "google",
                                                            "uid": user!.uid,
                                                            "email": googleUser.profile.email,
                                                            "googleId": googleUser.userID,
                                                            "guest": "no"])
                        
                        MyProfileRemoteManager.manager.createMyProfile(userId: user!.uid, data:[
                            "uid":user!.uid,
                            "name": googleUser.profile.name,
                            "email": googleUser.profile.email,
                            "avatar": avatarUrl,
                            "googleId": googleUser.userID,
                            "authorizedBy":"google",
                            "created":"\(Date().timeIntervalSince1970)"])
                        DispatchQueue.global(qos: .background).async {
                            MyProfileRemoteManager.manager.configureMyProfileListener()
                        }
                        self.completionCallbackForGoogleSignin!(nil)
                    }
                })
            } else {
                let errorCode = UInt((error! as NSError).code)
                if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.completionCallbackForGoogleSignin?("Email already in use.")
                } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                    self.completionCallbackForGoogleSignin?("This email address is already in use with a different service.")
                } else {
                    self.completionCallbackForGoogleSignin?(error!.localizedDescription)
                }
            }
        }
    }
    
    func googleContinue(completion: @escaping (String?)->()) {
        
        if let currentGuestUserId = Auth.auth().currentUser?.uid {
            self.database.child("users").child(currentGuestUserId).updateChildValues(["closed":"\(Date().timeIntervalSince1970)"])
        }
        
        if let googleUser = GIDSignIn.sharedInstance()?.currentUser {
            
            guard let authentication = googleUser.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signInAndRetrieveData(with: credential, completion: { (authDataResult, error) in
                if error == nil {
                    let user = authDataResult?.user
                    self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() {
                            DispatchQueue.global(qos: .background).async {
                                MyProfileRemoteManager.manager.configureMyProfileListener()
                            }
                            completion(nil)
                        } else {
                            completion("unknown error")
                        }
                    })
                } else {
                    let errorCode = UInt((error! as NSError).code)
                    if errorCode == AuthErrorCode.emailAlreadyInUse.rawValue {
                        completion("Email already in use.")
                    } else if errorCode == AuthErrorCode.accountExistsWithDifferentCredential.rawValue || errorCode == AuthErrorCode.providerAlreadyLinked.rawValue {
                        completion("This email address is already in use with a different service.")
                    } else {
                        completion(error!.localizedDescription)
                    }
                }
            })
        } else {
            completion("Encountered unexpected problems.  Please try again")
            return
        }
    }
    
    func signout() {
        try! Auth.auth().signOut()
    }
    
}

extension Authorizer: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            if let callback = self.completionCallbackForGoogleSignin {
                callback(error.localizedDescription)
                return
            }
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        if isGuestLogin() {
            self.guestGoogleConnect(with: credential, googleUser: user)
        } else {
            self.googleSignIn(with: credential, googleUser: user)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }

}
