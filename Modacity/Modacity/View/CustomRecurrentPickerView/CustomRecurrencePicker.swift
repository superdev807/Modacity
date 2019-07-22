//
//  CustomRecurrencePicker.swift
//  Modacity
//
//  Created by BC Engineer on 11/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol CustomRecurrencePickerDelegate {
    func closeCustomRecurrencePickerView(_ view: CustomRecurrencePicker)
    func selectCustomRecurrence(everyMode: Int, onWeeks: [Int], onDays: [Int], endsMode: Int, endsDate: Date?)
}

class CustomRecurrencePicker: UIView {
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var viewContentBox: UIView!
    @IBOutlet weak var collectionViewRepeatOn: UICollectionView!
    
    @IBOutlet weak var imageViewOptionRepeatEveryWeek: UIImageView!
    @IBOutlet weak var imageviewOptionRepeatEveryMonth: UIImageView!
    @IBOutlet weak var imageViewOptionEndsNever: UIImageView!
    @IBOutlet weak var imageViewOptionEndsAfter: UIImageView!
    @IBOutlet weak var viewAfterTimeBox: UIView!
    @IBOutlet weak var labelAfterTime: UILabel!
    
    @IBOutlet weak var viewAfterTimePickerBox: UIView!
    @IBOutlet weak var viewAfterTimePickerContainer: UIView!
    @IBOutlet weak var pickerViewAfterTime: UIPickerView!
    
    let labelWeeks = ["S", "M", "T", "W", "T", "F", "S"]
    
    var delegate: CustomRecurrencePickerDelegate!
    
    var repeatEveryMode = 0     // 0 for week, 1 for month
    var selectedRepeatOnWeeks = [Int]()
    var selectedRepeatOnDays = [Int]()
    var repeatEndsMode = 0      // 0 for never, 1 for after
    
//    var repeatEndsAfterNumber = 1
//    var repeatEndsAfterUnit = 0 // 0 for day, 1 for week, 2 for month
    
    var repeatEndsAfterDate: Date?
    
    var calendarOverlayView: CalendarOverlayView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomRecurrencePicker", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.viewContentBox.layer.cornerRadius = 5
        self.buttonDone.layer.cornerRadius = 28
        
        self.collectionViewRepeatOn.register(UINib(nibName: "RepeatOnCell", bundle: nil), forCellWithReuseIdentifier: "RepeatOnCell")
        
        configureRepeatEveryMode()
        configureEnds()
        self.configureRepeatEndsAfterTime()
        self.viewAfterTimePickerBox.isHidden = true
    }
    
    func configure(with custom: ReminderCustomRepeatData?) {
        if let custom = custom {
            self.repeatEveryMode = custom.everyMode
            self.selectedRepeatOnDays = custom.onDays
            self.selectedRepeatOnWeeks = custom.onWeeks
            self.repeatEndsAfterDate = custom.repeatEndDate()
//            self.repeatEndsAfterNumber = custom.endsNumber
//            self.repeatEndsAfterUnit = custom.endsUnit
            self.repeatEndsMode = custom.endsMode
            
            configureRepeatEveryMode()
            configureEnds()
            self.configureRepeatEndsAfterTime()
        }
    }
    
    func configureRepeatEveryMode() {
        self.imageViewOptionRepeatEveryWeek.image = UIImage(named: "icon_option_normal")
        self.imageviewOptionRepeatEveryMonth.image = UIImage(named: "icon_option_normal")
        
        if (self.repeatEveryMode == 0) {
            self.imageViewOptionRepeatEveryWeek.image = UIImage(named: "icon_option_selected")
        } else {
            self.imageviewOptionRepeatEveryMonth.image = UIImage(named: "icon_option_selected")
        }
        
        self.collectionViewRepeatOn.reloadData()
    }
    
    func configureEnds() {
        self.imageViewOptionEndsNever.image = UIImage(named: "icon_option_normal")
        self.imageViewOptionEndsAfter.image = UIImage(named: "icon_option_normal")
        
        if (self.repeatEndsMode == 0) {
            self.imageViewOptionEndsNever.image = UIImage(named: "icon_option_selected")
            self.viewAfterTimeBox.isHidden = true
        } else {
            self.imageViewOptionEndsAfter.image = UIImage(named: "icon_option_selected")
            self.viewAfterTimeBox.isHidden = false
        }
    }

    @IBAction func onDone(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.selectCustomRecurrence(everyMode: self.repeatEveryMode,
                                            onWeeks: self.selectedRepeatOnWeeks,
                                            onDays: self.selectedRepeatOnDays,
                                            endsMode: self.repeatEndsMode,
                                            endsDate: self.repeatEndsAfterDate)
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.closeCustomRecurrencePickerView(self)
        }
    }
    
    @IBAction func onRepeatEveryWeeks(_ sender: Any) {
        self.repeatEveryMode = 0
        self.configureRepeatEveryMode()
    }
    
    @IBAction func onRepeatEveryMonth(_ sender: Any) {
        self.repeatEveryMode = 1
        self.configureRepeatEveryMode()
    }
    
    @IBAction func onEndsNever(_ sender: Any) {
        self.repeatEndsMode = 0
        self.configureEnds()
    }
    
    @IBAction func onEndsAfter(_ sender: Any) {
        self.repeatEndsMode = 1
        self.configureEnds()
    }
    
    @IBAction func onAfterTimeTap(_ sender: Any) {
        self.showAfterTimeSelectPicker()
    }
    
    @IBAction func onCancelSelectAfterTime(_ sender: Any) {
        self.hideAfterTimeSelectPicker()
    }
    
    @IBAction func onSelectAfterTime(_ sender: Any) {
//        self.repeatEndsAfterNumber = self.pickerViewAfterTime.selectedRow(inComponent: 0) + 1
//        self.repeatEndsAfterUnit = self.pickerViewAfterTime.selectedRow(inComponent: 1)
        self.configureRepeatEndsAfterTime()
        self.hideAfterTimeSelectPicker()
    }
    
    func configureRepeatEndsAfterTime() {
        if let date = self.repeatEndsAfterDate {
            self.labelAfterTime.text = date.localeDisplay(dateStyle: .medium)//toString(format: "MMM d, yyyy")
            self.labelAfterTime.textColor = Color.darkGray
        } else {
            self.labelAfterTime.text = "Select End Date"
            self.labelAfterTime.textColor = AppConfig.UI.AppColors.placeholderTextColorGray
        }
//        self.labelAfterTime.text = "\(self.repeatEndsAfterNumber) \(["day", "week", "month"][self.repeatEndsAfterUnit])\(self.repeatEndsAfterNumber > 1 ? "s" : "")"
    }
}

