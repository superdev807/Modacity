//
//  PremiumUpgradeSlideView.swift
//  Modacity
//
//  Created by BC Engineer on 20/7/18.
//  Copyright © 2018 Modacity Inc. All rights reserved.
//

import UIKit

protocol PremiumUpgradeLockViewDelegate {
    func onFindOutMore()
}

class PremiumUpgradeLockView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var constraintForTopSpace: NSLayoutConstraint!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var viewContentPanel: UIView!
    
    var delegate: PremiumUpgradeLockViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PremiumUpgradeLockView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func configureForPracticeStats() {
        self.viewContent.isHidden = false
        let attributedString = NSMutableAttributedString(string: "UNLOCK YOUR\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 16)!])
        attributedString.append(NSAttributedString(string: "PRACTICE STATS", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 16)!]))
        self.labelTitle.attributedText = attributedString
        self.constraintForTopSpace.constant = 20
        self.labelDescription.text = "Get time breakdowns, rating history & more."
    }
    
    func configureForNote() {
//        self.viewContentPanel.isHidden = true
        let attributedString = NSMutableAttributedString(string: "WANT\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 16)!])
        attributedString.append(NSAttributedString(string: "UNLIMITED NOTES?", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 16)!]))
        self.labelTitle.attributedText = attributedString
        self.constraintForTopSpace.constant = 20
        self.labelDescription.text = "Get unlimited notes per item & access your archive."
    }
    
    func configureForHistory() {
        self.viewContent.isHidden = false
        let attributedString = NSMutableAttributedString(string: "UNLOCK YOUR\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 16)!])
        attributedString.append(NSAttributedString(string: "PRACTICE LOG", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 16)!]))
        self.labelTitle.attributedText = attributedString
        self.constraintForTopSpace.constant = 20
        self.labelDescription.text = "See a detailed history of your practice."
    }
    
    func configureForMetrodrone() {
        self.viewContent.isHidden = false
        let attributedString = NSMutableAttributedString(string: "UNLOCK STANDALONE\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 16)!])
        attributedString.append(NSAttributedString(string: "METRODRONE", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 16)!]))
        self.labelTitle.attributedText = attributedString
        self.constraintForTopSpace.constant = 20
        self.labelDescription.text = "Get access to our fullscreen MetroDrone."
    }
    
    func configureForTakeBreak() {
        self.viewContent.isHidden = false
        let attributedString = NSMutableAttributedString(string: "UNLOCK\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoLight, size: 16)!])
        attributedString.append(NSAttributedString(string: "BREAK REMINDERS", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 16)!]))
        self.labelTitle.attributedText = attributedString
        self.constraintForTopSpace.constant = 20
        self.labelDescription.text = "Let Modacity remind you to take a break!"
    }
    
    @IBAction func onFindOutMore(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.onFindOutMore()
        }
    }
}
