//
//  PlaylistDetailsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/28/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
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
    
    @IBOutlet weak var constraintForWalkthroughCloseButton1TopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintForWalkthroughCloseButton2TopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelSumOfTimers: UILabel!
    
    var isNameEditing = false
    var parentViewModel: PlaylistAndPracticeDeliverModel? = nil
    var viewModel = PlaylistContentsViewModel()
    var isPlaying = false
    var playingStartedTime: Date? = nil
    var currentRow = 0
    var playlistPracticeTotalTimeInSec = 0
    
    var snapshot: UIView? = nil
    var sourceIndexPath: IndexPath? = nil
    
    var shouldStartFromPracticeSelection = false
    var waitingPracticeSelection = false
    
    var showingWalkThrough1 = false
    var showingWalkThroughNaming = false
    var justLastPracticeItemFinished = false
    
    // MARK:- Process for practice break
    var practiceBreakShown = false
    var practiceBreakTime: Int! = 0
    var lastPracticeBreakTimeShown: Int! = 0
    var viewPracticeBreakPrompt: PracticeBreakPromptView! = nil
    
    var animatedShowing = false
    
    var sortKey = SortKeyOption.name
    var sortOption = SortOption.descending
    var deliveredSectionNames = [String]()
    var deliveredPracticeItems = [PracticeItem]()
    var deliveredSectionedPracticeItems = [String:[PracticeItem]]()
    var dataDelivered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iPhoneXorXRorXS() {
            self.constraintHeaderImageViewHeight.constant = 170
            self.constraintForWalkthroughCloseButton1TopSpace.constant = 40
            self.constraintForWalkthroughCloseButton2TopSpace.constant = 40
        } else {
            self.constraintHeaderImageViewHeight.constant = 150
            self.constraintForWalkthroughCloseButton1TopSpace.constant = 0
            self.constraintForWalkthroughCloseButton2TopSpace.constant = 0
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
            self.viewModel.playlistName = "My First Practice Session"
            self.buttonEditName.isHidden = false
            self.openPracticeItemsSelection()
        } else {
            self.processWalkThrough()
        }
      
        self.practiceBreakTime = AppOveralDataManager.manager.practiceBreakTime() * 60
    }
    
    deinit {
    }
    
    func openPracticeItemsSelection() {
        let controller = UIStoryboard(name: "practice_item", bundle: nil).instantiateViewController(withIdentifier: "PracticeItemSelectViewController") as! PracticeItemSelectViewController
        controller.shouldSelectPracticeItems = true
        controller.parentViewModel = self.viewModel
        controller.parentController = self
        controller.animatedShowing = self.animatedShowing
        
        if self.shouldStartFromPracticeSelection {
            controller.sortKey = self.sortKey
            controller.sortOption = self.sortOption
            controller.dataDelivered = self.dataDelivered
            controller.sectionNames = self.deliveredSectionNames
            controller.practiceItems = self.deliveredPracticeItems
            controller.filteredPracticeItems = self.deliveredPracticeItems
            controller.sectionedPracticeItems = self.deliveredSectionedPracticeItems
        }
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func practiceItemsSelected() {
        self.waitingPracticeSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
        
        if self.waitingPracticeSelection {
            self.waitingPracticeSelection = false
            self.processWalkThrough()
        } else {
            if self.justLastPracticeItemFinished {
                self.justLastPracticeItemFinished = false
                if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_playlist_finish") {
                    self.showWalkThrough2()
                }
            }
        }
        
        if self.isPlaying {
            self.showSessionTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func processWalkThrough() {
        if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_first_playlist") {
            self.showWalkThrough1()
        } else {
            if self.viewWalkThrough1.superview != nil {
                self.viewWalkThrough1.removeFromSuperview()
            }
            
            if self.viewModel.playlistName == "" {
                if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_playlist_naming") {
                    self.showWalkThroughNaming()
                } else {
                    if self.viewWalkThroughNaming.superview != nil {
                        self.viewWalkThroughNaming.removeFromSuperview()
                    }
                    if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_first_playlist") {
                        self.showWalkThrough1()
                    } else {
                        self.viewWalkThrough1.removeFromSuperview()
                    }
                }
            } else {
                if self.viewWalkThroughNaming.superview != nil {
                    self.viewWalkThroughNaming.removeFromSuperview()
                }
                if !AppOveralDataManager.manager.walkThroughFlagChecking(key: "walkthrough_first_playlist") {
                    self.showWalkThrough1()
                } else {
                    self.viewWalkThrough1.removeFromSuperview()
                }
            }
        }
    }
    
    func showWalkThrough1() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Intro - Displayed")
        self.showingWalkThrough1 = true
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThrough1.alpha = 1
        }
    }
    
    func showWalkThrough2() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Finish - Displayed")
        self.viewWalkThrough2.isHidden = false
        self.viewWalkThrough2.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThrough2.alpha = 1
        }
    }
    
    func dismissWalkThrough1(withSetting: Bool) {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Intro - Dismissed")
        self.viewWalkThrough1.removeFromSuperview()
        AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_first_playlist", value: true)
        self.showingWalkThrough1 = false
    }
    
    func dismissWalkThrough2() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Finish - Dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkThrough2.alpha = 0
        }) { (finished) in
            if finished {
                self.viewWalkThrough2.isHidden = true
                AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_playlist_finish", value: true)
            }
        }
    }
    
    @IBAction func onDismissWalkThrough1(_ sender: Any) {
        self.dismissWalkThrough1(withSetting: false)
    }
    
    func showWalkThroughNaming() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Naming - Displayed")
        self.showingWalkThroughNaming = true
        UIView.animate(withDuration: 0.5) {
            self.viewWalkThroughNaming.alpha = 1
        }
    }
    
    func dismissWalkThroughNaming() {
        ModacityAnalytics.LogStringEvent("Walkthrough - Playlist Naming - Dismissed")
        UIView.animate(withDuration: 0.5, animations: {
            self.viewWalkThroughNaming.alpha = 0
        }) { (finished) in
            if finished {
                self.viewWalkThroughNaming.removeFromSuperview()
                self.showingWalkThroughNaming = false
                AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_playlist_naming", value: true)
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
        } else if segue.identifier == "sid_finish" || segue.identifier == "sid_finish_ipad_size" {
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
                    if self.navigationController?.viewControllers.count == 1 {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                
                self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
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
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func onNotes(_ sender: Any) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
        let detailsViewController = controller.viewControllers[0] as! DetailsViewController
        detailsViewController.playlistItemId = self.viewModel.playlist.id
        detailsViewController.startTabIdx = 2
        self.present(controller, animated: true, completion: nil)
        ModacityAnalytics.LogStringEvent("Tapped Playlist Notes", extraParamName: "playlistName", extraParamValue: self.viewModel.playlist.name)
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
            if self.viewModel.playlistPracticeEntries.count > 0 {
                self.buttonStartPlaylist.isEnabled = true
                self.buttonStartPlaylist.alpha = 1.0
            } else {
                self.buttonStartPlaylist.isEnabled = false
                self.buttonStartPlaylist.alpha = 0.5
            }
            self.refreshData()
        }
        
        self.viewModel.subscribe(to: "editingRow") { (event, oldrow, newrow) in
            self.refreshData()
        }
        
        self.viewModel.subscribe(to: "timePracticed") { (_, _, _) in
            self.refreshData()
        }
        
        self.viewModel.subscribe(to: "countDownTimer") { (_, _, _) in
            self.refreshData()
        }
        
        if let parent = self.parentViewModel {
            if parent.deliverPlaylist != nil {
                
                self.viewModel.setPlaylist(parent.deliverPlaylist)
                self.textfieldPlaylistName.text = self.viewModel.playlistName
                
                if parent.deliverPlaylist.playlistPracticeEntries != nil && parent.deliverPlaylist.playlistPracticeEntries.count > 0 {
                    self.buttonStartPlaylist.isEnabled = true
                    self.buttonStartPlaylist.alpha = 1.0
                } else {
                    self.buttonStartPlaylist.isEnabled = false
                    self.buttonStartPlaylist.alpha = 0.5
                }
                
            } else if parent.deliverPracticeItem != nil {
                self.viewModel.addPracticeItems([parent.deliverPracticeItem])
            }
        }
        
        self.refreshData()
    }
    
    func showPracticeBreakPrompt(with time: Int) {
        
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
        }
        self.viewPracticeBreakPrompt = PracticeBreakPromptView()
        self.view.addSubview(self.viewPracticeBreakPrompt)
        self.view.topAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.topAnchor).isActive = true
        self.view.leadingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.leadingAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.trailingAnchor).isActive = true
        self.practiceBreakShown = true
        self.viewPracticeBreakPrompt.delegate = self
        if #available(iOS 11.0, *) {
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        } else {
            self.view.bottomAnchor.constraint(equalTo: self.viewPracticeBreakPrompt.bottomAnchor).isActive = true
        }
        self.view.bringSubview(toFront: self.viewPracticeBreakPrompt)
        self.viewPracticeBreakPrompt.showPracticeTime(time)
        self.viewPracticeBreakPrompt.startCountUpTimer()
        self.lastPracticeBreakTimeShown = time
    }
    
    func startPractice(withItem: Int) {
        
        self.isPlaying = true
        self.currentRow = 0
        self.playingStartedTime = Date()
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_finish"), for: .normal)
        self.buttonBack.isHidden = true
        self.imgBack.isHidden = true
        
        self.viewModel.playlistPracticeData.playlistId = self.viewModel.playlist.id
        let now = Date()
        self.viewModel.playlistPracticeData.entryDateString = now.toString(format: "yy-MM-dd")
        self.viewModel.playlistPracticeData.fromTime = now.toString(format: "HH:mm:ss")
        self.viewModel.playlistPracticeData.started = now.timeIntervalSince1970
        self.viewModel.playlistPracticeData.practices = [String]()
        PlaylistDailyLocalManager.manager.saveNewPlaylistPracticing(self.viewModel.playlistPracticeData)
        
        self.viewModel.currentPracticeEntry = self.viewModel.playlistPracticeEntries[withItem]
        self.viewModel.sessionImproved = [ImprovedRecord]()
        self.viewModel.sessionTimeStarted = Date()

        self.openPracticeViewController()
    }
    
    @IBAction func onStart(_ sender: Any) {
        
        AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_first_playlist", value: true)
        AppOveralDataManager.manager.storeFirstPlaylist()
        
        if self.showingWalkThrough1 {
            self.dismissWalkThrough1(withSetting: true)
        }
        
        if !self.viewWalkThrough2.isHidden {
            self.viewWalkThrough2.isHidden = true
            AppOveralDataManager.manager.walkthroughSetFlag(key: "walkthrough_playlist_finish", value: true)
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
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
  
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.shufflePlaylist()
            ModacityDebugger.debug("SHAKEN!");
        }
    }
    
    func shufflePlaylist() {
        var last = self.viewModel.playlistPracticeEntries.count - 1
        
        while(last > 0)
        {
            let rand = Int(arc4random_uniform(UInt32(last)))
            self.viewModel.playlistPracticeEntries.swapAt(last, rand)
            last -= 1
        }
        self.refreshData()
    }
    
    func finishPlaylist() {
        self.practiceBreakShown = false
        ModacityAnalytics.LogStringEvent("Pressed Finish Practice", extraParamName: "Practice Time", extraParamValue: self.playlistPracticeTotalTimeInSec)
        
        self.isPlaying = false
        self.viewModel.sessionCompleted = true
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_start"), for: .normal)
        self.buttonBack.isHidden =  false
        self.imgBack.isHidden = false
        self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()
        self.viewModel.sessionDurationInSecond = Int(Date().timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
        self.viewModel.sessionDurationInSecond = self.viewModel.totalPracticedTime()
        self.viewModel.playlistPracticeData.practiceTimeInSeconds = self.viewModel.sessionDurationInSecond
        
        var practicesFound = [String:Bool]()
        
        for idx in (0..<self.viewModel.playlistPracticeData.practices.count).reversed() {
            let practiceDataId = self.viewModel.playlistPracticeData.practices[idx]
            if let found = practicesFound[practiceDataId] {
                if found {
                    ModacityDebugger.debug("FOUND DUPLICATED PRACTICE DATA ENTRY ID!")
                    self.viewModel.playlistPracticeData.practices.remove(at: idx)
                    continue
                }
            }
            practicesFound[practiceDataId] = true
        }
        
        PlaylistDailyLocalManager.manager.saveNewPlaylistPracticing(self.viewModel.playlistPracticeData)
        
        self.performSegue(withIdentifier: "sid_finish", sender: nil)
    }
}

