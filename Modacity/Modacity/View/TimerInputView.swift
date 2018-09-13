//
//  TimerInputView.swift
//  Modacity
//
//  Created by Benjamin Chris on 14/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol TimerInputViewDelegate {
    func onTimerSelected(timerInSec: Int)
    func onTimerDismiss()
}

class TimerInputView: UIView {
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var labelHours: UILabel!
    @IBOutlet weak var labelMinutes: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    @IBOutlet weak var viewKeyboard: UIView!
    @IBOutlet weak var imageViewTriangle: UIImageView!
    
    var delegate: TimerInputViewDelegate!
    
    var inputIndicatorPoint = 6
    var inputDigits: [Int] = [Int](repeating: 0, count: 6)
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TimerInputView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.viewKeyboard.backgroundColor = Color(hexString: "#2B2847")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    @IBAction func onBackspace(_ sender: Any) {
        if self.inputIndicatorPoint < 6 {
            for idx in ((self.inputIndicatorPoint + 1)..<6).reversed() {
                inputDigits[idx] = inputDigits[idx - 1]
            }
            inputDigits[self.inputIndicatorPoint] = 0
            self.inputIndicatorPoint = self.inputIndicatorPoint + 1
        }
        displayDigits()
    }
    
    @IBAction func onTapLetter(_ sender: UIButton) {
        let digit = sender.tag - 100
        
        if self.inputIndicatorPoint > 0 {
            for idx in self.inputIndicatorPoint..<6 {
                inputDigits[idx - 1] = inputDigits[idx]
            }
            inputDigits[5] = digit
            inputIndicatorPoint = inputIndicatorPoint - 1
        }
        
        displayDigits()
    }
    
    @IBAction func onTapHours(_ sender: Any) {
    }
    
    @IBAction func onTapMinutes(_ sender: Any) {
    }
    
    @IBAction func onTapSeconds(_ sender: Any) {
    }
    
    func displayDigits() {
        
        self.labelHours.text = "\(inputDigits[0])\(inputDigits[1])"
        self.labelMinutes.text = "\(inputDigits[2])\(inputDigits[3])"
        self.labelSeconds.text = "\(inputDigits[4])\(inputDigits[5])"
        self.labelHours.textColor = Color.white
        self.labelMinutes.textColor = Color.white
        self.labelSeconds.textColor = Color.white
        
        if self.inputIndicatorPoint > 3 {
            let attributedString = NSMutableAttributedString(string: "\(inputDigits[4])\(inputDigits[5])")
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.timerGreenColor], range: NSMakeRange(self.inputIndicatorPoint - 4, 6 - self.inputIndicatorPoint))
            self.labelSeconds.attributedText = attributedString
        } else if self.inputIndicatorPoint > 1 {
            self.labelSeconds.textColor = AppConfig.UI.AppColors.timerGreenColor
            let attributedString = NSMutableAttributedString(string: "\(inputDigits[2])\(inputDigits[3])")
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.timerGreenColor], range: NSMakeRange(self.inputIndicatorPoint - 2, 4 - self.inputIndicatorPoint))
            self.labelMinutes.attributedText = attributedString
        } else {
            self.labelSeconds.textColor = AppConfig.UI.AppColors.timerGreenColor
            self.labelMinutes.textColor = AppConfig.UI.AppColors.timerGreenColor
            let attributedString = NSMutableAttributedString(string: "\(inputDigits[0])\(inputDigits[1])")
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.timerGreenColor], range: NSMakeRange(self.inputIndicatorPoint, 2 - self.inputIndicatorPoint))
            self.labelHours.attributedText = attributedString
        }
    }
    
    func calculateSeconds() -> Int {
        return inputDigits[5] + inputDigits[4] * 10 + inputDigits[3] * 60 + inputDigits[2] * 600 + inputDigits[1] * 3600 + inputDigits[0] * 36000
    }
    
    func showValues(timer: Int) {
        inputDigits[5] = (timer % 60) % 10
        inputDigits[4] = (timer % 60) / 10
        inputDigits[3] = ((timer % 3600) / 60) % 10
        inputDigits[2] = ((timer % 3600) / 60) / 10
        inputDigits[1] = (timer / 3600) % 10
        inputDigits[0] = (timer / 3600) / 10
        self.inputIndicatorPoint = 6
        for idx in 0...5 {
            if inputDigits[idx] > 0 {
                self.inputIndicatorPoint = idx
                break
            }
        }
        self.displayDigits()
    }
    
    @IBAction func onClose(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.onTimerDismiss()
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.onTimerSelected(timerInSec: self.calculateSeconds())
        }
    }
}
