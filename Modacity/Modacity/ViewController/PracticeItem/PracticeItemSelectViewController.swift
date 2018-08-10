//
//  PracticeItemSelectViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeItemSelectViewController: UIViewController {

    @IBOutlet weak var viewEditboxContainer: UIView!
    @IBOutlet weak var viewStoreNewItemPanel: UIView!
    @IBOutlet weak var labelStoreNewItem: UILabel!
    @IBOutlet weak var textfieldSearch: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForTableViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintForAddButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var buttonRemoveKeyword: UIButton!
    @IBOutlet weak var constraintForHeaderImageViewConstant: NSLayoutConstraint!
    
    @IBOutlet weak var viewAddPracticeButtonContainer: UIView!
    @IBOutlet weak var constraintForAddPracticeButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewWalkthrough: UIView!
    @IBOutlet weak var imageViewWalkThrough2: UIImageView!
    @IBOutlet weak var labelWalkThrough2: UILabel!
    
    var parentController : PlaylistContentsViewController?
    
    var practiceItemNameEditingCell: PracticeItemSelectCell? = nil
    var editingSection: Int = 0
    var editingRow: Int = 0
    
    var parentViewModel = PlaylistContentsViewModel()
    var shouldSelectPracticeItems = false
    var animatedShowing = false
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.ascending
    
    private let viewModel = PracticeItemViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewConstant.constant = 108
        } else {
            self.constraintForHeaderImageViewConstant.constant = 88
        }
        self.sortKey = AppOveralDataManager.manager.sortKey()
        self.sortOption = AppOveralDataManager.manager.sortOption()
        self.configureGUI()
        self.bindViewModel()
        self.processWalkthrough()
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_sort" {
            let controller = segue.destination as! SortOptionsViewController
            controller.sortOption = self.sortOption
            controller.sortKey = self.sortKey
            controller.delegate = self
        }
    }

    func configureGUI() {
        self.viewEditboxContainer.layer.cornerRadius = 5
        self.viewStoreNewItemPanel.layer.cornerRadius = 25
        self.viewStoreNewItemPanel.isHidden = true
        self.tableViewMain.tableFooterView = UIView()
        self.constraintForTableViewTopSpace.constant = 4
        self.viewAddPracticeButtonContainer.isHidden = true
        self.constraintForAddPracticeButtonHeight.constant = 0
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
        
        self.viewModel.sortOption = self.sortOption
        self.viewModel.sortKey = self.sortKey
        
        self.viewModel.subscribe(to: "sectionedPracticeItems") { (event, _, _) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "selectedPracticeItems") { (event, _, _) in
            if self.viewModel.selectedPracticeItems.count > 0 {
                self.viewAddPracticeButtonContainer.isHidden = false
                self.constraintForAddPracticeButtonHeight.constant = 64 / 375 * UIScreen.main.bounds.size.width
            } else {
                self.viewAddPracticeButtonContainer.isHidden = true
                self.constraintForAddPracticeButtonHeight.constant = 0
            }
            
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.loadItemNames()
    }
    
    func processWalkthrough() {
        if !AppOveralDataManager.manager.walkThroughDoneForSecondPage() {
            showPracticeItemWalkThrough()
        } else {
            self.viewWalkthrough.isHidden = true
        }
    }
    
    func showPracticeItemWalkThrough() {
        ModacityAnalytics.LogStringEvent("Walkthrough - PracticeItem - Displayed")
        self.viewWalkthrough.alpha = 0
        self.imageViewWalkThrough2.alpha = 0
        self.labelWalkThrough2.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkthrough.alpha = 1
        }) { (finished) in
            if finished {
                if self.viewModel.sectionedSearchSectionCount() > 0 {
                    self.imageViewWalkThrough2.alpha = 1
                    self.labelWalkThrough2.alpha = 1
                }
            }
        }
    }
    
    @IBAction func onDismissWalkThrough(_ sender: Any) {
        self.dismissWalkThrough(withSetting: false)
    }
    
    func dismissWalkThrough(withSetting: Bool) {
        ModacityAnalytics.LogStringEvent("Walkthrough - PracticeItem - Dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkthrough.alpha = 0
        }) { (finished) in
            self.viewWalkthrough.isHidden = true
            if self.viewModel.practiceItems.count > 0 {
                if withSetting {
                    // this never happens, should we remove this code?
                    // withSetting is always false in the current code
                    AppOveralDataManager.manager.walkThroughSecondPage()
                }
            }
        }
    }
}

extension PracticeItemSelectViewController {
    
