//
//  ViewController.swift
//  modacity-admin
//
//  Created by BC Engineer on 10/5/18.
//  Copyright © 2018 modacity. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MessageUI

class ViewController: UIViewController {
    
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonExport: UIButton!
    @IBOutlet weak var activityIndicatorLoading: UIActivityIndicatorView!
    
    let dateFormat = "yyyy-MM-dd"
    
    var userDataPerDate = [String: [[String:Any]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.activityIndicatorLoading.stopAnimating()
        self.processAuthStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.processAuthStatus()
    }
    
    func processAuthStatus() {
        if self.isLoggedIn() {
            self.textfieldEmail.isEnabled = false
            self.textfieldPassword.isEnabled = false
            self.textfieldEmail.textColor = UIColor.gray
            self.textfieldPassword.textColor = UIColor.gray
            self.buttonLogin.setTitle("Log Out", for: .normal)
            self.buttonExport.isEnabled = true
        } else {
            self.textfieldEmail.isEnabled = true
            self.textfieldPassword.isEnabled = true
            self.textfieldEmail.textColor = UIColor.black
            self.textfieldPassword.textColor = UIColor.black
            self.buttonLogin.setTitle("Log In", for: .normal)
            self.buttonExport.isEnabled = false
        }
    }
    
    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    @IBAction func onExport(_ sender: Any) {
        
        self.activityIndicatorLoading.startAnimating()
        
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.userDataPerDate = [String: [[String:Any]]]()
                if let children = snapshot.children.allObjects as? [DataSnapshot] {
                    for data in children {
                        if let userData = data.value as? [String:Any] {
                            if let userProfile = userData["profile"] as? [String:Any] {
                                if let createdAt = userProfile["created"] as? String {
                                    let createdTime = Date(timeIntervalSince1970: Double(createdAt) ?? 0)
                                    if var array = self.userDataPerDate[createdTime.toString(format: self.dateFormat)] {
                                        array.append(userProfile)
                                        self.userDataPerDate[createdTime.toString(format: self.dateFormat)] = array
                                    } else {
                                        self.userDataPerDate[createdTime.toString(format: self.dateFormat)] = [userProfile]
                                    }
                                }
                            }
                        }
                    }
                }
                self.createAndExportUserDataPerDate()
            }
            self.activityIndicatorLoading.stopAnimating()
        }
    }
    
    func createAndExportUserDataPerDate() {
        let fileName = "users.csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Date,User count,Emails\n"
        for (k,v) in Array(self.userDataPerDate).sorted(by: {$0.0 < $1.0}) {
            csvText.append(k)
            csvText.append(",")
            csvText.append("\(v.count)")
            csvText.append(",")
            for user in v {
                csvText.append(user["email"] as? String ?? "")
                csvText.append(",")
            }
            csvText.append("\n")
        }
        print(csvText)
        do {
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("User data")
            
            if let fileData = NSData(contentsOf: path) {
                mail.addAttachmentData(fileData as Data, mimeType: "text/csv", fileName: "users.csv")
            }
            
            self.present(mail, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: nil, message: "Please set email account!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func onLogin(_ sender: Any) {
        self.view.endEditing(true)
        
        if self.isLoggedIn() {
            do {
                try Auth.auth().signOut()
            } catch let err {
                print("Signout error \(err)")
            }
        } else {
            self.activityIndicatorLoading.startAnimating()
            Auth.auth().signIn(withEmail: self.textfieldEmail.text ?? "", password: self.textfieldPassword.text ?? "") { (user, err) in
                self.activityIndicatorLoading.stopAnimating()
                if let err = err {
                    let alert = UIAlertController(title: nil, message: err.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.processAuthStatus()
                }
            }
        }
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
