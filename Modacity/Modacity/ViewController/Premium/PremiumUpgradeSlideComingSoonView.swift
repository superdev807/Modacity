//
//  PremiumUpgradeSlideView.swift
//  Modacity
//
//  Created by Benjamin Chris on 20/7/18.
//  Copyright © 2018 Modacity Inc. All rights reserved.
//

import UIKit

class PremiumUpgradeSlideComingSoonView: UIView {

    @IBOutlet var viewContent: UIView!
    var delegate: PremiumUpgradeSlideViewDelegate!
    
    @IBOutlet weak var labelTitleTopView: UILabel!
    
    @IBOutlet weak var constraintForBottomViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForViewHeight1: NSLayoutConstraint!
    @IBOutlet weak var constraintForViewHeight2: NSLayoutConstraint!
    @IBOutlet weak var constraintForViewHeight3: NSLayoutConstraint!
    @IBOutlet weak var constraintForViewHeight4: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PremiumUpgradeSlideComingSoonView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let attributed = NSMutableAttributedString(string: "Coming soon", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 16)!])
        attributed.append(NSAttributedString(string: " for premium members only:", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoLight, size:16)!]))
        self.labelTitleTopView.attributedText = attributed
        
        let swipeNextGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipeNext))
        swipeNextGesture.direction = .left
        let swipePrevGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipePrev))
        swipePrevGesture.direction = .right
        self.viewContent.addGestureRecognizer(swipeNextGesture)
        self.viewContent.addGestureRecognizer(swipePrevGesture)
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForBottomViewBottomSpace.constant = -10
            self.constraintForViewHeight1.constant = 36
            self.constraintForViewHeight2.constant = 36
            self.constraintForViewHeight3.constant = 36
            self.constraintForViewHeight4.constant = 36
        }
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
