//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PracticeBreakPromptViewDelegate {
    func dismiss(practiceBreakPromptView: PracticeBreakPromptView)
}

class PracticeBreakPromptView: UIView {

    var delegate: PracticeBreakPromptViewDelegate!
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var buttonReady: UIButton!
    
    @IBOutlet weak var labelHour: UILabel!
    @IBOutlet weak var labelMinute: UILabel!
    @IBOutlet weak var labelSecond: UILabel!
    
    @IBOutlet weak var viewContentPanel: UIView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PracticeBreakPromptView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.viewContentPanel.layer.cornerRadius = 10
        self.buttonReady.layer.cornerRadius = 22
    }
    
    @IBAction func onCoverClick(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.dismiss(practiceBreakPromptView: self)
        }
    }
    
    @IBAction func onReady(_ sender: Any) {
        self.onCoverClick(sender)
    }
}
