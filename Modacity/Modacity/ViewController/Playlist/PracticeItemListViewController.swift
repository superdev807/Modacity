//
//  PracticeItemListViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeItemCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textfieldInputPracticeItemName: UITextField!
    @IBOutlet weak var ratingView: FloatRatingView!
    
    func configure(with name:String,
                   keyword: String,
                   isSelected:Bool,
                   rating: Double?) {
        
        if keyword == "" {
            self.labelPracticeItemName.attributedText = nil
            self.labelPracticeItemName.text = name
        } else {
            let range = NSString(string:name.lowercased()).range(of: keyword.lowercased())
            let attributed = NSMutableAttributedString(string: name)
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: Color.green], range: range)
            self.labelPracticeItemName.attributedText = attributed
        }
        
        if isSelected {
            self.imageViewIcon.image = UIImage(named:"icon_checked_white_large")
        } else {
            self.imageViewIcon.image = UIImage(named:"icon_plus")
        }
        
        self.textfieldInputPracticeItemName.text = name
        self.textfieldInputPracticeItemName.isHidden = true
        self.labelPracticeItemName.isHidden = false
        
        self.ratingView.contentMode = .scaleAspectFit
        if let rating = rating {
            self.ratingView.isHidden = false
            self.ratingView.rating = rating
        } else {
            self.ratingView.isHidden = true
        }
    }
    
    @IBAction func onEditingChangedOnPracticeItemNameField(_ sender: Any) {
        self.labelPracticeItemName.text = self.textfieldInputPracticeItemName.text
    }
    
}

class PracticeItemListViewController: UIViewController {

    @IBOutlet weak var viewEditboxContainer: UIView!
    @IBOutlet weak var viewStoreNewItemPanel: UIView!
    @IBOutlet weak var labelStoreNewItem: UILabel!
    @IBOutlet weak var textfieldSearch: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForTableViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForAddButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var buttonAddButton: UIButton!
    @IBOutlet weak var buttonRemoveKeyword: UIButton!
    @IBOutlet weak var constraintForHeaderImageViewConstant: NSLayoutConstraint!
    
    var practiceItemNameEditingCell: PracticeItemCell? = nil
    var editingRow: Int = 0
    
    var parentViewModel = PlaylistDetailsViewModel()
    
    private let viewModel = PracticeItemViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewConstant.constant = 108
        } else {
            self.constraintForHeaderImageViewConstant.constant = 88
        }
        self.configureGUI()
        self.bindViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func configureGUI() {
        self.viewEditboxContainer.layer.cornerRadius = 5
        self.viewStoreNewItemPanel.layer.cornerRadius = 25
        self.viewStoreNewItemPanel.isHidden = true
        self.tableViewMain.tableFooterView = UIView()
        self.constraintForTableViewTopSpace.constant = 10
        self.buttonAddButton.isHidden = true
        self.tableViewMain.sectionIndexBackgroundColor = Color.clear
        self.tableViewMain.sectionIndexColor = Color.white
        self.buttonRemoveKeyword.isHidden = true
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if AppUtils.iphoneIsXModel() {
                self.constraintForAddButtonBottomSpace.constant = keyboardSize.height - 34
            } else {
                self.constraintForAddButtonBottomSpace.constant = keyboardSize.height
            }
        }
    }
    
    @objc func onKeyboardWillHide() {
        self.constraintForAddButtonBottomSpace.constant = 0
        self.cancelCellEditingMode()
    }
    
    func bindViewModel() {
        self.viewModel.subscribe(to: "sectionedResult") { (event, _, _) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "selectedItems") { (event, _, _) in
            if self.viewModel.selectedItems.count > 0 {
                self.buttonAddButton.isHidden = false
                self.buttonAddButton.setTitle("Add \(self.viewModel.selectedItems.count) practice", for: .normal)
            } else {
                self.buttonAddButton.isHidden = true
            }
            
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.loadItemNames()
    }
}

