//
//  PremiumUpgradeSlideView.swift
//  Modacity
//
//  Created by Benjamin Chris on 20/7/18.
//  Copyright © 2018 Modacity Inc. All rights reserved.
//

import UIKit

protocol ImprovedDonePopupViewDelegate {
    func onPopupButtonYes()
    func onPopupButtonNo()
}

class ImprovedDonePopupView: UIView {

    @IBOutlet var viewContent: UIView!
    var delegate: ImprovedDonePopupViewDelegate?
    
    @IBOutlet weak var viewPopup: UIView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("ImprovedDonePopupView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.viewPopup.layer.cornerRadius = 10
    }
    
    @IBAction func onButtonNo(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onPopupButtonNo()
        }
    }
    
    @IBAction func onButtonYes(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onPopupButtonYes()
        }
    }
    
}
