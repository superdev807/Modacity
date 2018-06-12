//
//  PlayPracticeTabBarView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PlayPracticeTabBarViewDelegate {
    func onTab(idx: Int)
}

class PlayPracticeTabBarView: UIView {
    
    @IBOutlet var viewContent: UIView!
    
    var delegate: PlayPracticeTabBarViewDelegate!

    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("PlayPracticeTabBarView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    @IBAction func onTab(_ sender: UIButton) {
        if self.delegate != nil {
            self.delegate.onTab(idx: sender.tag - 10)
        }
    }
}
