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
    
    var selectedTabIdx = -1
    
    var statisticsView:StatisticsView! = nil
    var recordingsView: RecordingsListView! = nil
    var notesView: NotesListView! = nil
    var historyListView: HistoryListView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectTab(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension DetailsViewController {
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
        
        self.recordingsView.showRecordings(RecordingsLocalManager.manager.loadRecordings(forPracticeId: self.practiceItemId))
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
        
    }
    
    func detachNotesView(_ animated:Bool = false) {
        self.notesView.removeFromSuperview()
    }
    
    func attachHistoryView(_ animated:Bool = false) {
        
        if self.historyListView == nil {
            self.historyListView = HistoryListView()
        }
        self.view.addSubview(self.historyListView)
        self.historyListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.historyListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.historyListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.historyListView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor).isActive = true
        self.view.bringSubview(toFront: self.historyListView)
        self.historyListView.showHistory(for: self.practiceItemId)
    }
    
    func detachHistoryView(_ animated:Bool = false) {
        self.historyListView.removeFromSuperview()
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
    
    func selectTab(_ idx: Int) {
        if idx == self.selectedTabIdx {
            return
        }
        
        let currentTabIdx = self.selectedTabIdx
        
        self.viewIndicatorTab1.isHidden = true
        self.viewIndicatorTab2.isHidden = true
        self.viewIndicatorTab3.isHidden = true
        self.viewIndicatorTab4.isHidden = true
        
        switch currentTabIdx {
        case 0:
            self.detachStatisticsView(true)
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
            self.viewIndicatorTab1.isHidden = false
            self.attachStatisticsView()
        case 1:
            self.viewIndicatorTab2.isHidden = false
            self.attachRecordingView()
        case 2:
            self.attatchNotesView()
            self.viewIndicatorTab3.isHidden = false
        case 3:
            self.viewIndicatorTab4.isHidden = false
            self.attachHistoryView()
        default:
            return
        }
    }
    
}

extension DetailsViewController: NotesListViewDelegate {
    
    func processNotes() {
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                self.notesView.showNotes(practiceItem.notes ?? [])
            }
        } else {
            
        }
    }
    
    func onAddNote(text: String) {
        
        if self.practiceItemId != nil {
            if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                practiceItem.addNote(text: text)
            }
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
        }
    }
    
    func onDeleteNote(_ note: Note) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            
            if self.practiceItemId != nil {
                if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                    practiceItem.deleteNote(for: note.id)
                }
            }
//            if self.playlistViewModel != nil {
//                if self.noteIsForPlaylist {
//                    self.playlistViewModel.deletePlaylistNote(note)
//                } else {
//                    self.playlistViewModel.deleteNote(note, for: self.practiceEntry)
//                }
//            } else {
//                self.practiceItem.deleteNote(for: note.id)
//            }
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
        }
//        if self.playlistViewModel != nil {
//            if self.noteIsForPlaylist {
//                self.playlistViewModel.changeArchiveStatusForPlaylistNote(noteId)
//            } else {
//                self.playlistViewModel.changeArchiveStatusForNote(noteId: noteId, for: self.practiceEntry)
//            }
//        } else {
//            self.practiceItem.archiveNote(for: noteId)
//        }
        self.processNotes()
    }
    
    func onChangeTitle(for note: Note, to title: String) {
        if title != "" {
//            if self.playlistViewModel != nil {
//                if self.noteIsForPlaylist {
//                    self.playlistViewModel.changePlaylistNoteTitle(note: note, to: title)
//                } else {
//                    self.playlistViewModel.changeNoteTitle(entry: self.practiceEntry, note: note, to: title)
//                }
//            } else {
//                self.practiceItem.changeNoteTitle(for: note.id, to: title)
//            }
            
            if self.practiceItemId != nil {
                if let practiceItem = PracticeItemLocalManager.manager.practiceItem(forId: self.practiceItemId) {
                    practiceItem.changeNoteTitle(for: note.id, to: title)
                }
            }
        }
    }
    
}

