//
//  OptionsPickerBottomSheetView.swift
//  Modacity
//
//  Created by BC Engineer on 11/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol OptionsPickerBottomSheetViewDelegate {
    func selectOptionInPickerBottomSheet(_ view: OptionsPickerBottomSheetView, optionIdx: Int, optionValue: String)
    func cancelOptionSelectInPickerBottomSheet(_ view: OptionsPickerBottomSheetView)
}

class OptionsPickerBottomSheetView: UIView {
    
    let cellHeight = CGFloat(60)
    
    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var viewContentBox: UIView!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var constraintForOptionsBoxHeight: NSLayoutConstraint!
    
    var delegate: OptionsPickerBottomSheetViewDelegate!
    var options = [String]()
    var selectedOptionIdx = -1
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("OptionsPickerBottomSheetView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewOptions.register(UINib(nibName: "OptionsPickerOptionCell", bundle: nil), forCellReuseIdentifier: "OptionsPickerOptionCell")
    }
    
    func configureOptions(_ options: [String]) {
        self.options = options
        self.tableViewOptions.reloadData()
        self.constraintForOptionsBoxHeight.constant = CGFloat(options.count) * cellHeight
    }
    
    @IBAction func onClosePicker(_ sender: Any) {
        self.delegate.cancelOptionSelectInPickerBottomSheet(self)
    }
}

extension OptionsPickerBottomSheetView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsPickerOptionCell") as! OptionsPickerOptionCell
        cell.configure(option: self.options[indexPath.row], selected: indexPath.row == selectedOptionIdx)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedOptionIdx = indexPath.row
        self.tableViewOptions.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.delegate.selectOptionInPickerBottomSheet(self, optionIdx: indexPath.row, optionValue: self.options[indexPath.row])
        }
    }
    
}
