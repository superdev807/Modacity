//
//  DatePickerPopupView.swift
//  Modacity
//
//  Created by BC Engineer on 21/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol DatePickerPopupViewDelegate {
    func selectedDateOnDatePickerPopupView(_ popupView: DatePickerPopupView, date: Date)
    func cancelDateOnDatePickerPopupView(_ popupView: DatePickerPopupView)
}

class DatePickerPopupView: UIView {
    
    static let PopupWidth = CGFloat(305)
    static let PopupHeight = CGFloat(263)
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var constraintForDateInputPickerHeight: NSLayoutConstraint!
    
    var delegate: DatePickerPopupViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("DatePickerPopupView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            self.constraintForDateInputPickerHeight.constant = 240
        }
    }

    @IBAction func onDone(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.selectedDateOnDatePickerPopupView(self, date: self.datePicker.date)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.cancelDateOnDatePickerPopupView(self)
        }
    }
}
