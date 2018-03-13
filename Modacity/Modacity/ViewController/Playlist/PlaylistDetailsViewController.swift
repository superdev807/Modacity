//
//  PlaylistDetailsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PlaylistPracticeItemDelegate {
    func onLike(item: String)
    func onClock(item: String)
    func onDelete(item: String)
    
    func onSwipeToLeft(on item:String)
}

class  PlaylistPracticeItem: UITableViewCell {
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var buttonClock: UIButton!
    @IBOutlet weak var labelPracticeDuration: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var constraintForSubPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var labelCountDownTimer: UILabel!
    
    var practiceItemName: String!
    var practiceItemEntryId: String!
    var delegate: PlaylistPracticeItemDelegate? = nil
    
    func confgure(for item:String, entryId: String, isFavorite: Bool, isEditing: Bool, duration: Int?, rating: Double?, countDownTimer: Int?) {
        
        self.practiceItemEntryId = entryId
        self.practiceItemName = item
        self.labelPracticeName.text = item
        
        if !isFavorite {
            self.buttonHeart.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonHeart.alpha = 0.3
        } else {
            self.buttonHeart.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonHeart.alpha = 1
        }
        
        self.buttonDelete.backgroundColor = Color(hexString: "#6815CE")
        self.buttonClock.backgroundColor = Color(hexString: "#2E64E5")
        
        if isEditing {
            self.buttonClock.isHidden = false
            self.buttonDelete.isHidden = false
        } else {
            self.buttonClock.isHidden = true
            self.buttonDelete.isHidden = true
        }
        
        self.ratingView.contentMode = .scaleAspectFit
        if let duration = duration {
            self.labelPracticeDuration.text = String(format:"%d:%02d", duration / 60, duration % 60)
            self.constraintForSubPanelHeight.constant = 16
            
            if let rating = rating {
                self.ratingView.isHidden = false
                self.ratingView.rating = rating
            } else {
                self.ratingView.isHidden = true
            }
        } else {
            self.labelPracticeDuration.text = ""
            if let rating = rating {
                self.ratingView.isHidden = false
                self.ratingView.rating = rating
                self.constraintForSubPanelHeight.constant = 16
            } else {
                self.ratingView.isHidden = true
                self.constraintForSubPanelHeight.constant = 0
            }
        }
        
        if let countDownTimer = countDownTimer {
            if countDownTimer > 0 {
                self.labelCountDownTimer.isHidden = false
                self.labelCountDownTimer.text = String(format: "%d:%02d", countDownTimer / 60, countDownTimer % 60)
            } else {
                self.labelCountDownTimer.isHidden = true
            }
        } else {
            self.labelCountDownTimer.isHidden = true
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
        leftSwipe.direction = .left
        self.contentView.addGestureRecognizer(leftSwipe)
        
    }
    
    @objc func handleSwipes() {
        if self.delegate != nil {
            self.delegate!.onSwipeToLeft(on: self.practiceItemEntryId)
        }
    }
    
    @IBAction func onHeart(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onLike(item: self.practiceItemName)
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onDelete(item: self.practiceItemEntryId)
        }
    }
    
    @IBAction func onClockl(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onClock(item: self.practiceItemEntryId)
        }
    }
}

class PlaylistDetailsViewController: UIViewController {

