//
//  PracticeNotesViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 1/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class PracticeNotesViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var imageViewHeader: UIImageView!
    
    var playlistViewModel: PlaylistContentsViewModel!
    var practiceEntry: PlaylistPracticeEntry!
    var practiceItem: PracticeItem!
    var noteIsForPlaylist = false
    var noteToDeliver: Note!
    var noteListView:NotesListView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.noteListView = NotesListView()
        self.noteListView.delegate = self
        self.view.addSubview(self.noteListView)
        self.noteListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.noteListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.noteListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.noteListView.topAnchor.constraint(equalTo: self.imageViewHeader.bottomAnchor, constant: 10).isActive = true
        
        if self.playlistViewModel != nil {
            self.playlistViewModel.storePlaylist()
            if self.noteIsForPlaylist {
                self.labelTitle.text = self.playlistViewModel.playlistName
            } else {
                self.labelTitle.text = self.practiceEntry.practiceItem()?.name ?? ""
            }
        } else if self.practiceItem != nil {
            self.labelTitle.text = self.practiceItem.name ?? ""
        } else {
            self.labelTitle.text = "Goals"
            self.noteListView.isGoal = true
        }
        
        self.processNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_note_details" {
            let controller = segue.destination as! PracticeNoteDetailsViewController
            controller.playlistViewModel = self.playlistViewModel
            controller.playlistPracticeEntry = self.practiceEntry
            controller.noteIsForPlaylist = self.noteIsForPlaylist
            controller.note = self.noteToDeliver
            controller.practiceItem = self.practiceItem
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.playlistViewModel != nil {
            self.playlistViewModel.storePlaylist()
        }
        self.processNotes()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func processNotes() {
        
        var notes:[Note]?
        
        if self.playlistViewModel != nil {
            if self.noteIsForPlaylist {
                notes = self.playlistViewModel.playlist.notes
            } else {
                if self.playlistViewModel != nil {
                    notes = self.practiceEntry.practiceItem()?.notes
                }
            }
        } else if self.practiceItem != nil {
            notes = self.practiceItem.notes
        } else {
            notes = GoalsLocalManager.manager.loadGoals()
        }
        
        if let notes = notes {
            self.noteListView.showNotes(notes)
        }
    }
}

extension PracticeNotesViewController: NotesListViewDelegate {
    
    func onFindOutMore() {
        
    }
    
    func onAddNote(text: String) {
        if self.playlistViewModel != nil {
            if self.noteIsForPlaylist {
                self.playlistViewModel.addNoteToPlaylist(text)
            } else {
                self.playlistViewModel.addNote(to:self.practiceEntry, note:text)
            }
        } else if self.practiceItem != nil {
            self.practiceItem.addNote(text: text)
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
        self.noteToDeliver = note
        self.performSegue(withIdentifier: "sid_note_details", sender: nil)
    }
    
    func onDeleteNote(_ note: Note) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.deletePlaylistNote(note)
                } else {
                    self.playlistViewModel.deleteNote(note, for: self.practiceEntry)
                }
            } else if self.practiceItem != nil {
                self.practiceItem.deleteNote(for: note.id)
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
        if self.playlistViewModel != nil {
            if self.noteIsForPlaylist {
                self.playlistViewModel.changeArchiveStatusForPlaylistNote(noteId)
            } else {
                self.playlistViewModel.changeArchiveStatusForNote(noteId: noteId, for: self.practiceEntry)
            }
        } else if self.practiceItem != nil {
            self.practiceItem.archiveNote(for: noteId)
        } else {
            GoalsLocalManager.manager.changeGoalArchivedStatus(for: noteId)
        }
        self.processNotes()
    }
    
    func onChangeTitle(for note: Note, to title: String) {
        if title != "" {
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.changePlaylistNoteTitle(note: note, to: title)
                } else {
                    self.playlistViewModel.changeNoteTitle(entry: self.practiceEntry, note: note, to: title)
                }
            } else if self.practiceItem != nil {
                self.practiceItem.changeNoteTitle(for: note.id, to: title)
            } else {
                GoalsLocalManager.manager.changeGoalTitleAndSubTitle(goalId: note.id, title: title)
            }
        }
    }
    
}
