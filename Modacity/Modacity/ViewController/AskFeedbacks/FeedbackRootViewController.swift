//
//  FeedbackRootViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/25/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import MessageUI
import MBProgressHUD

class FeedbackRootViewController: UIViewController {
    
    var pageUIMode: Int = 0         // 0 : Ask an Expert, 1 : Feedback

    @IBOutlet weak var viewTextContainer: UIView!
    @IBOutlet weak var constraintForBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var imageViewCheckIcon: UIImageView!
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubTitle: UILabel!
    @IBOutlet weak var viewAttachMostRecentAudio: UIView!
    @IBOutlet weak var segmentedControlMode: UISegmentedControl!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopLeft: UIImageView!
    
    var checkIconSelected = false
    var pageIsRootFromMenu = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.viewTextContainer.layer.cornerRadius = 10
        self.checkIconSelected = false
        self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_deselected")
        self.textViewMessage.placeholder = "Type your message here"
        self.textViewMessage.placeholderColor = Color(hexString:"#9F9EAD")
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForHeaderImageViewHeight.constant = 70
        } else {
            self.constraintForHeaderImageViewHeight.constant = 80
        }
        
        if self.pageIsRootFromMenu {
            self.imageViewTopLeft.image = UIImage(named: "icon_menu")
        } else {
            self.imageViewTopLeft.image = UIImage(named: "icon_arrow_left")
        }
        
        self.configurePageForMode()
        self.textViewMessage.becomeFirstResponder()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_sent" {
            let controller = segue.destination as! FeedbackSentViewController
            controller.pageUIMode = self.pageUIMode
            controller.pageIsRootFromMenu = self.pageIsRootFromMenu
            controller.parentRootController = self
        }
    }
    
    func configurePageForMode() {
        if self.pageUIMode == 0 {
            self.labelTitle.text = "Want a Boost?"
            self.labelSubTitle.text = "Got a question or obstacle, or just want suggestions? We’ll connect you with pros from Philadelphia Orchestra, Juilliard, Berklee School of Music, and more!"
            self.viewAttachMostRecentAudio.isHidden = false
            self.segmentedControlMode.selectedSegmentIndex = 0
        } else {
            self.labelTitle.text = "We Love Hearing From You"
            self.labelSubTitle.text = "Got a suggestion on how we can improve? Or just want to share your experience?"
            self.viewAttachMostRecentAudio.isHidden = true
            self.segmentedControlMode.selectedSegmentIndex = 1
        }
    }
    
    func changePageUIMode(to mode:Int) {
        self.pageUIMode = mode
        self.configurePageForMode()
    }
    
    @objc func onKeyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                self.constraintForBottomSpace.constant = keyboardSize.height - 30
            } else {
                self.constraintForBottomSpace.constant = keyboardSize.height
            }
        }
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                self.constraintForBottomSpace.constant = keyboardSize.height - 30
            } else {
                self.constraintForBottomSpace.constant = keyboardSize.height
            }
        }
    }
    
    @objc func onKeyboardWillHide(notification: Notification) {
        self.constraintForBottomSpace.constant = 0
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.pageIsRootFromMenu {
            self.sideMenuController?.showLeftViewAnimated()
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onTaponView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onAttachMostRecentAudio(_ sender: Any) {
        self.checkIconSelected = !self.checkIconSelected
        if self.checkIconSelected {
            ModacityAnalytics.LogStringEvent("Selected Attach Audio")
            self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_selected")
        } else {
            ModacityAnalytics.LogStringEvent("Deselected Attach Audio")
            self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_deselected")
        }
    }
    
    @IBAction func onSegmentControlChanged(_ sender: Any) {
        self.pageUIMode = self.segmentedControlMode.selectedSegmentIndex
        self.configurePageForMode()
    }
    
    @IBAction func onSent(_ sender: Any) {
        let type :ModacityEmailType = (pageUIMode == 0) ? .AskExpert : .Feedback
        
        if (type == .AskExpert) {
            ModacityAnalytics.LogStringEvent("Pressed Send Ask Expert")
        } else {
            ModacityAnalytics.LogStringEvent("Pressed Send Feedback")
        }
        
        self.textViewMessage.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: "Send message", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Send via Email", style: .default, handler: { (_) in
            self.sendMail(type: type, body: self.textViewMessage.text, includeAudio: (type == .AskExpert && self.checkIconSelected))
        }))
        alertController.addAction(UIAlertAction(title: "Send via Modacity Cloud", style: .default, handler: { (_) in
            self.sendMessageToModacity(type: type, body: self.textViewMessage.text, includeAudio: (type == .AskExpert && self.checkIconSelected))
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @objc func confirmSent() {
        self.performSegue(withIdentifier: "sid_sent", sender: nil)
    }
}

enum ModacityEmailType { case Feedback, AskExpert }

//--------- MAIL
extension FeedbackRootViewController : MFMailComposeViewControllerDelegate {
    
    func sendMessageToModacity(type: ModacityEmailType, body:String, includeAudio: Bool=false) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        MessagesManager.manager.sendMessageToModacity(type: type, body: body, includeAudio: includeAudio) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error)
            } else {
                self.confirmSent()
            }
        }
    }
    
    func sendMail(type: ModacityEmailType, body:String, includeAudio: Bool=false) {
        
        if( MFMailComposeViewController.canSendMail() ) {
            ModacityDebugger.debug("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set the subject and message of the email
            let recipient = (type == .Feedback) ? "feedback@modacity.co" : "expert@modacity.co"
            
            let subject = generateEmailSubject(type)
            
            mailComposer.setToRecipients([recipient])
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(body, isHTML: false)
            
            if (includeAudio) {
                let fileURL = Recording.currentRecordingURL()
                
                do  {
                    let fileData = try Data.init(contentsOf: fileURL)
                    ModacityDebugger.debug("File data loaded.")
                    mailComposer.addAttachmentData(fileData, mimeType: "audio/wav", fileName: "all_good_getting_better")
                    
                } catch let error {
                    ModacityDebugger.debug("\(error.localizedDescription)")
                }
            }
            
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: nil, message: "Your device can't sent message. Please check Email settings on the device.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.openURL(settingsUrl)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func generateEmailSubject(_ type: ModacityEmailType) -> String {
        let uuid: String = (MyProfileLocalManager.manager.me?.uid)!
        switch(type) {
        case .Feedback:
            return "Beta feedback \(uuid)" // plus unique info
        case .AskExpert:
            return "Ask expert \(uuid)" // plus unique info
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                AppUtils.showSimpleAlertMessage(for: self, title: nil, message: error.localizedDescription, handler: { _ in
                    if !self.pageIsRootFromMenu {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                if result == .sent {
                    self.confirmSent()
                } else {
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Message has not been sent.")
                    if !self.pageIsRootFromMenu {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
}