    @IBOutlet weak var labelPlaylistName: UILabel!
    @IBOutlet weak var textfieldPlaylistName: UITextField!
    @IBOutlet weak var buttonEditName: UIButton!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var buttonStartPlaylist: UIButton!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var buttonAddPracticeItem: UIButton!
    @IBOutlet weak var constraintHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelImprovementsCount: UILabel!
    
    
    var isNameEditing = false
    var parentViewModel: PlaylistDeliverModel? = nil
    var viewModel = PlaylistDetailsViewModel()
    var isPlaying = false
    var playingStartedTime: Date? = nil
    var sessionTimer : Timer?
    var currentRow = 0
    var playlistPracticeTotalTimeInSec = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if AppUtils.iphoneIsXModel() {
            self.constraintHeaderImageViewHeight.constant = 200
        } else {
            self.constraintHeaderImageViewHeight.constant = 180
        }
        self.configureGUI()
        self.bindViewModel()
    }
    
    deinit {
        if self.sessionTimer != nil {
            self.sessionTimer!.invalidate()
            self.sessionTimer = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_select_practice_item" {
            let controller = segue.destination as! PracticeItemListViewController
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
        self.tableViewMain.tableFooterView = UIView()
        self.tableViewMain.isEditing = true
        self.tableViewMain.allowsSelectionDuringEditing = true
        
        self.buttonStartPlaylist.isEnabled = false
        self.buttonStartPlaylist.alpha = 0.5
    }

    @IBAction func onBack(_ sender: Any) {
        
        if self.isPlaying {
            let alertController = UIAlertController(title: nil, message: "This will end your practice session. Are you sure to close the page?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                let currentTime = Date()
                self.playlistPracticeTotalTimeInSec = Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
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
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func onEditName(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onDidEndOnExitOnNameInputField(_ sender: Any) {
        self.changeNameEditMode()
    }
    
    @IBAction func onEditingChangedOnNameInputField(_ sender: Any) {
        self.viewModel.playlistName = self.textfieldPlaylistName.text ?? ""
    }
    
    func changeNameEditMode() {
        isNameEditing = !isNameEditing
        if isNameEditing {
            self.labelPlaylistName.isHidden = true
            self.textfieldPlaylistName.isHidden = false
            self.textfieldPlaylistName.becomeFirstResponder()
            self.buttonEditName.setImage(UIImage(named:"icon_done"), for: .normal)
        } else {
            self.labelPlaylistName.isHidden = false
            self.textfieldPlaylistName.isHidden = true
            self.textfieldPlaylistName.resignFirstResponder()
            self.buttonEditName.setImage(UIImage(named:"icon_pen_white"), for: .normal)
        }
    }
    
    func bindViewModel() {
        
        self.viewModel.subscribe(to: "playlistName") { (_, _, newValue) in
            self.labelPlaylistName.text = newValue as? String ?? ""
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
            self.viewModel.setPlaylist(parent.deliverPlaylist)
            self.textfieldPlaylistName.text = self.viewModel.playlistName
            
            self.buttonStartPlaylist.isEnabled = true
            self.buttonStartPlaylist.alpha = 1.0
        }
    }
    
    func startPractice(withItem: Int) {
        self.isPlaying = true
        self.currentRow = 0
        self.tableViewMain.reloadData()
        self.playingStartedTime = Date()
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_finish"), for: .normal)
        
        self.sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
            let currentTime = Date()
            let timerInSec = Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
            self.playlistPracticeTotalTimeInSec = timerInSec
            DispatchQueue.main.async {
                self.labelTimer.text = String(format: "%02d", timerInSec / 3600) + ":" +
                    String(format:"%02d", (timerInSec % 3600) / 60) + ":" +
                    String(format:"%02d", timerInSec % 60)
            }
        })
        
        self.viewModel.currentPracticeItem = self.viewModel.practiceItems[withItem]
        let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        controller.playlistViewModel = self.viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onStart(_ sender: Any) {
        
        if !self.isPlaying {
            self.startPractice(withItem: 0)
        } else {
            
            let currentTime = Date()
            self.playlistPracticeTotalTimeInSec = Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
            self.viewModel.addPracticeTotalTime(inSec: self.playlistPracticeTotalTimeInSec)
            
            if let sessionTimer = self.sessionTimer {
                sessionTimer.invalidate()
            }
            
            self.isPlaying = false
            self.viewModel.sessionCompleted = true
            self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_start"), for: .normal)
            self.viewModel.sessionDurationInSecond = Int(Date().timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
            self.performSegue(withIdentifier: "sid_finish", sender: nil)
            
        }
    }
}

extension PlaylistDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.practiceItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistPracticeItem") as! PlaylistPracticeItem
        let practiceItem = self.viewModel.practiceItems[indexPath.row]
        cell.confgure(for: practiceItem.name,
                      entryId: practiceItem.entryId,
                      isFavorite: self.viewModel.isFavoritePracticeItem(for: practiceItem.name),
                      isEditing: indexPath.row == self.viewModel.editingRow,
                      duration: self.viewModel.duration(forPracticeItem: practiceItem.entryId),
                      rating: self.viewModel.ratingValue(for: practiceItem.name),
                      countDownTimer: /*self.viewModel.countDownTimer[practiceItem.name]*/practiceItem.countDownDuration)
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
            self.viewModel.currentPracticeItem = self.viewModel.practiceItems[indexPath.row]
            let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
            controller.playlistViewModel = self.viewModel
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == self.viewModel.editingRow {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.viewModel.chaneOrder(source: sourceIndexPath.row, target: destinationIndexPath.row)
    }
}

extension PlaylistDetailsViewController: PlaylistPracticeItemDelegate {
    func onLike(item: String) {
        self.viewModel.setLikePracticeItem(for: item)
        self.tableViewMain.reloadData()
    }
    
    func onDelete(item: String) {
        self.viewModel.editingRow = -1
        self.viewModel.deletePracticeItem(for: item)
    }
    
    func onClock(item: String) {
        self.openClockEdit(for: item)
    }
    
    func onSwipeToLeft(on item:String) {
        self.viewModel.setEditingRow(for: item)
    }
    
    func openClockEdit(for item:String) {
        self.viewModel.clockEditingPracticeItemId = item
        self.performSegue(withIdentifier: "sid_edit_duration", sender: nil)
    }
}