extension PlaylistContentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.viewModel.totalSumOfRemainingTimers() > 0 {
                return 0
            } else {
                return 0
            }
        } else {
            return self.viewModel.playlistPracticeEntries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalSumCell")!
            if let label = cell.viewWithTag(10) as? UILabel {
                let countDownTimer = self.viewModel.totalSumOfRemainingTimers()
                label.text = String(format: "Timers: %d:%02d", countDownTimer / 60, countDownTimer % 60)
            }
            return cell
        } else {
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if self.viewModel.editingRow == indexPath.row {
                self.viewModel.editingRow = -1
            }
            if !self.isPlaying {
                self.startPractice(withItem: indexPath.row)
            } else {
                
                self.viewModel.currentPracticeEntry = self.viewModel.playlistPracticeEntries[indexPath.row]
                self.viewModel.sessionImproved = [ImprovedRecord]()
                self.viewModel.sessionTimeStarted = Date()

                self.openPracticeViewController()
            }
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
                ModacityDebugger.debug ("source cell is nil")
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
            self.refreshData()
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
                                       rows: [["icon":"icon_notes", "text":"Details"],
                                              ["icon":"icon_row_clock", "text":"Set Timer"],
                                              ["icon":"icon_row_delete", "text":"Remove"]]) { (row) in
                                                
                                                if row == 2 {
                                                    self.viewModel.editingRow = -1
                                                    self.viewModel.deletePracticeItem(for: item)
                                                } else if row == 1 {
                                                    self.openClockEdit(for: item)
                                                } else if row == 0 {
                                                    self.openDetails(for: item)
                                                }
                                                
                                        }
    }
    
    func openDetails(for item:PlaylistPracticeEntry) {
        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: item.practiceItemId) {
            ModacityAnalytics.LogEvent(.OpenNotes, extraParamName: "item", extraParamValue: item.name)
            let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "DetailsScene") as! UINavigationController
            let detailsViewController = controller.viewControllers[0] as! DetailsViewController
            detailsViewController.practiceItemId = practice.id
            detailsViewController.startTabIdx = 2
            self.present(controller, animated: true, completion: nil)
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

