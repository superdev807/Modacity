//
//  PracticeItemSelectViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/28/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

typealias CompletedAction = () -> ()

class PracticeItemSelectViewController: UIViewController {

    @IBOutlet weak var viewEditboxContainer: UIView!
//    @IBOutlet weak var viewStoreNewItemPanel: UIView!
//    @IBOutlet weak var labelStoreNewItem: UILabel!
    
    @IBOutlet weak var textfieldSearch: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!
//    @IBOutlet weak var constraintForTableViewTopSpace: NSLayoutConstraint!
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
    
    var dataDelivered = false
    
    var practiceItems: [PracticeItem]? = nil
    var filteredPracticeItems: [PracticeItem]? = nil
    var sectionNames = [String]()
    var sectionedPracticeItems = [String:[PracticeItem]]()
    
    var selectedPracticeItems: [PracticeItem] = [PracticeItem]()
    
    var firstAppearing = true
    
    var searchKeyword = ""
    
    var processingSelectItems = false
    
    var tableHeaderShowing = false
    var tableHeaderKeyword = ""
    
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
        if !dataDelivered {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.updateList()
        } else {
            self.tableViewMain.reloadData()
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !firstAppearing {
            self.sortKey = AppOveralDataManager.manager.sortKey()
            self.sortOption = AppOveralDataManager.manager.sortOption()
            self.updateList()
        } else {
            firstAppearing = false
        }
    }
    
