//
//  DayView.swift
//  Calendar
//
//  Created by Nate Armstrong on 3/29/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//  Updated to Swift 4 by A&D Progress aka verebes (c) 2018
//

import UIKit
import SwiftMoment

let CalendarSelectedDayNotification = "CalendarSelectedDayNotification"

class DayView: UIView {

  var date: Moment! {
    didSet {
      dateLabel.text = date.format("d")
      setNeedsLayout()
    }
  }
  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = CalendarView.dayFont
    self.addSubview(label)
    return label
  }()
  lazy var dateBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = Color.clear
    self.addSubview(view)
    return view
  }()
  var isToday: Bool = false
  var isOtherMonth: Bool = false
  var selected: Bool = false {
    didSet {
      if selected {
        NotificationCenter.default
            .post(name: NSNotification.Name(rawValue: CalendarSelectedDayNotification), object: date.toNSDate())
      }
      updateView()
    }
  }

  init() {
    super.init(frame: CGRect.zero)
    let tap = UITapGestureRecognizer(target: self, action: #selector(selectIt))
    addGestureRecognizer(tap)
    NotificationCenter.default.addObserver(self,
      selector: #selector(onSelected(notification:)),
      name: NSNotification.Name(rawValue: CalendarSelectedDayNotification),
      object: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dateLabel.frame = bounds.insetBy(dx: 10, dy: 10) //(bounds, 10, 10)
    dateBackgroundView.frame = CGRect(x: dateLabel.frame.origin.x,
                                      y: dateLabel.frame.origin.y + (dateLabel.frame.size.height - dateLabel.frame.size.width) / 2,
                                      width: dateLabel.frame.size.width, height: dateLabel.frame.size.width)
    updateView()
  }

  @objc func onSelected(notification: NSNotification) {
    if let date = date, let nsDate = notification.object as? Date {
      let mo = moment(nsDate)
      if mo.month != date.month || mo.day != date.day {
        selected = false
      }
    }
  }

  func updateView() {
    DispatchQueue.main.async {
        if self.selected {
            self.dateLabel.textColor = CalendarView.daySelectedTextColor
            
            self.dateBackgroundView.backgroundColor = CalendarView.daySelectedBackgroundColor
            self.dateBackgroundView.layer.cornerRadius = min(self.dateLabel.frame.size.width, self.dateLabel.frame.size.height) / 2
            self.dateBackgroundView.layer.masksToBounds = true
            
            self.bringSubview(toFront: self.dateLabel)
        } else if self.isToday {
            
            self.dateLabel.textColor = CalendarView.todayTextColor
            self.dateBackgroundView.backgroundColor = CalendarView.todayBackgroundColor
            self.dateBackgroundView.layer.cornerRadius = min(self.dateLabel.frame.size.width, self.dateLabel.frame.size.height) / 2
            self.dateBackgroundView.layer.masksToBounds = true
            self.bringSubview(toFront: self.dateLabel)
            
        } else if self.isOtherMonth {
            
            self.dateLabel.textColor = CalendarView.otherMonthTextColor
            self.dateBackgroundView.backgroundColor = CalendarView.otherMonthBackgroundColor
            self.dateBackgroundView.layer.cornerRadius = min(self.dateLabel.frame.size.width, self.dateLabel.frame.size.height) / 2
            self.dateBackgroundView.layer.masksToBounds = true
            self.bringSubview(toFront: self.dateLabel)
            
        } else {
            self.dateLabel.textColor = CalendarView.dayTextColor
            self.dateBackgroundView.backgroundColor = CalendarView.dayBackgroundColor
        }
    }
  }

  @objc func selectIt() {
    selected = true
  }

}

public extension Moment {

  func toNSDate() -> Date? {
    let epoch = moment(Date(timeIntervalSince1970: 0))
    let timeInterval = self.intervalSince(epoch)
    let date = Date(timeIntervalSince1970: timeInterval.seconds)
    return date
  }

  func isToday() -> Bool {
    let cal = Calendar.current
    return cal.isDateInToday(self.toNSDate()!)
  }

  func isSameMonth(other: Moment) -> Bool {
    return self.month == other.month && self.year == other.year
  }

}
