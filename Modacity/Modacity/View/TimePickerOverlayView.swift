//
//  TimePickerOverlayView.swift
//  Modacity
//
//  Created by BC Engineer on 11/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol TimePickerOverlayViewDelegate {
    func selectedTimeOnTimePickerPopupView(_ popupView: TimePickerOverlayView, time: Date)
    func cancelTimeOnTimePickerPopupView(_ popupView: TimePickerOverlayView)
}

class TimePickerOverlayView: UIView {
    
    static let PopupWidth = CGFloat(305)
    static let PopupHeight = CGFloat(263)
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var viewContentBox: UIView!
    
    var delegate: TimePickerOverlayViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TimePickerOverlayView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.viewContentBox.layer.cornerRadius = 5
        self.buttonDone.layer.cornerRadius = 28
    }

    @IBAction func onDone(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.selectedTimeOnTimePickerPopupView(self, time: self.datePicker.date)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.cancelTimeOnTimePickerPopupView(self)
        }
    }
}
