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
import AuthenticationServices

#if canImport(CryptoKit)
import CryptoKit
#endif

class CreateAccountViewController: ModacityParentViewController {

    @IBOutlet weak var spinnerFacebook: UIActivityIndicatorView!
    @IBOutlet weak var spinnerGoogle: UIActivityIndicatorView!
    @IBOutlet weak var labelWaiting: UILabel!
    @IBOutlet weak var spinnerProcessing: UIActivityIndicatorView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var buttonEmailSignIn: UIButton!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var lableVersionChecking: UILabel!
    @IBOutlet weak var spinnerApple: UIActivityIndicatorView!
    
    fileprivate var currentNonce: String?

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
        
        switch AppConfig.appVersion {
        case .dev:
            self.lableVersionChecking.text = "(Dev Version)"
        case .staging:
            self.lableVersionChecking.text = "(Staging Version)"
        case .live:
            self.lableVersionChecking.text = ""
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if fromSignout || Authorizer.authorizer.isGuestLogin() {
            self.buttonSkip.isHidden = true
//        } else {
//            self.buttonSkip.isHidden = false
//        }
    }

    @IBAction func onAppleLogin(_ sender: Any) {
        if #available(iOS 13.0, *) {
            
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.email, .fullName]
            request.nonce = sha256(nonce)

            self.spinnerApple.startAnimating()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func initControls() {
        
        self.spinnerFacebook.stopAnimating()
        self.spinnerGoogle.stopAnimating()
        self.spinnerProcessing.stopAnimating()
        self.spinnerApple.stopAnimating()
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

@available(iOS 13.0, *)
extension CreateAccountViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        
        #if canImport(CryptoKit)
        let hashedData = SHA256.hash(data: inputData)
        
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
        #else
        return input
        #endif
        
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                spinnerApple.stopAnimating()
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                spinnerApple.stopAnimating()
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "ID Token is invalid")
                return
            }
            
            var emailAddress = ""
            var userDispayName = ""
            
            if let email = appleIDCredential.email {
                emailAddress = email
                UserDefaults.standard.set(email, forKey: "apple-email-\(appleIDCredential.user)")
            } else if let email = UserDefaults.standard.string(forKey: "apple-email-\(appleIDCredential.user)") {
                emailAddress = email
            }
            
            if let fullName = appleIDCredential.fullName {
                let familyName = fullName.familyName ?? ""
                let givenName = fullName.givenName ?? ""
                userDispayName = "\(givenName) \(familyName)"
                UserDefaults.standard.set(userDispayName, forKey: "apple-email-\(appleIDCredential.user)")
            } else if let fulName = UserDefaults.standard.string(forKey: "apple-email-\(appleIDCredential.user)") {
                userDispayName = fulName
            }
            
            Authorizer.authorizer.appleLogin(with: idTokenString, nonce: nonce, email: emailAddress, name: userDispayName, appleUserId: appleIDCredential.user) { [weak self] err in
                guard let self = self else { return }
                self.spinnerApple.stopAnimating()
                if let err = err {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: err)
                } else {
                    let controller = UIStoryboard(name: "sidemenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenuController") as! SideMenuController
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            
        } else {
            spinnerApple.stopAnimating()
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Failed to sign in with Apple")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.spinnerApple.stopAnimating()
        
        AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Apple sign in failed with error \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

