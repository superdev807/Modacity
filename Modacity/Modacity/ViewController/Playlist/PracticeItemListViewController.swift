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
    
    func configure(with name:String,
                   keyword: String,
                   isSelected:Bool) {
        
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
    
    var practiceItemNameEditingCell: PracticeItemCell? = nil
    var editingRow: Int = 0
    
    var parentViewModel = PlaylistDetailsViewModel()
    
    private let viewModel = PracticeItemViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForAddButtonBottomSpace.constant = keyboardSize.height
        }
    }
    
    @objc func onKeyboardWillHide() {
        self.constraintForAddButtonBottomSpace.constant = 0
        self.cancelCellEditingMode()
    }
    
    func bindViewModel() {
        
        self.viewModel.selectedItems = self.parentViewModel.practiceItems
        
        self.viewModel.subscribe(to: "searchResult") { (event, _, _) in
            if event != .deleted {
                self.tableViewMain.reloadData()
            }
        }
        
        self.viewModel.subscribe(to: "selectedItems") { (_, _, _) in
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
//        self.textfieldSearch.text = ""
        self.viewStoreNewItemPanel.isHidden = true
        self.constraintForTableViewTopSpace.constant = 10
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
        self.parentViewModel.practiceItems = self.viewModel.selectedItems
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
        self.viewModel.changeKeyword(to: newKeyword)
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.textfieldSearch.resignFirstResponder()
    }
}

extension PracticeItemListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.searchResultCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemCell
        cell.configure(with: self.viewModel.searchResult(at: indexPath.row),
                       keyword: self.textfieldSearch.text ?? "",
                       isSelected: self.viewModel.isSelected(for: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.selectItem(at: indexPath.row)
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
            self.viewModel.removePracticeItem(at: indexPath.row)
            self.tableViewMain.deleteRows(at: [indexPath], with: .automatic)
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
