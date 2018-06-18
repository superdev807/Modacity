//
//  PlaylistDetailsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistContentsViewController: UIViewController {

    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var textfieldPlaylistName: UITextField!
    @IBOutlet weak var buttonEditName: UIButton!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var buttonStartPlaylist: UIButton!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonAddPracticeItem: UIButton!
    @IBOutlet weak var constraintHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelImprovementsCount: UILabel!
    @IBOutlet weak var buttonEditPlaylistNameLarge: UIButton!
    @IBOutlet weak var viewKeyboardDismiss: UIView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var viewWalkThrough1: UIView!
    @IBOutlet weak var viewWalkThroughNaming: UIView!
    @IBOutlet weak var viewWalkThrough2: UIView!
    
    var isNameEditing = false
    var parentViewModel: PlaylistAndPracticeDeliverModel? = nil
    var viewModel = PlaylistContentsViewModel()
    var isPlaying = false
    var playingStartedTime: Date? = nil
    var sessionTimer : Timer? = nil
    var sessionStarted: Date? = nil
    var sessionPlayedInPlaylistPage = 0
    var currentRow = 0
    var playlistPracticeTotalTimeInSec = 0
    
    var snapshot: UIView? = nil
    var sourceIndexPath: IndexPath? = nil
    
    var shouldStartFromPracticeSelection = false
    var waitingPracticeSelection = false
    
    var showingWalkThrough1 = false
    var showingWalkThroughNaming = false
    var justLastPracticeItemFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintHeaderImageViewHeight.constant = 170
        } else {
            self.constraintHeaderImageViewHeight.constant = 150
        }
        self.configureGUI()
        self.bindViewModel()
        
        self.viewWalkThrough1.alpha = 0
        self.viewWalkThroughNaming.alpha = 0
        self.viewWalkThrough2.isHidden = true
        
        if self.shouldStartFromPracticeSelection {
            if AppOveralDataManager.manager.firstPlaylistGenerated() {
                self.openPracticeItemsSelection()
                return
            }
            self.viewModel.playlistName = "My First Playlist"
            self.buttonEditName.isHidden = false
            self.openPracticeItemsSelection()
        } else {
            self.processWalkThrough()
        }
    }
    
    deinit {
        if self.sessionTimer != nil {
            self.sessionTimer!.invalidate()
            self.sessionTimer = nil
        }
    }
    
    func openPracticeItemsSelection() {
        let controller = UIStoryboard(name: "practice_item", bundle: nil).instantiateViewController(withIdentifier: "PracticeItemSelectViewController") as! PracticeItemSelectViewController
        controller.shouldSelectPracticeItems = true
        controller.parentViewModel = self.viewModel
        controller.parentController = self
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func practiceItemsSelected() {
        self.waitingPracticeSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isPlaying {
            self.sessionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onSessionTimer), userInfo: nil, repeats: true)
            self.sessionStarted = Date()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isPlaying {
            if let sessionStartedTime = self.sessionStarted {
                self.sessionPlayedInPlaylistPage = self.sessionPlayedInPlaylistPage + Int(Date().timeIntervalSince1970 - sessionStartedTime.timeIntervalSince1970)
            }
            if let timer = self.sessionTimer {
                timer.invalidate()
                self.sessionTimer = nil
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewMain.reloadData()
        self.showSessionTime()
        
        if self.waitingPracticeSelection {
            self.waitingPracticeSelection = false
            self.processWalkThrough()
        } else {
            if self.justLastPracticeItemFinished {
                self.justLastPracticeItemFinished = false
                if !AppOveralDataManager.manager.walkThroughDoneForPlaylistFinish() {
                    self.showWalkThrough2()
                }
            }
        }
    }
    
    func processWalkThrough() {
        if !AppOveralDataManager.manager.walkThroughDoneForFirstPlaylist() {
            self.showWalkThrough1()
        } else {
            if self.viewWalkThrough1.superview != nil {
                self.viewWalkThrough1.removeFromSuperview()
            }
            
            if self.viewModel.playlistName == "" {
                if !AppOveralDataManager.manager.walkThroughDoneForPlaylistNaming() {
                    self.showWalkThroughNaming()
                } else {
                    if self.viewWalkThroughNaming.superview != nil {
                        self.viewWalkThroughNaming.removeFromSuperview()
                    }
                    if !AppOveralDataManager.manager.walkThroughDoneForFirstPlaylist() {
                        self.showWalkThrough1()
                    } else {
                        self.viewWalkThrough1.removeFromSuperview()
                    }
                }
            } else {
                if self.viewWalkThroughNaming.superview != nil {
                    self.viewWalkThroughNaming.removeFromSuperview()
                }
                if !AppOveralDataManager.manager.walkThroughDoneForFirstPlaylist() {
                    self.showWalkThrough1()
                } else {
                    self.viewWalkThrough1.removeFromSuperview()
                }
            }
        }
    }
    
    func showWalkThrough1() {
        self.showingWalkThrough1 = true
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThrough1.alpha = 1
        }
    }
    
    func showWalkThrough2() {
        self.viewWalkThrough2.isHidden = false
        self.viewWalkThrough2.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThrough2.alpha = 1
        }
    }
    
    func dismissWalkThrough1(withSetting: Bool) {
        self.viewWalkThrough1.removeFromSuperview()
        if withSetting {
            AppOveralDataManager.manager.walkThroughFirstPlaylist()
        }
        self.showingWalkThrough1 = false
    }
    
    func dismissWalkThrough2() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkThrough2.alpha = 0
        }) { (finished) in
            if finished {
                self.viewWalkThrough2.isHidden = true
                AppOveralDataManager.manager.walkThroughPlaylistFinish()
            }
        }
    }
    
    @IBAction func onDismissWalkThrough1(_ sender: Any) {
        self.dismissWalkThrough1(withSetting: false)
    }
    
    func showWalkThroughNaming() {
        self.showingWalkThroughNaming = true
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThroughNaming.alpha = 1
        }
    }
    
    func dismissWalkThroughNaming() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkThroughNaming.alpha = 0
        }) { (finished) in
            if finished {
                self.viewWalkThroughNaming.removeFromSuperview()
                self.showingWalkThroughNaming = false
                AppOveralDataManager.manager.walkThroughPlaylistNaming()
            }
        }
    }
    
    @IBAction func onDismissWalkThrough2(_ sender: Any) {
        self.dismissWalkThrough2()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_select_practice_item" {
            let controller = segue.destination as! PracticeItemSelectViewController
            controller.parentViewModel = self.viewModel
        } else if segue.identifier == "sid_finish" {
            let controller = segue.destination as! PlaylistFinishViewController
            controller.playlistDetailsViewModel = self.viewModel
        } else if segue.identifier == "sid_edit_duration" {
            let controller = segue.destination as! PlaylistPracticeDurationKeyboardViewController
            controller.viewModel = self.viewModel
        }
    }
    
    func configureGUI() {
        self.buttonEditName.isHidden = true
        self.tableViewMain.tableFooterView = UIView()
        self.tableViewMain.allowsSelectionDuringEditing = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        longPressGesture.minimumPressDuration = 0.48
        self.tableViewMain.addGestureRecognizer(longPressGesture)
        
        self.buttonStartPlaylist.isEnabled = false
        self.buttonStartPlaylist.alpha = 0.5
        
        self.buttonEditPlaylistNameLarge.isHidden = false
        
        self.viewKeyboardDismiss.isHidden = true
    }
    
    @IBAction func onBack(_ sender: Any) {
        ModacityAnalytics.LogStringEvent("Playlist Back Button", extraParamName: "duringSession", extraParamValue: self.isPlaying)
        if self.isPlaying {
            
            let alertController = UIAlertController(title: nil, message: "This will end your practice session. Are you sure to close the page?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                
                if self.viewModel.playlistName == "" {
                    self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
                    self.viewModel.addPracticeTotalTime(inSec: self.playlistPracticeTotalTimeInSec)
                    if self.navigationController?.viewControllers.count == 1 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                
                self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
                self.viewModel.addPracticeTotalTime(inSec: self.playlistPracticeTotalTimeInSec)
                if self.navigationController?.viewControllers.count == 1 {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
            
        }
        
        self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
        self.viewModel.addPracticeTotalTime(inSec: self.playlistPracticeTotalTimeInSec)
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func onNotes(_ sender: Any) {
        let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNotesViewController") as! PracticeNotesViewController
        controller.playlistViewModel = self.viewModel
        controller.noteIsForPlaylist = true
        self.navigationController?.pushViewController(controller, animated: true)
        ModacityAnalytics.LogStringEvent("Tapped Playlist Notes", extraParamName: "playlistName", extraParamValue: controller.playlistViewModel.playlistName)
    }
    
    
    @IBAction func onEditName(_ sender: Any) {
        if self.showingWalkThroughNaming {
            self.dismissWalkThroughNaming()
        }
        self.changeNameEditMode()
    }
    
    @IBAction func onDidEndOnExitOnNameInputField(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onEditingChangedOnNameInputField(_ sender: Any) {
        self.viewModel.playlistName = self.textfieldPlaylistName.text ?? ""
        if self.viewModel.playlistName != "" {
            self.labelPlaylistName.alpha = 1.0
        } else {
            self.labelPlaylistName.alpha = 0.25
        }
    }
    
    func changeNameEditMode() {
        isNameEditing = !isNameEditing
        if isNameEditing {
            self.buttonEditPlaylistNameLarge.isHidden = true
            self.labelPlaylistName.isHidden = true
            self.textfieldPlaylistName.isHidden = false
            self.textfieldPlaylistName.becomeFirstResponder()
            self.viewKeyboardDismiss.isHidden = false
        } else {
            self.buttonEditPlaylistNameLarge.isHidden = false
            self.labelPlaylistName.isHidden = false
            self.textfieldPlaylistName.isHidden = true
            self.textfieldPlaylistName.resignFirstResponder()
            self.viewKeyboardDismiss.isHidden = true
        }
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "playlistName") { (_, _, newValue) in
            self.labelPlaylistName.text = newValue as? String ?? ""
            if self.labelPlaylistName.text != "" {
                self.labelPlaylistName.alpha = 1.0
                self.buttonEditName.isHidden = false
            } else {
                self.labelPlaylistName.text = "Tap to Save Playlist"
                self.labelPlaylistName.alpha = 0.25
                self.buttonEditName.isHidden = true
            }
        }
        
        self.viewModel.subscribe(to: "total_improvements") { (_, _, improvements) in
            self.labelImprovementsCount.text = "\(improvements as? Int ?? 0)"
        }
        
        self.viewModel.subscribe(to: "practiceItems") { (_, old, _) in
            if let practiceItems = old as? [String] {
                if practiceItems.count == 0 {
                    self.buttonStartPlaylist.isEnabled = true
                    self.buttonStartPlaylist.alpha = 1.0
                }
            } else {
                self.buttonStartPlaylist.isEnabled = true
                self.buttonStartPlaylist.alpha = 1.0
            }
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "editingRow") { (event, oldrow, newrow) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "timePracticed") { (_, _, _) in
            self.tableViewMain.reloadData()
        }
        
        self.viewModel.subscribe(to: "countDownTimer") { (_, _, _) in
            self.tableViewMain.reloadData()
        }
        
        if let parent = self.parentViewModel {
            if parent.deliverPlaylist != nil {
                
                self.viewModel.setPlaylist(parent.deliverPlaylist)
                self.textfieldPlaylistName.text = self.viewModel.playlistName
                
                self.buttonStartPlaylist.isEnabled = true
                self.buttonStartPlaylist.alpha = 1.0
                
            } else if parent.deliverPracticeItem != nil {
                
                self.viewModel.addPracticeItems([parent.deliverPracticeItem])
                
            }
        }
    }
    
    func showSessionTime() {
        if let sessionStartedTime = self.sessionStarted {
            let now = Date().timeIntervalSince1970
            let timerInSec = self.viewModel.totalPracticedTime() + self.sessionPlayedInPlaylistPage + Int(now - (sessionStartedTime.timeIntervalSince1970))
            self.labelTimer.text = String(format: "%02d", timerInSec / 3600) + ":" +
                String(format:"%02d", (timerInSec % 3600) / 60) + ":" +
                String(format:"%02d", timerInSec % 60)
        } else {
            let timerInSec = self.viewModel.totalPracticedTime() + self.sessionPlayedInPlaylistPage
            self.labelTimer.text = String(format: "%02d", timerInSec / 3600) + ":" +
                String(format:"%02d", (timerInSec % 3600) / 60) + ":" +
                String(format:"%02d", timerInSec % 60)
        }
    }
    
    @objc func onSessionTimer() {
        self.showSessionTime()
    }
    
    func startPractice(withItem: Int) {
        self.sessionTimer = Timer(timeInterval: 0.2, target: self, selector: #selector(onSessionTimer), userInfo: nil, repeats: true)
        self.isPlaying = true
        self.currentRow = 0
        self.tableViewMain.reloadData()
        self.playingStartedTime = Date()
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_finish"), for: .normal)
        self.buttonBack.isHidden = true
        self.imgBack.isHidden = true
        self.sessionPlayedInPlaylistPage = 0
        self.viewModel.currentPracticeEntry = self.viewModel.playlistPracticeEntries[withItem]
        var controllerId = "PracticeViewController"
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            controllerId = "PracticeViewControllerSmallSizes"
        }
        let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: controllerId) as! PracticeViewController
        controller.playlistViewModel = self.viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onStart(_ sender: Any) {
        
        AppOveralDataManager.manager.storeFirstPlaylist()
        
        if self.showingWalkThrough1 {
            self.dismissWalkThrough1(withSetting: true)
        }
        
        if !self.viewWalkThrough2.isHidden {
            self.viewWalkThrough2.isHidden = true
            AppOveralDataManager.manager.walkThroughPlaylistFinish()
        }
        
        if !self.isPlaying {
            ModacityAnalytics.LogStringEvent("Pressed Start Practice")
            self.startPractice(withItem: 0)
        } else {
            self.finishPlaylist()
        }
    }
    
    @IBAction func onDismissKeyboard(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onAddPracticeItem(_ sender: Any) {
        let controller = UIStoryboard(name: "practice_item", bundle: nil).instantiateViewController(withIdentifier: "PracticeItemSelectViewController") as! PracticeItemSelectViewController
        controller.parentViewModel = self.viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func finishPlaylist() {
        ModacityAnalytics.LogStringEvent("Pressed Finish Practice", extraParamName: "Practice Time", extraParamValue: self.playlistPracticeTotalTimeInSec)
        
        if let sessionTimer = self.sessionTimer {
            sessionTimer.invalidate()
        }
        
        self.isPlaying = false
        self.viewModel.sessionCompleted = true
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_start"), for: .normal)
        self.buttonBack.isHidden =  false
        self.imgBack.isHidden = false
        self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
        self.viewModel.addPracticeTotalTime(inSec: self.playlistPracticeTotalTimeInSec)
        self.viewModel.sessionDurationInSecond = Int(Date().timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
        if let sessionStartedTime = self.sessionStarted {
            self.sessionPlayedInPlaylistPage = self.sessionPlayedInPlaylistPage + Int(Date().timeIntervalSince1970 - sessionStartedTime.timeIntervalSince1970)
        }
        self.viewModel.sessionDurationInSecond = self.sessionPlayedInPlaylistPage + self.viewModel.totalPracticedTime()
        if let timer = self.sessionTimer {
            timer.invalidate()
            self.sessionTimer = nil
        }
        self.performSegue(withIdentifier: "sid_finish", sender: nil)
    }
}

extension PlaylistContentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.playlistPracticeEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistPracticeItemCell") as! PlaylistPracticeItemCell
        let practiceItem = self.viewModel.playlistPracticeEntries[indexPath.row]
        cell.confgure(for: practiceItem,
                      isFavorite: self.viewModel.isFavoritePracticeItem(forItemId: practiceItem.practiceItemId),
                      rate: self.viewModel.rating(forPracticeItemId: practiceItem.practiceItemId) ?? 0,
                      isEditing: indexPath.row == self.viewModel.editingRow,
                      duration: self.viewModel.duration(forPracticeItem: practiceItem.entryId))
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.viewModel.editingRow == indexPath.row {
            self.viewModel.editingRow = -1
        }
        if !self.isPlaying {
            self.startPractice(withItem: indexPath.row)
        } else {
            self.viewModel.currentPracticeEntry = self.viewModel.playlistPracticeEntries[indexPath.row]
            var controllerId = "PracticeViewController"
            if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
                controllerId = "PracticeViewControllerSmallSizes"
            }
            let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: controllerId) as! PracticeViewController
            controller.playlistViewModel = self.viewModel
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.viewModel.chaneOrder(source: sourceIndexPath.row, target: destinationIndexPath.row)
    }
    
    func customSnapshot(from view:UIView) -> UIView {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
    
    @objc func longPressGestureRecognized(_ sender:UILongPressGestureRecognizer) {
        
        let state = sender.state
        let location = sender.location(in: self.tableViewMain)
        let indexPath = self.tableViewMain.indexPathForRow(at: location)
        
        switch state {
        case .began:
            if let indexPath = indexPath {
                self.sourceIndexPath = indexPath
                if let cell = self.tableViewMain.cellForRow(at: indexPath) {
                    self.snapshot = self.customSnapshot(from:cell)
                    var center = cell.center
                    self.snapshot?.center = center
                    self.snapshot?.alpha = 0.0
                    self.tableViewMain.addSubview(snapshot!)
                    UIView.animate(withDuration: 0.25, animations: {
                        center.y = location.y
                        self.snapshot?.center = center
                        self.snapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        self.snapshot?.alpha = 0.98
                    }, completion: { (finished) in
                        cell.isHidden = true
                    })
                }
            }
            break
        case .changed:
            var center = self.snapshot?.center
            center!.y = location.y
            self.snapshot?.center = center!
            
            if let indexPath = indexPath {
                if !(indexPath == sourceIndexPath) {
                    self.viewModel.chaneOrder(source: indexPath.row, target: self.sourceIndexPath!.row)
                    self.tableViewMain.moveRow(at: sourceIndexPath!, to: indexPath)
                    sourceIndexPath = indexPath
                }
            }
            
            break
        default:
            if let cell = self.tableViewMain.cellForRow(at: sourceIndexPath!) {
                cell.isHidden = false
                cell.alpha = 1.0
                UIView.animate(withDuration: 0.25, animations: {
                    self.snapshot?.center = cell.center
                    self.snapshot?.transform = CGAffineTransform.identity
                    self.snapshot?.alpha = 0
                }, completion: { (finished) in
                    self.sourceIndexPath = nil
                    self.snapshot?.removeFromSuperview()
                    self.snapshot = nil
                })
            } else {
                print ("source cell is nil")
                self.sourceIndexPath = nil
                self.snapshot?.removeFromSuperview()
                self.snapshot = nil
            }
            return
        }
    }
}

extension PlaylistContentsViewController: PlaylistPracticeItemCellDelegate {
    func onLike(item: PracticeItem?) {
        if let item = item {
            self.viewModel.setLikePracticeItem(for: item)
            self.tableViewMain.reloadData()
        }
    }
    
    func onDelete(item: PlaylistPracticeEntry) {
        self.viewModel.editingRow = -1
        self.viewModel.deletePracticeItem(for: item)
    }
    
    func onClock(item: PlaylistPracticeEntry) {
        self.openClockEdit(for: item)
    }
    
    func onSwipeToLeft(on item:PlaylistPracticeEntry) {
        self.viewModel.setEditingRow(for: item)
    }
    
    func openClockEdit(for item:PlaylistPracticeEntry) {
        self.viewModel.clockEditingPracticeItemId = item.entryId
        self.performSegue(withIdentifier: "sid_edit_duration", sender: nil)
    }
    
    func onMenu(item: PlaylistPracticeEntry, buttonMenu: UIButton) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_row_clock", "text":"Set Timer"],
                                              ["icon":"icon_notes", "text":"Notes"],
                                              ["icon":"icon_row_delete", "text":"Remove"]]) { (row) in
                                                
                                                if row == 2 {
                                                    self.viewModel.editingRow = -1
                                                    self.viewModel.deletePracticeItem(for: item)
                                                } else if row == 0 {
                                                    self.openClockEdit(for: item)
                                                } else if row == 1 {
                                                    self.openNotes(for: item)
                                                }
                                                
                                        }
    }
    
    func openNotes(for item:PlaylistPracticeEntry) {
        ModacityAnalytics.LogEvent(.OpenNotes, extraParamName: "item", extraParamValue: item.name)
        let controller = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNotesViewController") as! PracticeNotesViewController
        controller.playlistViewModel = self.viewModel
        controller.practiceEntry = item
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

protocol PlaylistPracticeItemCellDelegate {
    func onLike(item: PracticeItem?)
    func onClock(item: PlaylistPracticeEntry)
    func onDelete(item: PlaylistPracticeEntry)
    
    func onSwipeToLeft(on item:PlaylistPracticeEntry)
    
    func onMenu(item: PlaylistPracticeEntry, buttonMenu: UIButton)
}

class  PlaylistPracticeItemCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var labelPracticeDuration: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var constraintForSubPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var labelCountDownTimer: UILabel!
    
    @IBOutlet weak var buttonMenu: UIButton!
    var delegate: PlaylistPracticeItemCellDelegate? = nil
    var practiceItem: PlaylistPracticeEntry!
    
    func confgure(for item:PlaylistPracticeEntry, isFavorite: Bool, rate: Double, isEditing: Bool, duration: Int?) {
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = Color.white.alpha(0.1)
        self.selectedBackgroundView = bgColorView
        
        self.practiceItem = item
        self.labelPracticeName.text = item.practiceItem()?.name ?? "___"
        
        if !isFavorite {
            self.buttonHeart.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonHeart.alpha = 0.3
        } else {
            self.buttonHeart.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonHeart.alpha = 1
        }
        
        self.ratingView.contentMode = .scaleAspectFit
        if let duration = duration {
            self.labelPracticeDuration.text = String(format:"%d:%02d", duration / 60, duration % 60)
            self.constraintForSubPanelHeight.constant = 16
            
            if rate > 0 {
                self.ratingView.isHidden = false
                self.ratingView.rating = rate
            } else {
                self.ratingView.isHidden = true
            }
        } else {
            self.labelPracticeDuration.text = ""
            if rate > 0 {
                self.ratingView.isHidden = false
                self.ratingView.rating = rate
                self.constraintForSubPanelHeight.constant = 16
            } else {
                self.ratingView.isHidden = true
                self.constraintForSubPanelHeight.constant = 0
            }
        }
        
        if let countDownTimer = item.countDownDuration {
            if countDownTimer > 0 {
                self.labelCountDownTimer.isHidden = false
                self.labelCountDownTimer.text = String(format: "%d:%02d", countDownTimer / 60, countDownTimer % 60)
            } else {
                self.labelCountDownTimer.isHidden = true
            }
        } else {
            self.labelCountDownTimer.isHidden = true
        }
    }
    
    @IBAction func onMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onMenu(item: self.practiceItem, buttonMenu: self.buttonMenu)
        }
    }
    
    @objc func handleSwipes() {
        if self.delegate != nil {
            self.delegate!.onSwipeToLeft(on: self.practiceItem)
        }
    }
    
    @IBAction func onHeart(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onLike(item: self.practiceItem.practiceItem())
        }
    }
}
