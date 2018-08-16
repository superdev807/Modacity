//
//  PracticeItemListViewController.swift
//  Modacity
//
//  Created by BC Engineer on 16/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import MBProgressHUD

class PracticeItemListViewController: UIViewController {
    
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
    
    var tableHeaderShowing = false
    var tableHeaderKeyword = ""
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.ascending
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderImageViewHeight.constant = 108
        } else {
            if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
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
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
            self.practiceItemNameEditingCell = nil
        }
        self.sideMenuController?.showLeftViewAnimated()
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
    
    func updateList() {
        DispatchQueue.global().async {
            self.practiceItems = PracticeItemLocalManager.manager.loadPracticeItems()?.sorted(by: { (item1, item2) -> Bool in
                return item1.name < item2.name
            })
            self.refreshList()
        }
    }
    
    func refreshList() {
        self.filter()
        self.categorize()
        self.sort()
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableViewMain.reloadData()
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
                let date1 = ch1.date(format: "M/d/yy") ?? Date(timeIntervalSince1970: 0)
                let date2 = ch2.date(format: "M/d/yy") ?? Date(timeIntervalSince1970: 0)
                return (self.sortOption == .ascending) ? (date1 < date2) : (date1 > date2)
            } else {
                return (self.sortOption == .ascending) ? (ch1 < ch2) : (ch1 > ch2)
            }
        })
        
//        for key in self.sectionedPracticeItems.keys {
//            if let items = self.sectionedPracticeItems[key] {
//                self.sectionedPracticeItems[key] = items.sorted(by: { (item1, item2) -> Bool in
//                    switch self.sortKey {
//                    case .rating:
//                        fallthrough
//                    case .favorites:
//                        fallthrough
//                    case .name:
//                        return (self.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
//                    case .lastPracticedTime:
//                        let sortingKey1 = item1.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item1.name
//                        let sortingKey2 = item2.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item2.name
//                        return (self.sortOption == .ascending) ? (sortingKey1 < sortingKey2) : (sortingKey1 > sortingKey2)
//                    }
//                })
//            }
//        }
    }
    
    func categorize() {
        if var practiceItems = self.filteredPracticeItems {
            
            practiceItems.sort { (item1, item2) -> Bool in
                switch self.sortKey {
                case .rating:
                    fallthrough
                case .favorites:
                    fallthrough
                case .name:
                    return (self.sortOption == .ascending) ? (item1.name < item2.name) : (item1.name > item2.name)
                case .lastPracticedTime:
                    let sortingKey1 = item1.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item1.name
                    let sortingKey2 = item2.lastPracticeTime().toString(format: "yyyyMMddHHmmss") + item2.name
                    return (self.sortOption == .ascending) ? (sortingKey1 < sortingKey2) : (sortingKey1 > sortingKey2)
                }
            }
            
            self.sectionNames = [String]()
            self.sectionedPracticeItems = [String:[PracticeItem]]()
            
            for practice in practiceItems {
                
                var keyString = ""
                
                switch self.sortKey {
                case .name:
                    keyString = practice.firstCharacter()
                case .favorites:
                    keyString = practice.isFavorite == 0 ? "♡" : "♥"
                case .lastPracticedTime:
                    keyString = practice.lastPracticedDateString()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemCell
            cell.configure(with: self.sectionedPracticeItems[self.sectionNames[indexPath.section - (tableHeaderShowing ? 1 : 0)]]![indexPath.row], keyword: self.tableHeaderKeyword)
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
            deliverModel.deliverPracticeItem = practiceItem
            deliverModel.sessionTimeStarted = Date()
            deliverModel.sessionImproved = [ImprovedRecord]()
            practiceViewController.deliverModel = deliverModel
            practiceViewController.lastPracticeBreakTime = 0
            practiceViewController.practiceBreakTime = AppOveralDataManager.manager.practiceBreakTime() * 60
            self.tabBarController?.present(controller, animated: true, completion: nil)
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
        self.tabBarController!.present(controller, animated: true, completion: nil)
        
        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId) {
            ModacityAnalytics.LogStringEvent("Selected Practice Item", extraParamName: "Name", extraParamValue: practice.name)
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
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                self.processAction(row, cell)
        }
    }
    
    func processAction(_ row: Int, _ cell: PracticeItemCell) {
        if row == 1 {
            if self.practiceItemNameEditingCell != nil {
                self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
                self.practiceItemNameEditingCell = nil
            }
            cell.textfieldNameEdit.isHidden = false
            cell.labelPracticeName.isHidden = true
            cell.textfieldNameEdit.becomeFirstResponder()
            cell.textfieldNameEdit.text = cell.practiceItem.name
            self.practiceItemNameEditingCell = cell
        } else if row == 0 {
            self.openDetails(cell.practiceItem.id)
        } else if row == 2 {
            PracticeItemLocalManager.manager.removePracticeItem(for: cell.practiceItem)
            self.updateList()
        }
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
        self.refreshList()
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.textfieldHeader.resignFirstResponder()
        self.updateKeyword()
    }
    
    func updateKeyword() {
        let newKeyword = self.textfieldHeader.text ?? ""
        tableHeaderKeyword = newKeyword
        if newKeyword != "" && !self.practiceItemContains(for: newKeyword) {
            tableHeaderShowing = true
        } else {
            tableHeaderShowing = false
        }
        self.refreshList()
        self.buttonRemoveKeyboard.isHidden = (newKeyword == "")
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
        
        self.textfieldHeader.text = ""
        self.buttonRemoveKeyboard.isHidden = true
        
        self.updateList()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollTableView(to:newName)
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
        AppOveralDataManager.manager.saveSortKey(self.sortKey)
        AppOveralDataManager.manager.saveSortOption(self.sortOption)
        self.categorize()
        self.sort()
        self.tableViewMain.reloadData()
    }
}
