//
//  FeedbackRootViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/25/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import UITextView_Placeholder

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
    
    var checkIconSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.viewTextContainer.layer.cornerRadius = 10
        self.checkIconSelected = false
        self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_deselected")
        self.textViewMessage.placeholder = "Type your message here"
        self.textViewMessage.placeholderColor = Color(hexString:"#9F9EAD")
        
        self.configurePageForMode()
        
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
        }
    }
    
    func configurePageForMode() {
        if self.pageUIMode == 0 {
            self.labelTitle.text = "Need Help?"
            self.labelSubTitle.text = "Got a question about practice? Want ideas on how to improve? Connect with one of our experts."
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
            self.constraintForBottomSpace.constant = keyboardSize.height
        }
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForBottomSpace.constant = keyboardSize.height
        }
    }
    
    @objc func onKeyboardWillHide(notification: Notification) {
        self.constraintForBottomSpace.constant = 0
    }
    
    @IBAction func onMenu(_ sender: Any) {
        self.sideMenuController?.showLeftViewAnimated()
    }
    
    @IBAction func onTaponView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onAttachMostRecentAudio(_ sender: Any) {
        self.checkIconSelected = !self.checkIconSelected
        if self.checkIconSelected {
            self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_selected")
        } else {
            self.imageViewCheckIcon.image = UIImage(named:"icon_checkmark_blue_deselected")
        }
    }
    
    @IBAction func onSegmentControlChanged(_ sender: Any) {
        self.pageUIMode = self.segmentedControlMode.selectedSegmentIndex
        self.configurePageForMode()
    }
    
    @IBAction func onSent(_ sender: Any) {
        self.performSegue(withIdentifier: "sid_sent", sender: nil)
    }
    
}
