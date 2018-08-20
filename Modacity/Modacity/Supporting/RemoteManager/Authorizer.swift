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
    
    func signup(email: String, password: String, completion: @escaping (String?) ->()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                
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
    
    func facebookLogin(controller: UIViewController, completion: @escaping (String?)->()) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: controller) { (result, error) in
            if let error = error {
                completion(error.localizedDescription)
            } else if result!.isCancelled {
                completion("Facebook login canceled.")
            } else {
                if result!.grantedPermissions.contains("email") {
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if error == nil {
                            self.database.child("users").child(user!.uid).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.exists() {
                                    DispatchQueue.global(qos: .background).async {
                                        MyProfileRemoteManager.manager.configureMyProfileListener()
                                    }
                                    completion(nil)
                                } else {
                                    FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,first_name,last_name,picture.type(large), email"]).start(completionHandler: { (connection, result, error) in
                                        
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
                    }
                } else {
                    completion("Facebook login failed because of Email permission.")
                }
            }
        }
    }
    
    func googleLogin(completion: @escaping (String?)->()){
        self.completionCallbackForGoogleSignin = completion
        GIDSignIn.sharedInstance().signIn()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func googleSignIn(with credential: AuthCredential!, googleUser: GIDGoogleUser!) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error == nil {
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
        self.googleSignIn(with: credential, googleUser: user)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }

}
