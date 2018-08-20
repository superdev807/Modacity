//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PracticeTimerUpWalkThroughViewDelegate {
    func dismiss(practiceTimerUpWalkThroughView: PracticeTimerUpWalkThroughView, storing: Bool)
}

class PracticeTimerUpWalkThroughView: UIView {

    @IBOutlet var viewContent: UIView!
    var delegate: PracticeTimerUpWalkThroughViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PracticeTimerUpWalkThroughView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    @IBAction func onCoverClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(practiceTimerUpWalkThroughView: self, storing: false)
        }
    }
    
    @IBAction func onCloseButtonClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(practiceTimerUpWalkThroughView: self, storing: false)
        }
    }
    
    @IBAction func onGotitButtonClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(practiceTimerUpWalkThroughView: self, storing: true)
        }
    }
}
