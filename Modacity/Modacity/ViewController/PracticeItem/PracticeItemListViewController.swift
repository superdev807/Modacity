//
//  PracticeItemListViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 16/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol PracticeItemListViewControllerDelegate {
    func practiceItemListViewController(_ controller: PracticeItemListViewController, selectedPracticeItem: PracticeItem)
}

class PracticeItemListViewController: ModacityParentViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    var practiceItems: [PracticeItem]? = nil
    var practiceItemNameEditingCell: PracticeItemCell? = nil
    
    var filteredPracticeItems: [PracticeItem]? = nil
    var sectionNames = [String]()
    var sectionedPracticeItems = [String:[PracticeItem]]()
    
    @IBOutlet weak var viewTableHeader: UIView!
    @IBOutlet weak var viewHeaderSearchBar: UIView!
    @IBOutlet weak var textfieldHeader: UITextField!
    @IBOutlet weak var buttonRemoveKeyboard: UIButton!
    @IBOutlet weak var imageViewTopLeftIcon: UIImageView!
    @IBOutlet weak var constraintForTableViewBottomSpace: NSLayoutConstraint!
    
    var heightOfTableViewBottomSpaceStart = CGFloat(-64)
    
    var tableHeaderShowing = false
    var tableHeaderKeyword = ""
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.ascending
    
    var singleSelectMode = false
    var delegate: PracticeItemListViewControllerDelegate? = nil
    
    let operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        operationQueue.maxConcurrentOperationCount = 1
        if AppUtils.sizeModelOfiPhone() == .iphoneX_xS || AppUtils.sizeModelOfiPhone() == .iphonexR_xSMax {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            if AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                self.constraintForHeaderImageViewHeight.constant = 70
            } else {
                self.constraintForHeaderImageViewHeight.constant = 88
            }
        }
        self.buttonRemoveKeyboard.isHidden = true
        self.viewHeaderSearchBar.layer.cornerRadius = 5
        self.tableViewMain.tableFooterView = UIView()
        self.tableViewMain.sectionIndexBackgroundColor = Color.clear
        self.tableViewMain.sectionIndexColor = Color.white
        
        if self.singleSelectMode {
            self.imageViewTopLeftIcon.image = UIImage(named: "icon_arrow_left")
            self.constraintForTableViewBottomSpace.constant = 0
            heightOfTableViewBottomSpaceStart = 0
        } else {
            self.imageViewTopLeftIcon.image = UIImage(named: "icon_menu")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if AppUtils.iphoneIsXModel() {
                self.constraintForTableViewBottomSpace.constant = (-1) * (keyboardSize.height - 34)
            } else {
                self.constraintForTableViewBottomSpace.constant = keyboardSize.height * (-1)
            }
        }
    }
    
    @objc func onKeyboardWillHide() {
        self.constraintForTableViewBottomSpace.constant = heightOfTableViewBottomSpaceStart
    }
    
    @IBAction func onMenu(_ sender: Any) {
        
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
            self.practiceItemNameEditingCell = nil
        }
        
        if self.singleSelectMode {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.sideMenuController?.showLeftViewAnimated()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sortKey = AppOveralDataManager.manager.sortKey()
        self.sortOption = AppOveralDataManager.manager.sortOption()
        self.updateList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_sort" {
            let controller = segue.destination as! SortOptionsViewController
            controller.sortOption = self.sortOption
            controller.sortKey = self.sortKey
            controller.delegate = self
        }
    }
    
    func updateList(completed: CompletedAction? = nil) {
        self.operationQueue.cancelAllOperations()
        self.operationQueue.addOperation {
            DispatchQueue.global().async { [weak self] in
                guard let this = self else { return }
                this.practiceItems = PracticeItemLocalManager.manager.loadPracticeItems()?.sorted(by: { (item1, item2) -> Bool in
                    return item1.name < item2.name
                })
                this.refreshList(completed: completed)
            }
        }
    }
    
    func refreshList(completed: CompletedAction? = nil) {
        self.filter()
        self.categorize()
        self.sort()
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            MBProgressHUD.hide(for: this.view, animated: true)
            this.tableViewMain.reloadData()
            
            if let completed = completed {
                completed()
            }
        }
    }
    
    func filter() {
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
                let date1 = AppUtils.dateFromStringLocale(from: ch1) ?? Date(timeIntervalSince1970: 0)
                let date2 = AppUtils.dateFromStringLocale(from: ch2) ?? Date(timeIntervalSince1970: 0)
                return (self.sortOption == .ascending) ? (date1 < date2) : (date1 > date2)
            } else {
                return (self.sortOption == .ascending) ? (ch1 < ch2) : (ch1 > ch2)
            }
        })
    }
    
    func categorize() {
        
        if var practiceItems = self.filteredPracticeItems {
            
            practiceItems.sort { [weak self] (item1, item2) -> Bool in
                guard let this = self else { return false }
                switch this.sortKey {
                case .rating:
                    if item1.rating == item2.rating {
                        return (this.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
                    } else {
                        return (this.sortOption == .ascending) ? (item1.rating < item2.rating) : (item1.rating > item2.rating)
                    }
                case .favorites:
                    fallthrough
                case .name:
                    return (this.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
                case .lastPracticedTime:
                    let key1 = item1.lastPracticedSortKey ?? ""
                    let key2 = item2.lastPracticedSortKey ?? ""
                    return (this.sortOption == .ascending) ? (key1 < key2) : (key1 > key2)
                default:
                    return true
                }
            }
            
            self.sectionedPracticeItems = [String:[PracticeItem]]()
            
            for practice in practiceItems {
                
                var keyString = ""
                
                switch self.sortKey {
                case .name:
                    keyString = practice.firstCharacter()
                case .favorites:
                    keyString = (practice.isFavorite == 0) ? "♡" : "♥"
                case .lastPracticedTime:
                    keyString = practice.lastPracticedDateKeyString ?? ""//lastPracticedDateString()
                case .rating:
                    keyString = "\(Int(practice.rating)) STARS"
                default:
                    keyString = ""
                }
                
                if self.sectionedPracticeItems != nil && self.sectionedPracticeItems[keyString] != nil {
                    self.sectionedPracticeItems[keyString]!.append(practice)
                } else {
                    self.sectionedPracticeItems[keyString] = [practice]
                }
            }
        }
    }
    
    @IBAction func onSort(_ sender: Any) {
        let controller = UIStoryboard(name: "practice_item", bundle: nil).instantiateViewController(withIdentifier: "SortOptionsViewController") as! SortOptionsViewController
        controller.sortOption = self.sortOption
        controller.sortKey = self.sortKey
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        self.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
}

extension PracticeItemListViewController: UITableViewDataSource, UITableViewDelegate, PracticeItemCellDelegate {
    
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
            let returnedView = UIView(frame: CGRect(x:0, y:0, width:tableViewMain.frame.size.width, height:28))
            returnedView.backgroundColor = Color(hexString: "#3c385a")
            
            if self.sortKey == .favorites {
                
                let sectionName = self.sectionNames[section - (tableHeaderShowing ? 1: 0)]
                
                let imageView = UIImageView(frame: CGRect(x:10, y:7, width:20, height:14))
                if sectionName == "♥" {
                    imageView.image = UIImage(named: "icon_heart_red")
                    imageView.alpha = 1.0
                } else {
                    imageView.image = UIImage(named: "icon_heart")
                    imageView.alpha = 0.3
                }
                imageView.contentMode = .scaleAspectFit
                returnedView.addSubview(imageView)
                
            } else {
                
                let label = UILabel(frame: CGRect(x:10, y:0, width:tableViewMain.frame.size.width - 20, height:24))
                label.text = "\(self.sectionNames[section - (tableHeaderShowing ? 1: 0)])"
                label.textColor = Color.white.alpha(0.8)
                label.font = UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)
                returnedView.addSubview(label)
                
            }
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemCell
            if (self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]!.count > indexPath.row) {
                cell.configure(with: self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]![indexPath.row],
                               keyword: self.tableHeaderKeyword,
                               on: indexPath)
            }
            cell.delegate = self
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableHeaderShowing && indexPath.section == 0 {
            self.addNewPracticeItem()
        } else {
            
            let practiceItem = self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]![indexPath.row]
            
            if self.singleSelectMode {
                if let delegate = self.delegate {
                    delegate.practiceItemListViewController(self, selectedPracticeItem: practiceItem)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                var sceneName = ""
                if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
                    sceneName = "PracticeSceneForSmallSizes"
                } else {
                    sceneName = "PracticeScene"
                }
                let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: sceneName) as! UINavigationController
                let practiceViewController = controller.viewControllers[0] as! PracticeViewController
                practiceViewController.practiceItem = practiceItem
                let deliverModel = PlaylistAndPracticeDeliverModel()
                deliverModel.deliverPracticeItem = PracticeItemLocalManager.manager.practiceItem(forId: practiceItem.id) ?? practiceItem
                deliverModel.sessionTimeStarted = Date()
                deliverModel.sessionImproved = [ImprovedRecord]()
                practiceViewController.deliverModel = deliverModel
                practiceViewController.lastPracticeBreakTime = 0
                practiceViewController.practiceBreakTime = AppOveralDataManager.manager.practiceBreakTime() * 60
                self.tabBarController?.present(controller, animated: true, completion: nil)
            }
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
    
    func openDetails(_ practiceItemId:String) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
        let detailsViewController = controller.viewControllers[0] as! DetailsViewController
        detailsViewController.practiceItemId = practiceItemId
        
        if self.singleSelectMode {
            self.present(controller, animated: true, completion: nil)
        } else {
            self.tabBarController!.present(controller, animated: true, completion: nil)
        }
        
        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId) {
            ModacityAnalytics.LogStringEvent("Selected Practice Item", extraParamName: "Name", extraParamValue: practice.name)
        }
    }
    
    func onEditingDidEnd(on cell: PracticeItemCell, for practiceItem: PracticeItem, to newName: String) {
        
        if newName != "" {
            cell.labelPracticeName.text = cell.textfieldNameEdit.text
            
            if practiceItem.name.lowercased() == newName.lowercased() {
                return
            } else {
                if (PracticeItemLocalManager.manager.checkPracticeItemNameAvailable(newName, practiceItem.id)) {
                    practiceItem.name = newName
                    practiceItem.updateMe()
                } else {
                    cell.labelPracticeName.text = practiceItem.name
                    AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "An item with this name already exists!")
                }
            }
        }
    }
    
    func onCellMenu(cell: PracticeItemCell) {
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
            self.practiceItemNameEditingCell = nil
        }
        DropdownMenuView.instance.show(in: self.view,
                                       on: cell.buttonMenu,
                                       rows: [["icon":"icon_notes", "text":"Details"],
                                              ["icon":"icon_pen_white", "text":"Rename"],
                                              ["icon":"icon_duplicate", "text":"Duplicate"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { [weak self ](row) in
                                                self?.processAction(row, cell)
        }
    }
    
    func processAction(_ row: Int, _ cell: PracticeItemCell) {
        if row == 1 {
            self.rename(on:cell)
        } else if row == 0 {
            self.openDetails(cell.practiceItem.id)
        } else if row == 2 {
            self.duplicateItem(cell.practiceItem, on:cell.indexPath)
        } else if row == 3 {
            self.delete(on: cell)
        }
    }
    
    func delete(on cell: PracticeItemCell) {
        
        if let items = self.practiceItems {
            for row in 0..<items.count {
                if items[row].id == cell.practiceItem.id {
                    self.practiceItems!.remove(at: row)
                    break
                }
            }
        }
        
        if let items = self.filteredPracticeItems {
            for row in 0..<items.count {
                if items[row].id == cell.practiceItem.id {
                    self.filteredPracticeItems!.remove(at: row)
                    break
                }
            }
        }
        
        let sectionName = self.sectionNames[cell.indexPath.section - (tableHeaderShowing ? 1 : 0)]
        if let _ = self.sectionedPracticeItems[sectionName] {
            self.sectionedPracticeItems[sectionName]!.remove(at: cell.indexPath.row)
            if self.sectionedPracticeItems[sectionName]!.count == 0 {
                self.sectionNames.remove(at: cell.indexPath.section - (tableHeaderShowing ? 1 : 0))
                self.tableViewMain.reloadData()
            } else {
                self.tableViewMain.reloadData()
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            PracticeItemLocalManager.manager.removePracticeItem(for: cell.practiceItem)
        }
    }
    
    func rename(on cell: PracticeItemCell) {
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
            self.practiceItemNameEditingCell = nil
        }
        cell.textfieldNameEdit.isHidden = false
        cell.labelPracticeName.isHidden = true
        cell.textfieldNameEdit.becomeFirstResponder()
        cell.textfieldNameEdit.text = cell.practiceItem.name
        self.practiceItemNameEditingCell = cell
    }
}

extension PracticeItemListViewController: UITextFieldDelegate {
    
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
    
    @IBAction func onEditingChangedOnField(_ sender: Any) {
        self.updateKeyword()
    }
    
    @IBAction func onRemoveKeyword(_ sender: Any) {
        self.textfieldHeader.text = ""
        self.buttonRemoveKeyboard.isHidden = true
        self.updateKeyword()
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.textfieldHeader.resignFirstResponder()
        self.updateKeyword()
    }
    
    func updateKeyword() {
        ModacityDebugger.debug("Keyword updating...")
        let newKeyword = self.textfieldHeader.text ?? ""
        tableHeaderKeyword = newKeyword
        if newKeyword != "" && !self.practiceItemContains(for: newKeyword) {
            tableHeaderShowing = true
        } else {
            tableHeaderShowing = false
        }
        
        self.operationQueue.cancelAllOperations()
        self.operationQueue.addOperation {
            DispatchQueue.global().async { [weak self] in
                self?.refreshList()
            }
        }
        self.buttonRemoveKeyboard.isHidden = (newKeyword == "")
    }
    
    func addNewPracticeItem() {
        
        self.view.isUserInteractionEnabled = false
        
        if Authorizer.authorizer.isGuestLogin() {
            self.view.isUserInteractionEnabled = true
            AppUtils.showSimpleAlertMessage(for: self, title: nil, message: "Please login to add new practice item.") { [weak self] (_) in
                self?.openSignup()
            }
            return
        }
        
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
        
        self.textfieldHeader.text = ""
        self.buttonRemoveKeyboard.isHidden = true
        
        self.updateList {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollTableView(to:newName)
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
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
}

extension PracticeItemListViewController: SortOptionsViewControllerDelegate {
    
    func changeOptions(key: SortKeyOption, option: SortOption) {
        self.sortOption = option
        self.sortKey = key
        
        if key == .favorites {
            self.practiceItems = PracticeItemLocalManager.manager.loadPracticeItems()?.sorted(by: { (item1, item2) -> Bool in
                return item1.name < item2.name
            })
            self.updateList()
        } else {
            AppOveralDataManager.manager.saveSortKey(self.sortKey)
            AppOveralDataManager.manager.saveSortOption(self.sortOption)
            DispatchQueue.global().async { [weak self] in
                self?.categorize()
                self?.sort()
                DispatchQueue.main.async { [weak self] in
                    self?.tableViewMain.reloadData()
                }
            }
        }
    }
    
    func duplicateItem(_ item: PracticeItem, on indexPath: IndexPath) {
        
        let newName = item.name ?? ""
        
        ModacityAnalytics.LogStringEvent("Duplicated Practice Item", extraParamName: "name", extraParamValue: newName)
        
        let practiceItem = PracticeItem()
        practiceItem.id = UUID().uuidString
        practiceItem.name = PracticeItemLocalManager.manager.availablePracticeItemName(from: newName)
        
        if self.practiceItems == nil {
            self.practiceItems = [PracticeItem]()
        }
        
        self.practiceItems!.append(practiceItem)
        self.filteredPracticeItems!.append(practiceItem)
        
        let sectionName = self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]
        if let _ = self.sectionedPracticeItems[sectionName] {
            self.sectionedPracticeItems[sectionName]!.insert(practiceItem, at: indexPath.row + 1)
        }
        
        self.tableViewMain.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            guard let this = self else { return }
            if !(this.tableViewMain.indexPathsForVisibleRows!.contains(IndexPath(row: indexPath.row + 1, section:indexPath.section))) {
                this.tableViewMain.scrollToRow(at: IndexPath(row: indexPath.row + 1, section:indexPath.section), at: .none, animated: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                    if let cell = self?.tableViewMain.cellForRow(at: IndexPath(row: indexPath.row + 1, section:indexPath.section)) as? PracticeItemCell {
                        self?.rename(on: cell)
                    } else {
                        print("rename cell is nil, need to wait more.")
                    }
                }
            } else {
                if let cell = this.tableViewMain.cellForRow(at: IndexPath(row: indexPath.row + 1, section:indexPath.section)) as? PracticeItemCell {
                    this.rename(on: cell)
                } else {
                    print("rename cell is nil, need to wait more.")
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            PracticeItemLocalManager.manager.storePracticeItems(self.practiceItems!)
            PracticeItemRemoteManager.manager.add(item: practiceItem)
        }
    }
    
    func openSignup() {
        let controller = UIStoryboard(name: "welcome", bundle: nil).instantiateViewController(withIdentifier: "LoginScene") as! UINavigationController
        self.tabBarController?.present(controller, animated: true, completion: nil)
    }
}