extension CustomRecurrencePicker: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.repeatEveryMode == 0 ? 7 : 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RepeatOnCell", for: indexPath) as! RepeatOnCell
        if self.repeatEveryMode == 0 {
            cell.configure(label: labelWeeks[indexPath.row], selected: self.selectedRepeatOnWeeks.contains(indexPath.row))
        } else {
            cell.configure(label: "\(indexPath.row + 1)", selected: self.selectedRepeatOnDays.contains(indexPath.row))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.repeatEveryMode == 0 {
            if self.selectedRepeatOnWeeks.contains(indexPath.row) {
                for idx in 0..<self.selectedRepeatOnWeeks.count {
                    if self.selectedRepeatOnWeeks[idx] == indexPath.row {
                        self.selectedRepeatOnWeeks.remove(at: idx)
                        break
                    }
                }
            } else {
                self.selectedRepeatOnWeeks.append(indexPath.row)
            }
            
        } else {
            if self.selectedRepeatOnDays.contains(indexPath.row) {
                for idx in 0..<self.selectedRepeatOnDays.count {
                    if self.selectedRepeatOnDays[idx] == indexPath.row {
                        self.selectedRepeatOnDays.remove(at: idx)
                        break
                    }
                }
            } else {
                self.selectedRepeatOnDays.append(indexPath.row)
            }
        }
        
        self.collectionViewRepeatOn.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.repeatEveryMode == 0 {
            return CGSize(width: (UIScreen.main.bounds.size.width - 55 - 20) / 7, height: 40)
        } else {
            return CGSize(width: 40, height: 40)
        }
    }
    
}

extension CustomRecurrencePicker: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 10
        } else {
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row + 1)"
        } else {
            return ["Day", "Week", "Month"][row]
        }
    }
    
    func showAfterTimeSelectPicker() {
        
        let view = CalendarOverlayView()
        self.viewContent.addSubview(view)
        
        view.bottomAnchor.constraint(equalTo: self.viewContent.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.viewContent.topAnchor, constant: -20).isActive = true
        view.leadingAnchor.constraint(equalTo: self.viewContent.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.viewContent.trailingAnchor).isActive = true
        
        view.delegate = self
        
        if let date = self.repeatEndsAfterDate {
            view.selectDate(date)
        }
        
        self.calendarOverlayView = view
//        self.viewAfterTimePickerBox.isHidden = false
//
//        self.viewAfterTimePickerContainer.frame = CGRect(x: 0, y: self.viewContent.frame.size.height, width: self.viewAfterTimePickerContainer.frame.size.width, height: self.viewAfterTimePickerContainer.frame.size.height)
//        UIView.animate(withDuration: 0.5, animations: {
//            self.viewAfterTimePickerContainer.frame = CGRect(x: 0, y: self.viewContent.frame.size.height - self.viewAfterTimePickerContainer.frame.size.height, width: self.viewAfterTimePickerContainer.frame.size.width, height: self.viewAfterTimePickerContainer.frame.size.height)
//        }) { (_) in
//
//        }
    }
    
    func hideAfterTimeSelectPicker() {
        
        self.calendarOverlayView.removeFromSuperview()
//        self.viewAfterTimePickerContainer.frame = CGRect(x: 0, y: self.viewContent.frame.size.height - self.viewAfterTimePickerContainer.frame.size.height, width: self.viewAfterTimePickerContainer.frame.size.width, height: self.viewAfterTimePickerContainer.frame.size.height)
//        UIView.animate(withDuration: 0.5, animations: {
//            self.viewAfterTimePickerContainer.frame = CGRect(x: 0, y: self.viewContent.frame.size.height, width: self.viewAfterTimePickerContainer.frame.size.width, height: self.viewAfterTimePickerContainer.frame.size.height)
//        }) { (_) in
//            self.viewAfterTimePickerBox.isHidden = true
//        }
    }
}

extension CustomRecurrencePicker: CalendarOverlayViewDelegate {
    func selectedDateOnCalendarOverlayView(_ view: CalendarOverlayView, date: Date) {
        self.repeatEndsAfterDate = date
        self.configureRepeatEndsAfterTime()
        self.hideAfterTimeSelectPicker()
    }
    
    func cancelOnCalendarOverlayView(_ view: CalendarOverlayView) {
        self.hideAfterTimeSelectPicker()
    }
}
