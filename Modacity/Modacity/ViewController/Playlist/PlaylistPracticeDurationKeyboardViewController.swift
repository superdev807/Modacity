//
//  PlaylistPracticeDurationKeyboardViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 3/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistPracticeDurationKeyboardViewController: UIViewController {

    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var labelHours: UILabel!
    @IBOutlet weak var labelMinutes: UILabel!
    @IBOutlet weak var labelSeconds: UILabel!
    
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var labelPracticeDuration: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var constraintForSubPanelHeight: NSLayoutConstraint!
    
    var viewModel: PlaylistDetailsViewModel!
    var inputIndicatorPoint = 6
    var inputDigits: [Int] = [Int](repeating: 0, count: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showValues()
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let seconds = self.calculateSeconds()
        self.viewModel.editingRow = -1
        self.viewModel.changeCountDownDuration(for: self.viewModel.clockEditingPracticeItemId, duration: seconds)
        self.dismiss(animated: true, completion: nil)
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
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.appConfigTimerGreenColor], range: NSMakeRange(self.inputIndicatorPoint - 4, 6 - self.inputIndicatorPoint))
            self.labelSeconds.attributedText = attributedString
        } else if self.inputIndicatorPoint > 1 {
            self.labelSeconds.textColor = AppConfig.appConfigTimerGreenColor
            let attributedString = NSMutableAttributedString(string: "\(inputDigits[2])\(inputDigits[3])")
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.appConfigTimerGreenColor], range: NSMakeRange(self.inputIndicatorPoint - 2, 4 - self.inputIndicatorPoint))
            self.labelMinutes.attributedText = attributedString
        } else {
            self.labelSeconds.textColor = AppConfig.appConfigTimerGreenColor
            self.labelMinutes.textColor = AppConfig.appConfigTimerGreenColor
            let attributedString = NSMutableAttributedString(string: "\(inputDigits[0])\(inputDigits[1])")
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor: AppConfig.appConfigTimerGreenColor], range: NSMakeRange(self.inputIndicatorPoint, 2 - self.inputIndicatorPoint))
            self.labelHours.attributedText = attributedString
        }
    }
    
    func calculateSeconds() -> Int {
        return inputDigits[5] + inputDigits[4] * 10 + inputDigits[3] * 60 + inputDigits[2] * 600 + inputDigits[1] * 3600 + inputDigits[0] * 36000
    }
    
    func showValues() {
        self.labelPracticeName.text = self.viewModel.clockEditingPracticeItem.name
        
        if (self.viewModel.isFavoritePracticeItem(forItemId: self.viewModel.clockEditingPracticeItem.practiceItemId)) {
            self.buttonHeart.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonHeart.alpha = 0.3
        } else {
            self.buttonHeart.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonHeart.alpha = 1
        }
        
        self.ratingView.contentMode = .scaleAspectFit
        if let duration = self.viewModel.duration(forPracticeItem: self.viewModel.clockEditingPracticeItem.entryId) {
            
            self.labelPracticeDuration.text = String(format:"%d:%02d", duration / 60, duration % 60)
            self.constraintForSubPanelHeight.constant = 16
            
            if let rating = self.viewModel.rating(forPracticeItemId: self.viewModel.clockEditingPracticeItem.practiceItemId) {
                if rating > 0 {
                    self.ratingView.isHidden = false
                    self.ratingView.rating = rating
                } else {
                    self.ratingView.isHidden = true
                }
            } else {
                self.ratingView.isHidden = true
            }
        } else {
            self.labelPracticeDuration.text = ""
            if let rating = self.viewModel.rating(forPracticeItemId: self.viewModel.clockEditingPracticeItem.practiceItemId) {
                if rating > 0 {
                    self.ratingView.isHidden = false
                    self.ratingView.rating = rating
                    self.constraintForSubPanelHeight.constant = 16
                } else {
                    self.ratingView.isHidden = true
                    self.constraintForSubPanelHeight.constant = 0
                }
            } else {
                self.ratingView.isHidden = true
                self.constraintForSubPanelHeight.constant = 0
            }
        }
        
        self.displayDigits()
        
        if let timer = self.viewModel.clockEditingPracticeItem.countDownDuration {
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
    }
    
}
