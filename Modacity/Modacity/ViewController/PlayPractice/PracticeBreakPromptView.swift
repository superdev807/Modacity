//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
    
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var viewContentPanel: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    var timerStarted: Date!
    var timer: Timer! = nil
    
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
    
    func showPracticeTime(_ second: Int) {
        var timeString = ""
        if second > 0 && second < 60 {
            if second == 1 {
                timeString = "1 second"
            } else {
                timeString = "\(second) seconds"
            }
        } else {
            let minute = second / 60
            if minute == 1 {
                timeString = "1 minute"
            } else {
                timeString = "\(minute) minutes"
            }
        }
        let attributedString = NSMutableAttributedString(string: "You've been practicing for \n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!])
        attributedString.append(NSAttributedString(string: timeString, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 12)!]))
        attributedString.append(NSAttributedString(string: ", don’t forget to take a moment to rest.", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!]))
        self.labelNote.attributedText = attributedString
        
        let noteTitle = NSMutableAttributedString(string: "IT'S TIME TO\n", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoLight, size: 21)!])
        noteTitle.append(NSAttributedString(string: "TAKE A BREAK", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBold, size: 21)!]))
        self.labelTitle.attributedText = noteTitle

    }
    
    @IBAction func onCoverClick(_ sender: Any) {
        self.stopCountUpTimer()
        if self.delegate != nil {
            self.delegate.dismiss(practiceBreakPromptView: self)
        }
    }
    
    @IBAction func onReady(_ sender: Any) {
        self.onCoverClick(sender)
    }
    
    func startCountUpTimer() {
        self.timerStarted = Date()
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onUpdateTimer), userInfo: nil, repeats: true)
    }
    
    func stopCountUpTimer() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc func onUpdateTimer() {
        let time = Int(Date().timeIntervalSince1970 - self.timerStarted.timeIntervalSince1970)
        self.labelHour.text = String(format:"%02d", time / 3600)
        self.labelMinute.text = String(format:"%02d", (time % 3600) / 60)
        self.labelSecond.text = String(format:"%02d", time % 60)
    }
}
