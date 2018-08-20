//
//  PlaylistPracticeDurationKeyboardViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 3/7/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PlaylistPracticeDurationKeyboardViewController: UIViewController, TimerInputViewDelegate {

    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var labelPracticeDuration: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var constraintForSubPanelHeight: NSLayoutConstraint!
    
    var viewModel: PlaylistContentsViewModel!
    
    var timerInputView: TimerInputView!
    
    @IBOutlet weak var viewRowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addInputView()
        self.showValues()
    }
    
    func addInputView() {
        self.timerInputView = TimerInputView()
        self.view.addSubview(self.timerInputView)
        self.timerInputView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.timerInputView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.timerInputView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.viewRowView.bottomAnchor.constraint(equalTo: self.timerInputView.topAnchor, constant:10).isActive = true
        self.timerInputView.delegate = self
    }
    
    func onTimerSelected(timerInSec: Int) {
//        if timerInSec > 0 {
            self.viewModel.editingRow = -1
            self.viewModel.changeCountDownDuration(for: self.viewModel.clockEditingPracticeItemId, duration: timerInSec)
//        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClose(_ sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func onTimerDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    func showValues() {
        self.labelPracticeName.text = self.viewModel.clockEditingPracticeItem.practiceItem()?.name ?? ""

        if !(self.viewModel.isFavoritePracticeItem(forItemId: self.viewModel.clockEditingPracticeItem.practiceItemId)) {
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
        if let timer = self.viewModel.clockEditingPracticeItem.countDownDuration {
            self.timerInputView.showValues(timer: timer)
        }
    }
}
