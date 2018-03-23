//
//  PlaylistDetailsViewController.swift
//  Modacity
//
//  Created by Perfect Engineer on 2/28/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PlaylistPracticeItemDelegate {
    func onLike(item: PracticeItem?)
    func onClock(item: PlaylistPracticeEntry)
    func onDelete(item: PlaylistPracticeEntry)
    
    func onSwipeToLeft(on item:PlaylistPracticeEntry)
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
    
    var delegate: PlaylistPracticeItemDelegate? = nil
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
        
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes))
//        leftSwipe.direction = .left
//        self.contentView.addGestureRecognizer(leftSwipe)
        
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
    
    @IBAction func onDelete(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onDelete(item: self.practiceItem)
        }
    }
    
    @IBAction func onClockl(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onClock(item: self.practiceItem)
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
    @IBOutlet weak var buttonEditPlaylistNameLarge: UIButton!
    
    
    var isNameEditing = false
    var parentViewModel: PlaylistDeliverModel? = nil
    var viewModel = PlaylistDetailsViewModel()
    var isPlaying = false
    var playingStartedTime: Date? = nil
    var sessionTimer : Timer? = nil
    var currentRow = 0
    var playlistPracticeTotalTimeInSec = 0
    
    var snapshot: UIView? = nil
    var sourceIndexPath: IndexPath? = nil
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewMain.reloadData()
        self.showSessionTime()
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
        self.tableViewMain.allowsSelectionDuringEditing = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        self.tableViewMain.addGestureRecognizer(longPressGesture)
        
        self.buttonStartPlaylist.isEnabled = false
        self.buttonStartPlaylist.alpha = 0.5
        
        self.buttonEditPlaylistNameLarge.isHidden = false
    }

    @IBAction func onBack(_ sender: Any) {
        
        if self.isPlaying {
            let alertController = UIAlertController(title: nil, message: "This will end your practice session. Are you sure to close the page?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
//                let currentTime = Date()
                self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()//Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
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
            self.buttonEditPlaylistNameLarge.isHidden = true
            self.labelPlaylistName.isHidden = true
            self.textfieldPlaylistName.isHidden = false
            self.textfieldPlaylistName.becomeFirstResponder()
            self.buttonEditName.setImage(UIImage(named:"icon_done"), for: .normal)
        } else {
            self.buttonEditPlaylistNameLarge.isHidden = false
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
    
    func showSessionTime() {
        let timerInSec = self.viewModel.totalPracticedTime()
        self.labelTimer.text = String(format: "%02d", timerInSec / 3600) + ":" +
                                String(format:"%02d", (timerInSec % 3600) / 60) + ":" +
                                 String(format:"%02d", timerInSec % 60)
    }
    
    
    func startPractice(withItem: Int) {
        self.isPlaying = true
        self.currentRow = 0
        self.tableViewMain.reloadData()
        self.playingStartedTime = Date()
        self.buttonStartPlaylist.setImage(UIImage(named:"btn_playlist_finish"), for: .normal)
        
//        self.sessionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (_) in
//            let currentTime = Date()
//            let timerInSec = Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
//            self.playlistPracticeTotalTimeInSec = timerInSec
//            DispatchQueue.main.async {
//                self.labelTimer.text = String(format: "%02d", timerInSec / 3600) + ":" +
//                    String(format:"%02d", (timerInSec % 3600) / 60) + ":" +
//                    String(format:"%02d", timerInSec % 60)
//            }
//        })
        
        self.viewModel.currentPracticeEntry = self.viewModel.playlistPracticeEntries[withItem]
        let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
        controller.playlistViewModel = self.viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onStart(_ sender: Any) {
        
        if !self.isPlaying {
            self.startPractice(withItem: 0)
        } else {
            
//            let currentTime = Date()
            self.playlistPracticeTotalTimeInSec = self.viewModel.totalPracticedTime()//Int(currentTime.timeIntervalSince1970 - self.playingStartedTime!.timeIntervalSince1970)
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
        return self.viewModel.playlistPracticeEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistPracticeItem") as! PlaylistPracticeItem
        let practiceItem = self.viewModel.playlistPracticeEntries[indexPath.row]
        cell.confgure(for: practiceItem,
                      isFavorite: self.viewModel.isFavoritePracticeItem(forItemId: practiceItem.practiceItemId),
                      rate: self.viewModel.rating(forPracticeItemId: practiceItem.practiceItemId) ?? 0,
                      isEditing: indexPath.row == self.viewModel.editingRow,
                      duration: self.viewModel.duration(forPracticeItem: practiceItem.entryId))
        cell.accessoryType = .disclosureIndicator
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
            let controller = UIStoryboard(name: "practice", bundle: nil).instantiateViewController(withIdentifier: "PracticeViewController") as! PracticeViewController
            controller.playlistViewModel = self.viewModel
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
//        if indexPath.row == self.viewModel.editingRow {
//            return false
//        }
//        return true
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.viewModel.chaneOrder(source: sourceIndexPath.row, target: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            self.viewModel.editingRow = -1
            self.viewModel.deletePracticeItem(for: self.viewModel.playlistPracticeEntries[indexPath.row])
        }
        delete.setIcon(iconImage: UIImage(named:"icon_delete_white")!, backColor: Color(hexString: "#6815CE"), cellHeight: 64, iconSizePercentage: 0.25)
        let calendar = UITableViewRowAction(style: .default, title: "") { (action, indexPath) in
            self.openClockEdit(for: self.viewModel.playlistPracticeEntries[indexPath.row])
        }
        calendar.setIcon(iconImage: UIImage(named:"icon_row_clock")!, backColor: Color(hexString: "#2E64E5"), cellHeight: 64, iconSizePercentage: 0.25)
        
        return [delete, calendar]
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
            let cell = self.tableViewMain.cellForRow(at: sourceIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 1.0
            UIView.animate(withDuration: 0.25, animations: {
                self.snapshot?.center = cell!.center
                self.snapshot?.transform = CGAffineTransform.identity
                self.snapshot?.alpha = 0
            }, completion: { (finished) in
                self.sourceIndexPath = nil
                self.snapshot?.removeFromSuperview()
                self.snapshot = nil
            })
            return
        }
    }
}

extension PlaylistDetailsViewController: PlaylistPracticeItemDelegate {
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
}
