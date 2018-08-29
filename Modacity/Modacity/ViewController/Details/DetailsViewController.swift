//
//  DetailsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 21/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var practiceItemId: String!
    var playlistItemId: String!

    @IBOutlet weak var viewIndicatorTab1: UIView!
    @IBOutlet weak var viewIndicatorTab2: UIView!
    @IBOutlet weak var viewIndicatorTab3: UIView!
    @IBOutlet weak var viewIndicatorTab4: UIView!
    @IBOutlet weak var imageViewHeader: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var labelTab1: UILabel!
    @IBOutlet weak var labelTab2: UILabel!
    @IBOutlet weak var labelTab3: UILabel!
    @IBOutlet weak var labelTab4: UILabel!
    
    @IBOutlet weak var buttonMenu: UIButton!
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    
    var selectedTabIdx = -1
    
    var statisticsView:StatisticsView! = nil
    var recordingsView: RecordingsListView! = nil
    var notesView: NotesListView! = nil
    var historyListView: HistoryListView! = nil
    
    var playlistStatsView: PlaylistStatsView! = nil
    var playlistHistoryView: PlaylistHistoryView! = nil
    
    var premiumLockView: PremiumUpgradeLockView! = nil
    
    var constraintForContentTopSpace: NSLayoutConstraint!
    var constraintForPremiumUnlockTopSpace: NSLayoutConstraint!
    
    var currentNotesCount = 0
    
    var analyticsName: String = "Item Details" // can be "Playlist Details" or "Overview"
    var analyticsParam: String = "Put Item Name Here" // see initAnalytics
    var tabNames: [String] = ["Stats", "Recordings", "Notes", "History"] // used for analytics
    
    var startTabIdx = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.practiceItemId != nil {
            self.analyticsName = "Item Details"
            self.tabNames = ["Stats", "Recordings", "Notes", "History"]
            if let practiceItemData = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                self.labelTitle.text = practiceItemData.name
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                self.labelTitle.text = playlist.name
            }
        } else {
            ModacityAnalytics.LogStringEvent("Opened Overview")
            self.labelTitle.text = "Overview"
            self.labelTab3.text = "GOALS"
        }
        
        self.initAnalytics()
        
        self.viewIndicatorTab1.backgroundColor = Color(hexString: "#292947")
        self.viewIndicatorTab2.backgroundColor = Color(hexString: "#292947")
        self.viewIndicatorTab3.backgroundColor = Color(hexString: "#292947")
        self.viewIndicatorTab4.backgroundColor = Color(hexString: "#292947")
        selectTab(startTabIdx)
        
        NotificationCenter.default.addObserver(self, selector: #selector(processPremiumStatusChanged), name: AppConfig.appNotificationPremiumStatusChanged, object: nil)
        
        if AppUtils.iphoneIsXModel() {
            self.constraintForHeaderViewHeight.constant = 140
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_add_practice_history" {
            let controller = segue.destination as! UpdatePracticeEntryViewController
            controller.practiceItemId = self.practiceItemId
        }
    }
    
    func initAnalytics() {
        self.tabNames = ["Stats", "Recordings", "Notes", "History"]
        if self.practiceItemId != nil {
            self.analyticsName = "Item Details"
            
            if let practiceItemData = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                self.analyticsParam = practiceItemData.name
            }
            
        } else if self.playlistItemId != nil {
            self.analyticsName = "Playlist Details"
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                self.analyticsParam = playlist.name
            }
        } else {
            self.tabNames[2] = "Goals"
            self.analyticsName = "Overview"
            self.analyticsParam = "Overview"
        }
    }
    
    deinit {
        if self.recordingsView != nil {
            self.recordingsView.cleanPlaying()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.practiceItemId == nil && self.playlistItemId == nil {
            self.buttonMenu.setImage(UIImage(named: "icon_menu"), for: .normal)
        }
        
        if self.notesView != nil && self.selectedTabIdx == 2 {
            self.processNotes()
            
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                if self.currentNotesCount == 0 {
                    self.notesView.freeUserLock()
                } else {
                    self.notesView.lock()
                }
            } else {
                self.notesView.unlock()
            }
        }
        
        if self.historyListView != nil && self.selectedTabIdx == 3 {
            if self.practiceItemId != nil {
                self.historyListView.showHistory(for: self.practiceItemId)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.recordingsView != nil {
            self.recordingsView.stopPlaying()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        if self.practiceItemId == nil && self.playlistItemId == nil {
            self.sideMenuController?.showLeftViewAnimated()
        } else {
            if self.navigationController?.viewControllers.count == 1 {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension DetailsViewController {
    
    func attachPlaylistStatsView(_ animated:Bool = false) {
        
        if self.playlistStatsView == nil {
            self.playlistStatsView = PlaylistStatsView()
        }
        
        self.view.addSubview(self.playlistStatsView)
        self.playlistStatsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.playlistStatsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.playlistStatsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.constraintForContentTopSpace = self.playlistStatsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor)
        self.constraintForContentTopSpace.isActive = true
        self.view.bringSubview(toFront: self.playlistStatsView)
        
        if self.playlistItemId != nil {
            self.playlistStatsView.showStats(playlistId: self.playlistItemId)
        } else {
            self.playlistStatsView.showOverallStats()
        }
        
    }
    
    func detachPlaylistStatsView(_ animated:Bool = false) {
        self.playlistStatsView.removeFromSuperview()
    }
    
    func attachStatisticsView(_ animated:Bool = false) {
        
        if self.statisticsView == nil {
            self.statisticsView = StatisticsView()
        }
        
        self.view.addSubview(self.statisticsView)
        self.statisticsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.statisticsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.statisticsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.constraintForContentTopSpace = self.statisticsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor)
        self.constraintForContentTopSpace.isActive = true
        self.view.bringSubview(toFront: self.statisticsView)
        
        self.statisticsView.showStats(practice: self.practiceItemId)
        
    }
    
    func detachStatisticsView(_ animated:Bool = false) {
        self.statisticsView.removeFromSuperview()
    }
    
    func attachRecordingView(_ animated:Bool = false) {
        
        if self.recordingsView == nil {
            self.recordingsView = RecordingsListView()
        }
        
        self.view.addSubview(self.recordingsView)
        self.recordingsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.recordingsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.recordingsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.recordingsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
        self.view.bringSubview(toFront: self.recordingsView)
        
        if self.practiceItemId != nil {
            self.recordingsView.showRecordings(RecordingsLocalManager.manager.loadRecordings(forPracticeId: self.practiceItemId))
        } else if self.playlistItemId != nil {
            self.recordingsView.showRecordings(RecordingsLocalManager.manager.loadRecordings(forPlaylistId: self.playlistItemId))
        } else {
            self.recordingsView.showRecordings(RecordingsLocalManager.manager.loadRecordings())
        }
        self.recordingsView.delegate = self
    }
    
    func detachRecordingView(_ animated:Bool = false) {
        self.recordingsView.removeFromSuperview()
    }
    
    @discardableResult
    func attatchNotesView(_ animated:Bool = false)->Int {
        
        if self.notesView == nil {
            self.notesView = NotesListView()
            self.notesView.delegate = self
        }
        let notesCount = self.processNotes()
        self.view.addSubview(self.notesView)
        self.notesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.notesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.notesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.notesView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
        self.view.bringSubview(toFront: self.notesView)
        
        if self.practiceItemId == nil && self.playlistItemId == nil {
            self.notesView.textfieldAddNote.attributedPlaceholder = NSAttributedString(string: "Add a goal...", attributes: [.foregroundColor: Color.white.alpha(0.5)])
        }
        
        return notesCount
    }
    
    func detachNotesView(_ animated:Bool = false) {
        self.notesView.removeFromSuperview()
    }
    
    func attachHistoryView(_ animated:Bool = false) {
        
        if self.practiceItemId != nil {
            
            if self.historyListView == nil {
                self.historyListView = HistoryListView()
            }
            self.view.addSubview(self.historyListView)
            self.historyListView.delegate = self
            self.historyListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.historyListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.historyListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            self.constraintForContentTopSpace = self.historyListView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor)
            self.constraintForContentTopSpace.isActive = true
            self.view.bringSubview(toFront: self.historyListView)
        
            self.historyListView.showHistory(for: self.practiceItemId)
            
        } else {
            
            if self.playlistHistoryView == nil {
                self.playlistHistoryView = PlaylistHistoryView()
            }
            self.view.addSubview(self.playlistHistoryView)
            self.playlistHistoryView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.playlistHistoryView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.playlistHistoryView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.playlistHistoryView.delegate = self
            self.constraintForContentTopSpace = self.playlistHistoryView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor)
            self.constraintForContentTopSpace.isActive = true
            self.view.bringSubview(toFront: self.playlistHistoryView)
            self.playlistHistoryView.showHistory(for: self.playlistItemId)
            
        }
        
    }
    
    func detachHistoryView(_ animated:Bool = false) {
        if self.practiceItemId != nil {
            self.historyListView.removeFromSuperview()
        } else if self.playlistItemId != nil {
            self.playlistHistoryView.removeFromSuperview()
        } else {
            self.playlistHistoryView.removeFromSuperview()
        }
    }
}

extension DetailsViewController {
    
    @IBAction func onTab1(_ sender: Any) {
        selectTab(0)
    }
    
    @IBAction func onTab2(_ sender: Any) {
        selectTab(1)
    }
    
    @IBAction func onTab3(_ sender: Any) {
        selectTab(2)
    }
    
    @IBAction func onTab4(_ sender: Any) {
        selectTab(3)
    }
    
    func deselectTabLabels() {
        self.labelTab1.font = UIFont.systemFont(ofSize: 11)
        self.labelTab2.font = UIFont.systemFont(ofSize: 11)
        self.labelTab3.font = UIFont.systemFont(ofSize: 11)
        self.labelTab4.font = UIFont.systemFont(ofSize: 11)
    }
    
    func selectTab(_ idx: Int) {
        if idx == self.selectedTabIdx {
            return
        }
        
        let eventName = self.analyticsName + " - " + self.tabNames[idx]
        
        ModacityAnalytics.LogStringEvent(eventName, extraParamName: "Detail", extraParamValue: self.analyticsParam)
        
        let currentTabIdx = self.selectedTabIdx
        
        self.viewIndicatorTab1.isHidden = true
        self.viewIndicatorTab2.isHidden = true
        self.viewIndicatorTab3.isHidden = true
        self.viewIndicatorTab4.isHidden = true
        
        deselectTabLabels()
        
        switch currentTabIdx {
        case 0:
            if self.practiceItemId != nil {
                self.detachStatisticsView(true)
            } else if self.playlistItemId != nil {
                self.detachPlaylistStatsView()
            } else {
                self.detachPlaylistStatsView()
            }
        case 1:
            self.detachRecordingView(true)
        case 2:
            self.detachNotesView()
        case 3:
            self.detachHistoryView()
        default:
            break
        }
        
        self.selectedTabIdx = idx
        switch idx {
        case 0:
            self.labelTab1.font = UIFont.boldSystemFont(ofSize: 11)
            self.viewIndicatorTab1.isHidden = false
            if self.practiceItemId != nil {
                self.attachStatisticsView()
            } else if self.playlistItemId != nil {
                self.attachPlaylistStatsView()
            } else {
                self.attachPlaylistStatsView()
            }
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                self.attachPremiumLockView()
                self.premiumLockView.configureForPracticeStats()
                if self.constraintForContentTopSpace != nil {
                    self.constraintForContentTopSpace.constant = 160
                }
                if self.constraintForPremiumUnlockTopSpace != nil {
                    self.constraintForPremiumUnlockTopSpace.constant = 0
                }
            } else {
                if self.constraintForContentTopSpace != nil {
                    self.constraintForContentTopSpace.constant = 0
                }
                self.detachPremiumLockView()
            }
        case 1:
            self.labelTab2.font = UIFont.boldSystemFont(ofSize: 11)
            self.viewIndicatorTab2.isHidden = false
            self.attachRecordingView()
            
            self.detachPremiumLockView()
        case 2:
            self.labelTab3.font = UIFont.boldSystemFont(ofSize: 11)
            self.attatchNotesView()
            
            self.viewIndicatorTab3.isHidden = false
            self.detachPremiumLockView()
            
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                if self.currentNotesCount == 0 {
                    self.notesView.freeUserLock()
                } else {
                    self.notesView.lock()
                }
            } else {
                self.notesView.unlock()
            }
        case 3:
            self.labelTab4.font = UIFont.boldSystemFont(ofSize: 11)
            self.viewIndicatorTab4.isHidden = false
            self.attachHistoryView()
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                self.attachPremiumLockView()
                self.premiumLockView.configureForHistory()
                if self.constraintForContentTopSpace != nil {
                    self.constraintForContentTopSpace.constant = 160
                }
                if self.constraintForPremiumUnlockTopSpace != nil {
                    self.constraintForPremiumUnlockTopSpace.constant = 0
                }
            } else {
                if self.constraintForContentTopSpace != nil {
                    self.constraintForContentTopSpace.constant = 0
                }
                self.detachPremiumLockView()
            }
        default:
            return
        }
    }
    
}