extension PlaylistContentsViewController: PracticeBreakPromptViewDelegate {
    func dismiss(practiceBreakPromptView: PracticeBreakPromptView) {
        if self.viewPracticeBreakPrompt != nil {
            self.viewPracticeBreakPrompt.removeFromSuperview()
            self.viewPracticeBreakPrompt = nil
            self.practiceBreakShown = false
        }
    }
}

// MARK: - Session timer management
extension PlaylistContentsViewController {
    
    func showSessionTimer() {
        let playedSessionTime = self.viewModel.totalPracticedTime()
        self.labelTimer.text = String(format: "%02d", playedSessionTime / 3600) + ":" + String(format:"%02d", (playedSessionTime % 3600) / 60) + ":" + String(format:"%02d", playedSessionTime % 60)
    }
    
    func openPracticeViewController() {
        var controllerId = "PracticeViewController"
        if AppUtils.sizeModelOfiPhone() == .iphone4_35in || AppUtils.sizeModelOfiPhone() == .iphone5_4in {
            controllerId = "PracticeViewControllerSmallSizes"
        }
        let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: controllerId) as! PracticeViewController
        controller.parentContentViewController = self
        controller.playlistViewModel = self.viewModel
        
        if self.practiceBreakTime > 0 {
            controller.lastPracticeBreakTime = -1 * (self.viewModel.totalPracticedTime() % self.practiceBreakTime)
            controller.practiceBreakTime = self.practiceBreakTime
            
            ModacityDebugger.debug("last practice break time - \(controller.lastPracticeBreakTime ?? 0)")
            ModacityDebugger.debug("practice break time - \(self.practiceBreakTime ?? 0)")
            
        } else {
            controller.practiceBreakTime = 0
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func refreshData() {
        
        let countDownTimer = self.viewModel.totalSumOfRemainingTimers()
        self.labelSumOfTimers.text = String(format: "Timers: %d:%02d", countDownTimer / 60, countDownTimer % 60)
        if countDownTimer > 0 {
            self.constraintForHeaderViewHeight.constant = 40
        } else {
            self.constraintForHeaderViewHeight.constant = 0
        }
        self.tableViewMain.reloadData()
    }
}