extension PracticeItemListViewController {
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddtoStore(_ sender: Any) {
        self.viewModel.addItemtoStore(with: self.textfieldSearch.text!)
        self.viewStoreNewItemPanel.isHidden = true
        self.constraintForTableViewTopSpace.constant = 10
        
        self.textfieldSearch.text = ""
        self.buttonRemoveKeyword.isHidden = true
        self.viewModel.changeKeyword(to: "")
    }
    
    @IBAction func cancelCellEditingMode() {
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.isHidden = true
            self.practiceItemNameEditingCell!.labelPracticeItemName.isHidden = false
            self.viewModel.replaceItem(name: self.viewModel.searchResult(at: self.editingRow), to: self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.text ?? "")
            self.practiceItemNameEditingCell = nil
        }
    }
    
    @IBAction func onSelectItems(_ sender: Any) {
        self.parentViewModel.addPracticeItems(itemNames: self.viewModel.selectedItems)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension PracticeItemListViewController: UITextFieldDelegate {
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        let newKeyword = self.textfieldSearch.text ?? ""
        if newKeyword != "" && !self.viewModel.practiceItemContains(itemName: newKeyword) {
            self.viewStoreNewItemPanel.isHidden = false
            self.labelStoreNewItem.text = "Add practice \"\(newKeyword)\"."
            self.constraintForTableViewTopSpace.constant = 100
        } else {
            self.viewStoreNewItemPanel.isHidden = true
            self.labelStoreNewItem.text = ""
            self.constraintForTableViewTopSpace.constant = 10
        }
        self.buttonRemoveKeyword.isHidden = (newKeyword == "")
        self.viewModel.changeKeyword(to: newKeyword)
    }
    
    @IBAction func onRemoveKeyword(_ sender: Any) {
        self.textfieldSearch.text = ""
        self.buttonRemoveKeyword.isHidden = true
        self.viewModel.changeKeyword(to: "")
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.textfieldSearch.resignFirstResponder()
    }
}

extension PracticeItemListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionedSearchSectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionedSearchResultCount(in: section)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.viewModel.sortedSectionedResult()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableViewMain.frame.size.width, height:33))
        returnedView.backgroundColor = Color.white.alpha(0.3)
        
        let label = UILabel(frame: CGRect(x:10, y:0, width:tableViewMain.frame.size.width - 20, height:33))
        label.text = self.viewModel.sortedSectionedResult()[section]
        label.textColor = Color.white
        label.font = UIFont(name: AppConfig.appFontLatoBold, size: 14)
        returnedView.addSubview(label)
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemCell
        let itemName = self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row)
        cell.configure(with: itemName,
                       keyword: self.textfieldSearch.text ?? "",
                       isSelected: self.viewModel.isSelected(for: itemName),
                       rating: self.viewModel.ratingValue(forPracticeItem: itemName))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.selectItem(for: self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.practiceItemNameEditingCell == nil {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            self.viewModel.removePracticeItem(for: self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row))
        }
        delete.setIcon(iconImage: UIImage(named:"icon_delete_white")!, backColor: Color(hexString: "#6815CE"), cellHeight: 64, iconSizePercentage: 0.25)
        let edit = UITableViewRowAction(style: .default, title: "") { (action, indexPath) in
            if let cell = self.tableViewMain.cellForRow(at: indexPath) as? PracticeItemCell {
                self.practiceItemNameEditingCell = cell
                self.editingRow = indexPath.row
                cell.textfieldInputPracticeItemName.isHidden = false
                cell.labelPracticeItemName.isHidden = true
                cell.textfieldInputPracticeItemName.becomeFirstResponder()
            }
        }
        edit.setIcon(iconImage: UIImage(named:"icon_pen_white")!, backColor: Color(hexString: "#2E64E5"), cellHeight: 64, iconSizePercentage: 0.25)
        
        return [delete, edit]        
    }
}
