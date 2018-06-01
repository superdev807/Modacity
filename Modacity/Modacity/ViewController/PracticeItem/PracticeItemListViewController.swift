//
//  PracticeItemListViewController.swift
//  Modacity
//
//  Created by BC Engineer on 16/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeItemListViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintForHeaderImageViewHeight: NSLayoutConstraint!
    
    var practiceItems: [PracticeItem]? = nil
    var practiceItemNameEditingCell: PracticeItemCell? = nil
    
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
        self.tableViewMain.tableFooterView = UIView()
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
        self.refreshList()
    }
    
    func refreshList() {
        self.practiceItems = PracticeItemLocalManager.manager.loadPracticeItems()?.sorted(by: { (item1, item2) -> Bool in
            return item1.name < item2.name
        })
        self.tableViewMain.reloadData()
    }
}

protocol PracticeItemCellDelegate {
    func onCellMenu(cell: PracticeItemCell)
}

class PracticeItemCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textfieldNameEdit: UITextField!
    
    @IBOutlet weak var labelPracticeItemLastPracticed: UILabel!
    var delegate: PracticeItemCellDelegate? = nil
    var practiceItem: PracticeItem!
    
    func configure(with practiceItem: PracticeItem) {
        self.labelPracticeName.text = practiceItem.name
        self.ratingView.rating = PracticeItemLocalManager.manager.ratingValue(for: practiceItem.id) ?? 0        
        self.labelPracticeItemLastPracticed.text = practiceItem.lastPracticedTimeString()
        self.practiceItem = practiceItem
        self.textfieldNameEdit.isHidden = true
        self.labelPracticeName.isHidden = false
        self.changeHeartIconImage()
    }
    
    @IBAction func onCellMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onCellMenu(cell: self)
        }
    }
    
    func changeHeartIconImage() {
        if !PracticeItemLocalManager.manager.isFavoritePracticeItem(for: self.practiceItem.id) {
            self.buttonHeart.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonHeart.alpha = 0.3
        } else {
            self.buttonHeart.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonHeart.alpha = 1
        }
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
        if self.textfieldNameEdit.text != "" {
            self.labelPracticeName.text = self.textfieldNameEdit.text
            self.practiceItem.name = self.textfieldNameEdit.text
            self.practiceItem.updateMe()
        }
        self.textfieldNameEdit.isHidden = true
        self.labelPracticeName.isHidden = false
    }
    
    @IBAction func onHeart(_ sender:Any) {
        PracticeItemLocalManager.manager.setFavoritePracticeItem(forItemId: self.practiceItem.id)
        self.changeHeartIconImage()
    }
}

extension PracticeItemListViewController: UITableViewDataSource, UITableViewDelegate, PracticeItemCellDelegate {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.practiceItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeItemCell") as! PracticeItemCell
        cell.configure(with: self.practiceItems![indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let practiceItem = self.practiceItems![indexPath.row]
        var sceneName = ""
        if AppUtils.sizeModelOfiPhone() == .iphone5_4in || AppUtils.sizeModelOfiPhone() == .iphone4_35in {
            sceneName = "PracticeSceneForSmallSizes"
        } else {
            sceneName = "PracticeScene"
        }
        let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: sceneName) as! UINavigationController
        let practiceViewController = controller.viewControllers[0] as! PracticeViewController
        practiceViewController.practiceItem = practiceItem
        self.tabBarController?.present(controller, animated: true, completion: nil)
        
        ModacityAnalytics.LogStringEvent("Selected Practice Item", extraParamName: "Name", extraParamValue: practiceItem.name)
    }
    
    func onCellMenu(cell: PracticeItemCell) {
        if self.practiceItemNameEditingCell != nil {
            self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
            self.practiceItemNameEditingCell = nil
        }
        DropdownMenuView.instance.show(in: self.view,
                                       on: cell.buttonMenu,
                                       rows: [["icon":"icon_pen_white", "text":"Rename"],
                                              ["icon":"icon_notes", "text":"Notes"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                                self.processAction(row, cell)
        }
    }
    
    func processAction(_ row: Int, _ cell: PracticeItemCell) {
        if row == 0 {
            if self.practiceItemNameEditingCell != nil {
                self.practiceItemNameEditingCell!.textfieldNameEdit.resignFirstResponder()
                self.practiceItemNameEditingCell = nil
            }
            cell.textfieldNameEdit.isHidden = false
            cell.labelPracticeName.isHidden = true
            cell.textfieldNameEdit.becomeFirstResponder()
            cell.textfieldNameEdit.text = cell.practiceItem.name
            self.practiceItemNameEditingCell = cell
        } else if row == 1 {
            let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNotesViewController") as! PracticeNotesViewController
            controller.practiceItem = self.practiceItems?[row]
            self.navigationController?.pushViewController(controller, animated: true)
        } else if row == 2 {
            PracticeItemLocalManager.manager.removePracticeItem(for: cell.practiceItem)
            self.refreshList()
        }
    }
}