extension DetailsViewController: NotesListViewDelegate, RecordingsListViewDelegate {
    
    @discardableResult
    func processNotes() -> Int { // return the size of notes
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                let notes = practiceItem.notes ?? []
                self.notesView.showNotes(notes)
                self.currentNotesCount = 0
                for note in notes {
                    if !note.archived {
                        self.currentNotesCount = self.currentNotesCount + 1
                    }
                }
                return notes.count
            }
            self.currentNotesCount = 0
            return 0
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                let notes = playlist.notes ?? []
                self.notesView.showNotes(playlist.notes ?? [])
                self.currentNotesCount = 0
                for note in notes {
                    if !note.archived {
                        self.currentNotesCount = self.currentNotesCount + 1
                    }
                }
                return notes.count
            }
            self.currentNotesCount = 0
            return 0
        } else {
            self.notesView.isGoal = true
            let notes = GoalsLocalManager.manager.loadGoals() ?? []
            self.notesView.showNotes(GoalsLocalManager.manager.loadGoals() ?? [])
            self.currentNotesCount = 0
            for note in notes {
                if !note.archived {
                    self.currentNotesCount = self.currentNotesCount + 1
                }
            }
            return notes.count
        }
    }
    
    func onAddNote(text: String) {
        
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                practiceItem.addNote(text: text)
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                playlist.addNote(text: text)
            }
        } else {
            let note = Note()
            note.id = UUID().uuidString
            note.note = text
            note.createdAt = "\(Date().timeIntervalSince1970)"
            GoalsLocalManager.manager.addGoal(note)
        }
        
        self.processNotes()
        
        if !PremiumDataManager.manager.isPremiumUnlocked() {
            if self.currentNotesCount == 0 {
                self.notesView.freeUserLock()
            } else if self.currentNotesCount == 1 {
                self.notesView.lock()
            }
        }
    }
    
    func onOpenNoteDetails(_ note: Note) {
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                let noteDetailsViewController = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNoteDetailsViewController") as! PracticeNoteDetailsViewController
                noteDetailsViewController.note = note
                noteDetailsViewController.practiceItem = practiceItem
                self.navigationController?.pushViewController(noteDetailsViewController, animated: true)
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                let noteDetailsViewController = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNoteDetailsViewController") as! PracticeNoteDetailsViewController
                noteDetailsViewController.note = note
                noteDetailsViewController.noteIsForPlaylist = true
                noteDetailsViewController.playlist = playlist
                self.navigationController?.pushViewController(noteDetailsViewController, animated: true)
            }
        } else {
            let noteDetailsViewController = UIStoryboard(name: "practice_note", bundle: nil).instantiateViewController(withIdentifier: "PracticeNoteDetailsViewController") as! PracticeNoteDetailsViewController
            noteDetailsViewController.note = note
            self.navigationController?.pushViewController(noteDetailsViewController, animated: true)
        }
    }
    
    func onDeleteNote(_ note: Note) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            
            if self.practiceItemId != nil {
                if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                    practiceItem.deleteNote(for: note.id)
                }
            } else if self.playlistItemId != nil {
                if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                    playlist.deleteNote(for: note.id)
                }
            } else {
                GoalsLocalManager.manager.removeGoal(for: note.id)
            }
            self.processNotes()
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                if self.currentNotesCount == 0 {
                    if self.notesView != nil {
                        self.notesView.freeUserLock()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onArchive(_ noteId: String) {
        ModacityAnalytics.LogStringEvent("Notes - Archived")
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                practiceItem.archiveNote(for: noteId)
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                playlist.archiveNote(for: noteId)
            }
        } else {
            GoalsLocalManager.manager.changeGoalArchivedStatus(for: noteId)
        }
        self.processNotes()
    }
    
    func onChangeTitle(for note: Note, to title: String) {
        if title != "" {
            if self.practiceItemId != nil {
                if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                    practiceItem.changeNoteTitle(for: note.id, to: title)
                }
            } else if self.playlistItemId != nil {
                if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                    playlist.changeNoteTitle(for: note.id, to: title)
                }
            } else {
                GoalsLocalManager.manager.changeGoalTitleAndSubTitle(goalId: note.id, title: title)
            }
            self.processNotes()
        }
    }
    
    func onShareRecording(text: String, url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension DetailsViewController: PremiumUpgradeLockViewDelegate {
    
    func attachPremiumLockView() {
        if self.premiumLockView == nil {
            self.premiumLockView = PremiumUpgradeLockView()
            self.view.addSubview(self.premiumLockView)
            self.premiumLockView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.premiumLockView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.premiumLockView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.constraintForPremiumUnlockTopSpace = self.premiumLockView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor)
            self.constraintForPremiumUnlockTopSpace.isActive = true
            self.view.bringSubview(toFront: self.premiumLockView)
            self.premiumLockView.delegate = self
        } else {
            self.view.bringSubview(toFront: self.premiumLockView)
        }
    }
    
    @objc func processPremiumStatusChanged() {
        if PremiumDataManager.manager.isPremiumUnlocked() {
            if self.premiumLockView != nil {
                self.premiumLockView.removeFromSuperview()
                self.premiumLockView = nil
            }
            
            if self.constraintForContentTopSpace != nil {
                self.constraintForContentTopSpace.constant = 0
            }
            if self.notesView != nil {
                self.notesView.unlock()
            }
        }
    }
    
    @objc func detachPremiumLockView() {
        if self.premiumLockView != nil && self.premiumLockView.superview != nil {
            self.premiumLockView.removeFromSuperview()
            self.premiumLockView = nil
        }
    }
    
    func onFindOutMore() {
        let controller = UIStoryboard(name: "premium", bundle: nil).instantiateViewController(withIdentifier: "PremiumUpgradeScene")
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension DetailsViewController: HistoryListViewDelegate, PlaylistHistoryListViewDelegate {
    
    func onAddOnHistoryListView(_ historyListView: HistoryListView) {
        self.performSegue(withIdentifier: "sid_add_practice_history", sender: nil)
    }
    
    func onEditPracticeData(_ data: PracticeDaily) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "UpdatePracticeEntryViewController") as! UpdatePracticeEntryViewController
        controller.isUpdating = true
        controller.editingPracticeData = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onDeletePracticeData(_ data: PracticeDaily) {
        let alertController = UIAlertController(title: nil, message: "Are you sure to delete this practice history?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            PracticingDailyLocalManager.manager.removeData(data)
            self.historyListView.showHistory(for: self.practiceItemId)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onAddOnPlaylistHistoryListView(_ historyListView: PlaylistHistoryView, playlistId: String?) {
        let controller = UIStoryboard(name: "details", bundle: nil).instantiateViewController(withIdentifier: "UpdatePracticeEntryViewController") as! UpdatePracticeEntryViewController
        controller.fromPlaylist = true
        controller.playlistItemId = playlistId
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onEditPlaylistPracticeData(_ data: PracticeDaily, playlistId: String?) {
        
    }
    
    func onDeletePlaylistPracticeData(_ data: PracticeDaily, playlistId: String?) {
        
    }
}