    @IBAction func onBack(_ sender: Any) {

        if let parentController = self.parentController {
            if parentController.shouldStartFromPracticeSelection {
                self.navigationController?.dismiss(animated: self.animatedShowing, completion: nil)
                return
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddtoStore(_ sender: Any) {
        let newName = self.textfieldSearch.text!
        ModacityAnalytics.LogStringEvent("Created Practice Item", extraParamName: "name", extraParamValue: newName)
        self.viewModel.addItemtoStore(with: self.textfieldSearch.text!)
        self.viewStoreNewItemPanel.isHidden = true
        self.constraintForTableViewTopSpace.constant = 4
        
        self.textfieldSearch.text = ""
        self.buttonRemoveKeyword.isHidden = true
        self.viewModel.changeKeyword(to: "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollTableView(to:newName)
        }
    }
    
    func scrollTableView(to name:String) {
        for section in 0..<self.viewModel.sectionedSearchSectionCount() {
            for row in 0..<self.viewModel.sectionedSearchResultCount(in: section) {
                let item = self.viewModel.sectionResult(section: section, row: row)
                if item.name.lowercased() == name.lowercased() {
                    self.tableViewMain.scrollToRow(at: IndexPath(row: row, section: section), at: .top, animated: true)
                    return
                }
            }
        }
    }
    
    @IBAction func cancelCellEditingMode() {
        
        self.dismissWalkThrough(withSetting: false)
        
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.isHidden = true
            let originalPracticeItemName = self.viewModel.sectionResult(section: self.editingSection, row: self.editingRow).name
            let newPracticeItemName = self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.text ?? ""
            if newPracticeItemName != originalPracticeItemName {
                if newPracticeItemName == "" {
                    self.practiceItemNameEditingCell!.labelPracticeItemName.text = originalPracticeItemName
                } else if self.viewModel.canChangeItemName(to: newPracticeItemName, forItem: self.viewModel.sectionResult(section: self.editingSection, row: self.editingRow)) {
                    self.viewModel.changeItemName(to: newPracticeItemName, forItem: self.viewModel.sectionResult(section: self.editingSection, row: self.editingRow))
                } else {
                    self.practiceItemNameEditingCell!.labelPracticeItemName.text = originalPracticeItemName
                    self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.text = originalPracticeItemName
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "You've already same practice item name.")
                }
            }
            self.practiceItemNameEditingCell!.labelPracticeItemName.isHidden = false
            self.practiceItemNameEditingCell = nil
        }
    }
    
    @IBAction func onSelectItems(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Added Practice Item to Playlist", extraParamName: "Item Count", extraParamValue: self.viewModel.selectedPracticeItems.count)
        
        AppOveralDataManager.manager.walkThroughSecondPage()
        
        if !AppOveralDataManager.manager.firstPlaylistGenerated() {
            AppOveralDataManager.manager.generatedFirstPlaylist()
        }
        
        self.parentViewModel.addPracticeItems(self.viewModel.selectedPracticeItems)
        if let parentController = self.parentController {
            parentController.practiceItemsSelected()
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension PracticeItemSelectViewController: UITextFieldDelegate {
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        let newKeyword = self.textfieldSearch.text ?? ""
        if newKeyword != "" && !self.viewModel.practiceItemContains(itemName: newKeyword) {
            self.viewStoreNewItemPanel.isHidden = false
            self.labelStoreNewItem.text = "\(newKeyword)"
            self.constraintForTableViewTopSpace.constant = 74
        } else {
            self.viewStoreNewItemPanel.isHidden = true
            self.labelStoreNewItem.text = ""
            self.constraintForTableViewTopSpace.constant = 4
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
        if !self.viewStoreNewItemPanel.isHidden {
            self.onAddtoStore(sender)
        }
    }
}

extension PracticeItemSelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionedSearchSectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sectionedSearchResultCount(in: section)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.viewModel.sortKey == .name {
            return self.viewModel.sortedSectionedResult()
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableViewMain.frame.size.width, height:40))
        returnedView.backgroundColor = Color(hexString: "#3c385a")

        let label = UILabel(frame: CGRect(x:10, y:0, width:tableViewMain.frame.size.width - 20, height:24))
        label.text = self.viewModel.sortedSectionedResult()[section]
        label.textColor = Color.white.alpha(0.8)
        label.font = UIFont(name: AppConfig.appFontLatoRegular, size: 14)
        returnedView.addSubview(label)

        return returnedView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemSelectCell
        let item = self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row)
        cell.configure(with: item,
                       rate: self.viewModel.ratingValue(forPracticeItem: item) ?? 0,
                       keyword: self.textfieldSearch.text ?? "",
                       isSelected: self.viewModel.isSelected(for: item),
                       indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.viewModel.selectItem(for: self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row))
    }
    
}

extension PracticeItemSelectViewController: PracticeItemSelectCellDelegate {
    
    func onCellMenu(menuButton: UIButton, indexPath: IndexPath) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: menuButton,
                                       rows: [["icon":"icon_notes", "text":"Details"],
                                              ["icon":"icon_pen_white", "text":"Rename"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                self.processAction(row, indexPath)
        }
        
    }
    
    func processAction(_ row: Int, _ indexPath: IndexPath) {
        if row == 1 {
            if let cell = self.tableViewMain.cellForRow(at: indexPath) as? PracticeItemSelectCell {
                self.practiceItemNameEditingCell = cell
                self.editingSection = indexPath.section
                self.editingRow = indexPath.row
                cell.textfieldInputPracticeItemName.isHidden = false
                cell.labelPracticeItemName.isHidden = true
                cell.textfieldInputPracticeItemName.becomeFirstResponder()
            }
        } else if row == 2 {
            self.viewModel.removePracticeItem(for: self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row))
            self.parentViewModel.checkPlaylistForPracticeItemRemoved()
        } else {
            self.openDetails(self.viewModel.sectionResult(section: indexPath.section, row: indexPath.row).id)
        }
    }
    
    func openDetails(_ practiceItemId:String) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
        let detailsViewController = controller.viewControllers[0] as! DetailsViewController
        detailsViewController.practiceItemId = practiceItemId
        self.present(controller, animated: true, completion: nil)
        
        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId) {
            ModacityAnalytics.LogStringEvent("Selected Practice Item", extraParamName: "Name", extraParamValue: practice.name)
        }
    }
}

extension PracticeItemSelectViewController: SortOptionsViewControllerDelegate {
    func changeOptions(key: SortKeyOption, option: SortOption) {
        self.sortKey = key
        self.sortOption = option
        AppOveralDataManager.manager.saveSortKey(self.sortKey)
        AppOveralDataManager.manager.saveSortOption(self.sortOption)
        self.viewModel.changeSort(key: key, option: option)
    }
}
