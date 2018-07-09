//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import Charts
import AVFoundation

protocol NotesListViewDelegate {
    func onOpenNoteDetails(_ note: Note)
    func onArchive(_ noteId: String)
    func onDeleteNote(_ note: Note)
    func onChangeTitle(for note: Note, to title: String)
    func onAddNote(text: String)
}

class NotesListView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var viewAddNoteContainer: UIView!
    @IBOutlet weak var textfieldAddNote: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var totalNotes = [Note]()
    
    var notes = [Note]()
    var archivedNotes = [Note]()
    var showArchived = false

    var delegate: NotesListViewDelegate!
    
    var noteEditingCell: NoteCell!
    
    var isGoal = false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("NotesListView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewMain.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        self.tableViewMain.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
        self.viewAddNoteContainer.layer.cornerRadius = 10
        self.textfieldAddNote.attributedPlaceholder = NSAttributedString(string: "Type to add a note...", attributes: [.foregroundColor: Color.white.alpha(0.5)])
    }
    
    func showNotes(_ notes: [Note]) {
        self.totalNotes = notes
        self.processNotes()
    }
    
    @IBAction func onAddNote(_ sender: Any) {
        
        self.textfieldAddNote.resignFirstResponder()
        if self.textfieldAddNote.text != "" {
            ModacityAnalytics.LogStringEvent("Notes - Added Note", extraParamName: "Note", extraParamValue: self.textfieldAddNote.text!)
            
            self.delegate.onAddNote(text: self.textfieldAddNote.text!)
            self.textfieldAddNote.text = ""
        }
        else {
            // user tapped on plus button before they typed anything. direct to type.
            ModacityAnalytics.LogStringEvent("Notes - Tapped Plus Button No Text")
            self.textfieldAddNote.becomeFirstResponder()
        }
    }
    
    @IBAction func onEditingDidBeginForAddNote(_ sender: Any) {
        if self.noteEditingCell != nil {
            self.tableViewMain.reloadData()
        }
    }
}

extension NotesListView : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.archivedNotes.count == 0 {
            return self.notes.count
        } else {
            return self.notes.count + 1 + (self.showArchived ? self.archivedNotes.count : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.notes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
            cell.configure(note: self.notes[indexPath.row])
            cell.delegate = self
            return cell
        } else if indexPath.row == self.notes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            if self.showArchived {
                cell.labelStatus.text = self.isGoal ? "HIDE ARCHIVED GOALS" : "HIDE ARCHIVED NOTES"
            } else {
                cell.labelStatus.text = self.isGoal ? "SHOW ARCHIVED GOALS" : "SHOW ARCHIVED NOTES"
            }
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
            cell.configure(note: self.archivedNotes[indexPath.row - self.notes.count - 1])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < self.notes.count {
            self.delegate.onOpenNoteDetails(self.notes[indexPath.row])
        } else if indexPath.row > self.notes.count {
            self.delegate.onOpenNoteDetails(self.archivedNotes[indexPath.row - self.notes.count - 1])
        }
    }
}

extension NotesListView: ButtonCellDelegate {
    func onToggleArchivedStatus() {
        ModacityAnalytics.LogStringEvent("Notes - Toggled Archived View")
        self.showArchived = !self.showArchived
        self.processNotes()
        self.tableViewMain.reloadData()
    }
}

extension NotesListView {
    
    func processNotes() {
        self.notes = [Note]()
        self.archivedNotes = [Note]()
        
        for note in self.totalNotes {
            if note.archived {
                self.archivedNotes.append(note)
            } else {
                self.notes.append(note)
            }
        }
        
        self.tableViewMain.reloadData()
    }
}

extension NotesListView: NoteCellDelegate {

    func onArchive(_ noteId: String) {
        self.delegate.onArchive(noteId)
    }

    func onMenu(note: Note, buttonMenu: UIButton, cell:NoteCell) {
        
        DropdownMenuView.instance.show(in: self.viewContent,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_pen_white", "text": "Edit"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in

                                                if row == 1 {
                                                    self.delegate.onDeleteNote(note)
                                                } else if row == 0 {

                                                    if self.noteEditingCell != nil {
                                                    }

                                                    self.noteEditingCell = cell
                                                    cell.enableTitleEditing()
                                                }

        }
    }

    func onEditingEnd(cell: NoteCell, text: String) {
        self.delegate.onChangeTitle(for: cell.note, to: text)
        cell.textfieldNoteTitle.isHidden = true
        cell.labelNote.isHidden = false
        self.tableViewMain.reloadData()
        self.noteEditingCell = nil
    }
}

