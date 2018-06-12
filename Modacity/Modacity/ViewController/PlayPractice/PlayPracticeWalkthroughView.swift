//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PlayPracticeWalkthroughViewDelegate {
    func dismiss(playpracticeWalkThroughView: PlayPracticeWalkthroughView, storing: Bool)
}

class PlayPracticeWalkthroughView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet var constraintForWalkthroughNotesLeading: NSLayoutConstraint!
    var delegate: PlayPracticeWalkthroughViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PlayPracticeWalkthroughView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        if AppUtils.sizeModelOfiPhone() == .iphone6p_55in {
            self.constraintForWalkthroughNotesLeading.constant = 100
        }
    }
    
    @IBAction func onCoverClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(playpracticeWalkThroughView: self, storing: false)
        }
    }
    
    @IBAction func onCloseButtonClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(playpracticeWalkThroughView: self, storing: false)
        }
    }
    
    @IBAction func onGotitButtonClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(playpracticeWalkThroughView: self, storing: true)
        }
    }
}