    func configureGUI() {
//        self.viewEditboxContainer.layer.cornerRadius = 5
//        self.viewStoreNewItemPanel.layer.cornerRadius = 25
//        self.viewStoreNewItemPanel.isHidden = true
//        self.constraintForTableViewTopSpace.constant = 4
        self.tableViewMain.tableFooterView = UIView()
        self.viewAddPracticeButtonContainer.isHidden = true
        self.constraintForAddPracticeButtonHeight.constant = 0
        self.tableViewMain.sectionIndexBackgroundColor = Color.clear
        self.tableViewMain.sectionIndexColor = Color.white
        self.buttonRemoveKeyword.isHidden = true
        self.viewEditboxContainer.layer.cornerRadius = 5
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
    
    func processWalkthrough() {
        if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_second_page") {
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
                if (self.practiceItems?.count ?? 0) > 0 {
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
            AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_second_page", value: true)
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
    
    func updateKeyword() {
        let newKeyword = self.textfieldSearch.text ?? ""
        tableHeaderKeyword = newKeyword
        if newKeyword != "" && !self.practiceItemContains(for: newKeyword) {
            tableHeaderShowing = true
        } else {
            tableHeaderShowing = false
        }
        self.refreshList()
        self.buttonRemoveKeyword.isHidden = (newKeyword == "")
    }
    
    func addNewPracticeItem() {
        
        let newName = tableHeaderKeyword
        
        ModacityAnalytics.LogStringEvent("Created Practice Item", extraParamName: "name", extraParamValue: newName)
        
        let practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = tableHeaderKeyword
        
        if self.practiceItems == nil {
            self.practiceItems = [PracticeItem]()
        }
        
        self.practiceItems!.append(practiceItem)
        
        PracticeItemLocalManager.manager.storePracticeItems(self.practiceItems!)
        PracticeItemRemoteManager.manager.add(item: practiceItem)
        
        tableHeaderShowing = false
        tableHeaderKeyword = ""
        
        self.textfieldSearch.text = ""
        self.buttonRemoveKeyword.isHidden = true
        self.tableHeaderKeyword = ""
        self.searchKeyword = ""
        self.selectedPracticeItems.append(practiceItem)
        
        self.updateKeyword()
        self.updateList()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.scrollTableView(to:newName)
        }
    }
    
//    @IBAction func onAddtoStore(_ sender: Any) {
//        let newName = self.textfieldSearch.text!
//        ModacityAnalytics.LogStringEvent("Created Practice Item", extraParamName: "name", extraParamValue: newName)
//        MBProgressHUD.showAdded(to: self.view, animated: true)
//        DispatchQueue.global().async {
//            self.addNewPracticeItem(newName)
//            self.searchKeyword = ""
//            self.updateList(completed: {
////                self.viewStoreNewItemPanel.isHidden = true
////                self.constraintForTableViewTopSpace.constant = 4
//                self.textfieldSearch.text = ""
//                self.buttonRemoveKeyword.isHidden = true
//                self.scrollTableView(to:newName)
//            })
//        }
//    }
//
//    func addNewPracticeItem(_ newName: String) {
//
//        ModacityAnalytics.LogStringEvent("Created Practice Item", extraParamName: "name", extraParamValue: newName)
//
//        let practiceItem = PracticeItem()
//        practiceItem.id = UUID().uuidString
//        practiceItem.name = newName
//
//        if self.practiceItems == nil {
//            self.practiceItems = [PracticeItem]()
//        }
//
//        self.practiceItems!.append(practiceItem)
//
//        PracticeItemLocalManager.manager.storePracticeItems(self.practiceItems!)
//        PracticeItemRemoteManager.manager.add(item: practiceItem)
//
//    }

    func scrollTableView(to name:String) {
        for section in 0..<self.sectionNames.count {
            for row in 0..<self.sectionedPracticeItems[self.sectionNames[section]]!.count {
                let item = self.sectionedPracticeItems[self.sectionNames[section]]![row]
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
            if let originalPracticeItemName = self.sectionedPracticeItems[self.sectionNames[self.editingSection]]?[self.editingRow].name {
                let newPracticeItemName = self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.text ?? ""
                if newPracticeItemName != originalPracticeItemName {
                    if newPracticeItemName == "" {
                        self.practiceItemNameEditingCell!.labelPracticeItemName.text = originalPracticeItemName
                    } else if self.canChangeItemName(to: newPracticeItemName, forItem: self.sectionedPracticeItems[self.sectionNames[self.editingSection]]![self.editingRow]) {
                        self.changeItemName(to: newPracticeItemName, forItem: self.sectionedPracticeItems[self.sectionNames[self.editingSection]]![self.editingRow])
                    } else {
                        self.practiceItemNameEditingCell!.labelPracticeItemName.text = originalPracticeItemName
                        self.practiceItemNameEditingCell!.textfieldInputPracticeItemName.text = originalPracticeItemName
                        AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "You've already same practice item name.")
                    }
                }
            }
            self.practiceItemNameEditingCell!.labelPracticeItemName.isHidden = false
            self.practiceItemNameEditingCell = nil
        }
    }
    
    func canChangeItemName(to: String, forItem: PracticeItem) -> Bool {
        if let practiceItems = self.practiceItems {
            for idx in 0..<practiceItems.count {
                let selectedItem = practiceItems[idx]
                if selectedItem.id != forItem.id && selectedItem.name == to {
                    return false
                }
            }
        }
        return true
    }
    
    func changeItemName(to: String, forItem: PracticeItem) {
        forItem.name = to
        forItem.updateMe()
    }
    
    @IBAction func onSelectItems(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Added Practice Item to Playlist", extraParamName: "Item Count", extraParamValue: self.selectedPracticeItems.count)
        
        AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_second_page", value: true)
        
        if !AppOveralDataManager.manager.firstPlaylistGenerated() {
            AppOveralDataManager.manager.generatedFirstPlaylist()
        }
        
        self.parentViewModel.addPracticeItems(self.selectedPracticeItems)
        if let parentController = self.parentController {
            parentController.practiceItemsSelected()
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension PracticeItemSelectViewController: UITextFieldDelegate {
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        self.searchKeyword = self.textfieldSearch.text ?? ""
        self.updateKeyword()
//        let newKeyword = self.textfieldSearch.text ?? ""
//        if newKeyword != "" && !self.practiceItemContains(for: newKeyword) {
////            self.viewStoreNewItemPanel.isHidden = false
////            self.labelStoreNewItem.text = "\(newKeyword)"
////            self.constraintForTableViewTopSpace.constant = 74
//        } else {
////            self.viewStoreNewItemPanel.isHidden = true
////            self.labelStoreNewItem.text = ""
////            self.constraintForTableViewTopSpace.constant = 4
//        }
//        self.buttonRemoveKeyword.isHidden = (newKeyword == "")
//        self.refreshList()
    }
    
    func practiceItemContains(for name: String) -> Bool {
        if let practiceItems = self.practiceItems {
            for practiceItem in practiceItems {
                if practiceItem.name.lowercased() == name.lowercased() {
                    return true
                }
            }
        }
        
        return false
    }
    
    @IBAction func onRemoveKeyword(_ sender: Any) {
        self.textfieldSearch.text = ""
        self.searchKeyword = ""
        self.buttonRemoveKeyword.isHidden = true
        self.updateKeyword()
//        self.textfieldSearch.text = ""
//        self.buttonRemoveKeyword.isHidden = true
//        self.searchKeyword = ""
//        self.refreshList()
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.textfieldSearch.resignFirstResponder()
        self.updateKeyword()
//        if !self.viewStoreNewItemPanel.isHidden {
//            self.onAddtoStore(sender)
//        }
    }
}

extension PracticeItemSelectViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionNames.count + (tableHeaderShowing ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableHeaderShowing && section == 0 {
            return 0
        } else {
            return 28
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableHeaderShowing && section == 0 {
            return nil
        } else {
            let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableViewMain.frame.size.width, height:40))
            returnedView.backgroundColor = Color(hexString: "#3c385a")
            
            let label = UILabel(frame: CGRect(x:10, y:0, width:tableViewMain.frame.size.width - 20, height:24))
            label.text = "\(self.sectionNames[section - (tableHeaderShowing ? 1: 0)])"
            label.textColor = Color.white.alpha(0.8)
            label.font = UIFont(name: AppConfig.appFontLatoRegular, size: 14)
            returnedView.addSubview(label)
            
            return returnedView
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableHeaderShowing && section == 0 {
            return 1
        } else {
            return self.sectionedPracticeItems[self.sectionNames[section - (tableHeaderShowing ? 1 : 0)]]?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableHeaderShowing && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemHeaderCell") as! PracticeItemHeaderCell
            cell.configure(with: tableHeaderKeyword)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemSelectCell
            if let item = self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]?[indexPath.row] {
                cell.configure(with: item,
                               rate: item.rating,
                               keyword: tableHeaderKeyword,
                               isSelected: self.isSelected(for: item),
                               indexPath: indexPath)
                cell.delegate = self
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableHeaderShowing && indexPath.section == 0 {
            return 70
        } else {
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Color(hexString: "#D8D8D8").alpha(0.1)
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = Color.white
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.sortKey == .name {
            return self.sectionNames
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableHeaderShowing && indexPath.section == 0 {
            self.addNewPracticeItem()
        } else {
            if !self.processingSelectItems {
                self.selectItem(for: self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]![indexPath.row], indexPath: indexPath)
            }
        }
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
            PracticeItemLocalManager.manager.removePracticeItem(for: self.sectionedPracticeItems[self.sectionNames[indexPath.section]]![indexPath.row])
            self.updateList()
            self.parentViewModel.checkPlaylistForPracticeItemRemoved()
        } else {
            self.openDetails(self.sectionedPracticeItems[self.sectionNames[indexPath.section]]![indexPath.row].id)
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
        self.sortOption = option
        self.sortKey = key
        AppOveralDataManager.manager.saveSortKey(self.sortKey)
        AppOveralDataManager.manager.saveSortOption(self.sortOption)
        self.updateWithFilterList()
    }
    
    func updateList(completed: CompletedAction? = nil) {
        DispatchQueue.global().async {
            self.practiceItems = PracticeItemLocalManager.manager.loadPracticeItems()?.sorted(by: { (item1, item2) -> Bool in
                return item1.name < item2.name
            })
            self.refreshList(completed: completed)
        }
    }
    
    func updateWithFilterList() {
        DispatchQueue.global().async {
            self.categorize()
            self.sort()
            DispatchQueue.main.async {
                self.processingSelectItems = false
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableViewMain.reloadData()
                if self.selectedPracticeItems.count > 0 {
                    self.viewAddPracticeButtonContainer.isHidden = false
                    self.constraintForAddPracticeButtonHeight.constant = 64// / 375 * UIScreen.main.bounds.size.width
                } else {
                    self.viewAddPracticeButtonContainer.isHidden = true
                    self.constraintForAddPracticeButtonHeight.constant = 0
                }
            }
        }
    }
    
    func refreshList(completed: CompletedAction? = nil) {
        self.filter()
        self.categorize()
        self.sort()
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableViewMain.reloadData()
            if self.selectedPracticeItems.count > 0 {
                self.viewAddPracticeButtonContainer.isHidden = false
                self.constraintForAddPracticeButtonHeight.constant = 64// / 375 * UIScreen.main.bounds.size.width
            } else {
                self.viewAddPracticeButtonContainer.isHidden = true
                self.constraintForAddPracticeButtonHeight.constant = 0
            }
            if let completed = completed {
                completed()
            }
        }
    }
    
    func filter() {
        let tableHeaderKeyword = self.searchKeyword
        if tableHeaderKeyword == "" {
            self.filteredPracticeItems = self.practiceItems
        } else {
            if let practiceItems = self.practiceItems {
                self.filteredPracticeItems = [PracticeItem]()
                for practiceItem in practiceItems {
                    if practiceItem.name.lowercased().contains(tableHeaderKeyword.lowercased()) {
                        self.filteredPracticeItems!.append(practiceItem)
                    }
                }
            } else {
                self.filteredPracticeItems = nil
            }
        }
    }
    
    func sort() {
        
        self.sectionNames = Array(self.sectionedPracticeItems.keys).sorted(by: { (ch1, ch2) -> Bool in
            if self.sortKey == .lastPracticedTime {
                let date1 =  AppUtils.dateFromStringLocale(from: ch1) ?? Date(timeIntervalSince1970: 0)
                let date2 =  AppUtils.dateFromStringLocale(from: ch2) ?? Date(timeIntervalSince1970: 0)
                return (self.sortOption == .ascending) ? (date1 < date2) : (date1 > date2)
            } else {
                return (self.sortOption == .ascending) ? (ch1 < ch2) : (ch1 > ch2)
            }
        })
    }
    
    func categorize() {
        
        var showingPracticeItems = [PracticeItem]()
        
        var flags = [String:Bool]()
        for item in self.selectedPracticeItems {
            showingPracticeItems.append(item)
            flags[item.id] = true
        }
        
        if let practiceItems = self.filteredPracticeItems {
            for practiceItem in practiceItems {
                if !(flags[practiceItem.id] ?? false) {
                    showingPracticeItems.append(practiceItem)
                }
            }
        }
        
        self.sectionNames = [String]()
        self.sectionedPracticeItems = [String:[PracticeItem]]()
        
        showingPracticeItems.sort { (item1, item2) -> Bool in
            switch self.sortKey {
            case .rating:
                fallthrough
            case .favorites:
                fallthrough
            case .name:
                return (self.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
            case .lastPracticedTime:
                let key1 = item1.lastPracticedSortKey ?? ""
                let key2 = item2.lastPracticedSortKey ?? ""
                return (self.sortOption == .ascending) ? (key1 < key2) : (key1 > key2)
            }
        }
        
        for practice in showingPracticeItems {
            
            var keyString = ""
            
            switch self.sortKey {
            case .name:
                keyString = practice.firstCharacter()
            case .favorites:
                keyString = practice.isFavorite == 0 ? "♡" : "♥"
            case .lastPracticedTime:
                keyString = practice.lastPracticedDateKeyString ?? "" //lastPracticedDateString()
            case .rating:
                keyString = "\(Int(practice.rating)) STARS"
            }
            
            if self.sectionedPracticeItems[keyString] != nil {
                self.sectionedPracticeItems[keyString]!.append(practice)
            } else {
                self.sectionedPracticeItems[keyString] = [practice]
            }
        }
    }
}

extension PracticeItemSelectViewController {
    
    func selectItem(for item:PracticeItem, indexPath: IndexPath) {
        self.processingSelectItems = true
        for idx in 0..<self.selectedPracticeItems.count {
            let selectedItem = self.selectedPracticeItems[idx]
            if selectedItem.id == item.id {
                self.selectedPracticeItems.remove(at: idx)
                self.updateWithFilterList()
                return
            }
        }
        self.selectedPracticeItems.append(item)
        self.updateWithFilterList()
    }
    
    func isSelected(for item:PracticeItem) -> Bool {
        for idx in 0..<self.selectedPracticeItems.count {
            let selectedItem = self.selectedPracticeItems[idx]
            if selectedItem.id == item.id {
                return true
            }
        }
        return false
    }
}
