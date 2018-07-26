//
//  DetailsViewController.swift
//  Modacity
//
//  Created by BC Engineer on 21/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
    
    var selectedTabIdx = -1
    
    var statisticsView:StatisticsView! = nil
    var recordingsView: RecordingsListView! = nil
    var notesView: NotesListView! = nil
    var historyListView: HistoryListView! = nil
    
    var playlistStatsView: PlaylistStatsView! = nil
    var playlistHistoryView: PlaylistHistoryView! = nil
    
    var premiumLockView: PremiumUpgradeLockView! = nil
    
    @IBOutlet weak var constraintForHeaderViewHeight: NSLayoutConstraint!
    
    var startTabIdx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.practiceItemId != nil {
            if let practiceItemData = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                self.labelTitle.text = practiceItemData.name
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                self.labelTitle.text = playlist.name
            }
        } else {
            self.labelTitle.text = "Overview"
            self.labelTab3.text = "GOALS"
        }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.practiceItemId == nil && self.playlistItemId == nil {
            self.buttonMenu.setImage(UIImage(named: "icon_menu"), for: .normal)
            
            if self.notesView != nil && self.selectedTabIdx == 2 {
                self.processNotes()
            }
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
        self.playlistStatsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
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
        self.statisticsView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
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
    
    func attatchNotesView(_ animated:Bool = false) {
        
        if self.notesView == nil {
            self.notesView = NotesListView()
            self.notesView.delegate = self
        }
        self.processNotes()
        self.view.addSubview(self.notesView)
        self.notesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.notesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.notesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.notesView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
        self.view.bringSubview(toFront: self.notesView)
        
        if self.practiceItemId == nil && self.playlistItemId == nil {
            self.notesView.textfieldAddNote.attributedPlaceholder = NSAttributedString(string: "Add a goal...", attributes: [.foregroundColor: Color.white.alpha(0.5)])
        }
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
            self.historyListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.historyListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.historyListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            self.historyListView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
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
            self.playlistHistoryView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
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
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                self.attachPremiumLockView()
                self.premiumLockView.configureForNote()
            }
        case 3:
            self.labelTab4.font = UIFont.boldSystemFont(ofSize: 11)
            self.viewIndicatorTab4.isHidden = false
            self.attachHistoryView()
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                self.attachPremiumLockView()
                self.premiumLockView.configureForPracticeStats()
            }
            if !PremiumDataManager.manager.isPremiumUnlocked() {
                self.attachPremiumLockView()
                self.premiumLockView.configureForHistory()
            }
        default:
            return
        }
    }
    
}

extension DetailsViewController: NotesListViewDelegate, RecordingsListViewDelegate {
    
    func processNotes() {
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                self.notesView.showNotes(practiceItem.notes ?? [])
            }
        } else if self.playlistItemId != nil {
            if let playlist = PlaylistLocalManager.manager.loadPlaylist(forId: self.playlistItemId) {
                self.notesView.showNotes(playlist.notes ?? [])
            }
        } else {
            self.notesView.isGoal = true
            self.notesView.showNotes(GoalsLocalManager.manager.loadGoals() ?? [])
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
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onArchive(_ noteId: String) {
        ModacityAnalytics.LogStringEvent("Notes - Archived \(noteId)")
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
            self.premiumLockView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
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
        }
    }
    
    @objc func detachPremiumLockView() {
        if self.premiumLockView != nil {
            self.premiumLockView.removeFromSuperview()
            self.premiumLockView = nil
        }
    }
    
    func onFindOutMore() {
        let controller = UIStoryboard(name: "premium", bundle: nil).instantiateViewController(withIdentifier: "PremiumUpgradeScene")
        self.present(controller, animated: true, completion: nil)
    }
    
}
