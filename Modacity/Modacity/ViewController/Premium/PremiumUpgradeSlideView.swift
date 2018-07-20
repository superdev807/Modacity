//
//  PremiumUpgradeSlideView.swift
//  Modacity
//
//  Created by BC Engineer on 20/7/18.
//  Copyright © 2018 Modacity Inc. All rights reserved.
//

import UIKit

protocol PremiumUpgradeSlideViewDelegate {
    func onSlideNext()
    func onSlidePrev()
}

class PremiumUpgradeSlideView: UIView {

    @IBOutlet var viewContent: UIView!
    var delegate: PremiumUpgradeSlideViewDelegate!
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelTitlePart1: UILabel!
    @IBOutlet weak var labelTitlePart2: UILabel!
    @IBOutlet weak var imageViewImage: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PremiumUpgradeSlideView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let swipeNextGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeNext))
        swipeNextGesture.direction = .left
        let swipePrevGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipePrev))
        swipePrevGesture.direction = .right
        self.viewContent.addGestureRecognizer(swipeNextGesture)
        self.viewContent.addGestureRecognizer(swipePrevGesture)
    }
    
    @objc func onSwipeNext() {
        if self.delegate != nil {
            self.delegate.onSlideNext()
        }
    }
    
    @objc func onSwipePrev() {
        if self.delegate != nil {
            self.delegate.onSlidePrev()
        }
    }
}
