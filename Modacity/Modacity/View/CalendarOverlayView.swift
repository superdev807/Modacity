//
//  CalendarOverlayView.swift
//  Modacity
//
//  Created by BC Engineer on 11/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import SwiftMoment

protocol CalendarOverlayViewDelegate {
    func selectedDateOnCalendarOverlayView(_ view: CalendarOverlayView, date: Date)
    func cancelOnCalendarOverlayView(_ view: CalendarOverlayView)
}

class CalendarOverlayView: UIView {
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var viewContentBox: UIView!
    
    @IBOutlet weak var labelSelectedDay: UILabel!
    @IBOutlet weak var labelSelectedYear: UILabel!
    @IBOutlet weak var labelShowingMonth: UILabel!
    
    var delegate: CalendarOverlayViewDelegate!
    
    var selectedDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CalendarOverlayView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.viewContentBox.layer.cornerRadius = 5
        self.buttonDone.layer.cornerRadius = 28
        
        CalendarView.daySelectedBackgroundColor = Color(hexString: "#5311CA")
        self.calendarView.delegate = self
        
        let now = Date()
        self.selectedDate = now      // initialize with today
        
        self.labelSelectedYear.text = now.toString(format: "yyyy")
        self.labelSelectedDay.text = now.toString(format: "EEE, MMM d")
    }
    
    func selectDate(_ date: Date) {
        self.selectedDate = date
        
        self.labelSelectedYear.text = date.toString(format: "yyyy")
        self.labelSelectedDay.text = date.toString(format: "EEE, MMM d")
    }

    @IBAction func onDone(_ sender: Any) {
        if self.delegate != nil {
            if let date = self.selectedDate {
                self.delegate.selectedDateOnCalendarOverlayView(self, date: date)
            }
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.cancelOnCalendarOverlayView(self)
        }
    }
    
    @IBAction func onPrevMonth(_ sender: Any) {
        self.calendarView.contentView.setContentOffset(CGPoint(x: (self.calendarView.contentView.currentPage - 1) * self.calendarView.contentView.frame.size.width, y: 0), animated: true)
    }
    
    @IBAction func onNextMonth(_ sender: Any) {
        self.calendarView.contentView.setContentOffset(CGPoint(x: (self.calendarView.contentView.currentPage + 1) * self.calendarView.contentView.frame.size.width, y: 0), animated: true)
    }
}

extension CalendarOverlayView: CalendarViewDelegate {
    func calendarDidSelectDate(date: Moment) {
        self.selectedDate = String(format: "%@ 23:59:59", date.date.toString(format: "yyyy-MM-dd")).date(format: "yyyy-MM-dd HH:mm:ss")
        DispatchQueue.main.async {
            self.labelSelectedYear.text = date.date.toString(format: "yyyy")
            self.labelSelectedDay.text = date.date.toString(format: "EEE, MMM d")
        }
    }
    
    func calendarDidPageToDate(date: Moment) {
        DispatchQueue.main.async {
            self.labelShowingMonth.text = date.date.toString(format: "MMMM yyyy")
        }
    }
}
