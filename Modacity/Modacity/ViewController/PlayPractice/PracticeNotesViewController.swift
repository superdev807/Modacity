//
//  PracticeNotesViewController.swift
//  Modacity
//
//  Created by BC Engineer on 1/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate {
    func onToggleArchivedStatus()
}

class ButtonCell: UITableViewCell {
    
    @IBOutlet weak var labelStatus: UILabel!
    var delegate: ButtonCellDelegate!
    
    @IBAction func onArchive(_ sender: Any) {
        delegate.onToggleArchivedStatus()
    }
    
}

protocol NoteCellDelegate {
    func onArchive(_ noteId:String)
    func onMenu(note: Note, buttonMenu: UIButton, cell: NoteCell)
    func onEditingEnd(cell: NoteCell, text: String)
}

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var imageViewChecked: UIImageView!
    @IBOutlet weak var labelNoteCreated: UILabel!
    @IBOutlet weak var labelNoteSubTitle: UILabel!
    @IBOutlet weak var textfieldNoteTitle: UITextField!
    
    var delegate: NoteCellDelegate!
    var note: Note!
    
    func configure(note: Note) {
        self.note = note
        self.labelNoteCreated.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        self.labelNoteSubTitle.text = note.subTitle
        self.textfieldNoteTitle.isHidden = true
        self.labelNote.isHidden = false
        if note.archived {
            let attributedString = NSMutableAttributedString(string:note.note)
            attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.styleThick.rawValue), range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSAttributedStringKey.strikethroughColor, value: Color.white, range: NSMakeRange(0, attributedString.length))
            self.labelNote.attributedText = attributedString
            self.imageViewChecked.image = UIImage(named:"icon_checkmark_white_grayed")
        } else {
            self.labelNote.attributedText = NSAttributedString(string: note.note)
            self.imageViewChecked.image = UIImage(named:"icon_checkmark_blue_deselected")
        }
    }
    
    @IBAction func onArchive(_ sender: Any) {
        self.delegate.onArchive(self.note.id)
    }
    
    @IBAction func onMenu(_ sender: UIButton) {
        self.delegate.onMenu(note: self.note, buttonMenu: sender, cell: self)
    }
    
    func enableTitleEditing() {
        self.labelNote.isHidden = true
        self.textfieldNoteTitle.isHidden = false
        self.textfieldNoteTitle.text = self.note.note
        self.textfieldNoteTitle.becomeFirstResponder()
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.delegate.onEditingEnd(cell: self, text: self.textfieldNoteTitle.text ?? "")
    }
}

class PracticeNotesViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewAddNoteContainer: UIView!
    @IBOutlet weak var textfieldAddNote: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!

    var playlistViewModel: PlaylistDetailsViewModel!
    var practiceEntry: PlaylistPracticeEntry!
    var practiceItem: PracticeItem!
    var noteIsForPlaylist = false
    var notes = [Note]()
    var archivedNotes = [Note]()
    var showArchived = false
    var noteToDeliver: Note!
    
    var noteEditingCell: NoteCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.playlistViewModel != nil {
            self.playlistViewModel.storePlaylist()
            if self.noteIsForPlaylist {
                self.labelTitle.text = self.playlistViewModel.playlistName
            } else {
                self.labelTitle.text = self.practiceEntry.practiceItem()?.name ?? ""//self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
            }
        } else {
            self.labelTitle.text = self.practiceItem.name ?? ""
        }
        
        self.viewAddNoteContainer.layer.cornerRadius = 10
        self.textfieldAddNote.attributedPlaceholder = NSAttributedString(string: "Type to add a note...", attributes: [.foregroundColor: Color.white.alpha(0.5)])
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
        self.tableViewMain.reloadData()
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddNote(_ sender: Any) {
        
        self.textfieldAddNote.resignFirstResponder()
        if self.textfieldAddNote.text != "" {
            ModacityAnalytics.LogStringEvent("Notes - Added Note", extraParamName: "Note", extraParamValue: self.textfieldAddNote.text!)
            
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.addNoteToPlaylist(self.textfieldAddNote.text!)
                } else {
                    self.playlistViewModel.addNote(to:self.practiceEntry, note:self.textfieldAddNote.text!)
                }
            } else {
                self.practiceItem.addNote(text: self.textfieldAddNote.text!)
            }
            self.textfieldAddNote.text = ""
            self.processNotes()
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
        } else {
            notes = self.practiceItem.notes
        }
        
        if let notes = notes {
            self.notes = [Note]()
            self.archivedNotes = [Note]()
            
            for note in notes {
                if note.archived {
                    self.archivedNotes.append(note)
                } else {
                    self.notes.append(note)
                }
            }
            
            self.tableViewMain.reloadData()
        }
    }
}

extension PracticeNotesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.archivedNotes.count == 0 {
            return self.notes.count
        } else {
            return self.notes.count + 1 + (self.showArchived ? self.archivedNotes.count : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.notes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
            cell.configure(note: self.notes[indexPath.row])
            cell.delegate = self
            return cell
        } else if indexPath.row == self.notes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            if self.showArchived {
                cell.labelStatus.text = "HIDE ARCHIVED NOTES"
            } else {
                cell.labelStatus.text = "SHOW ARCHIVED NOTES"
            }
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
            cell.configure(note: self.archivedNotes[indexPath.row - self.notes.count - 1])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < self.notes.count {
            self.noteToDeliver = self.notes[indexPath.row]
        } else if indexPath.row > self.notes.count {
            self.noteToDeliver = self.archivedNotes[indexPath.row - self.notes.count - 1]
        }
        self.performSegue(withIdentifier: "sid_note_details", sender: nil)
    }
}

extension PracticeNotesViewController: NoteCellDelegate, ButtonCellDelegate {
    func onArchive(_ noteId: String) {
        ModacityAnalytics.LogStringEvent("Notes - Toggled Archived Status")
        if self.playlistViewModel != nil {
            if self.noteIsForPlaylist {
                self.playlistViewModel.changeArchiveStatusForPlaylistNote(noteId)
            } else {
                self.playlistViewModel.changeArchiveStatusForNote(noteId: noteId, for: self.practiceEntry)//changeArchiveStatusForNote(noteId)
            }
        } else {
            self.practiceItem.archiveNote(for: noteId)
        }
        self.processNotes()
        self.tableViewMain.reloadData()
    }
    
    func onToggleArchivedStatus() {
        ModacityAnalytics.LogStringEvent("Notes - Toggled Archived View")
        self.showArchived = !self.showArchived
        self.processNotes()
        self.tableViewMain.reloadData()
    }
    
    func onMenu(note: Note, buttonMenu: UIButton, cell:NoteCell) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_pen_white", "text": "Edit"],
                                              ["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                        
                                                if row == 1 {
                                                    
                                                    let alert = UIAlertController(title: nil, message: "Are you sure to delete this note?", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                                                        if self.playlistViewModel != nil {
                                                            if self.noteIsForPlaylist {
                                                                self.playlistViewModel.deletePlaylistNote(note)
                                                            } else {
                                                                self.playlistViewModel.deleteNote(note, for: self.practiceEntry)//deleteNote(note)
                                                            }
                                                        } else {
                                                            self.practiceItem.deleteNote(for: note.id)
                                                        }
                                                        self.processNotes()
                                                        self.tableViewMain.reloadData()
                                                    }))
                                                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                                                    self.present(alert, animated: true, completion: nil)
                                                    
                                                } else if row == 1 {
                                                    
                                                    if self.noteEditingCell != nil {
                                                        
                                                    }
                                                    
                                                    self.noteEditingCell = cell
                                                    cell.enableTitleEditing()
                                                    
                                                }
                                                
                                        }
    }
    
    func onEditingEnd(cell: NoteCell, text: String) {
        if text != "" {
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.changePlaylistNoteTitle(note: cell.note, to: text)
                } else {
                    self.playlistViewModel.changeNoteTitle(entry: self.practiceEntry, note: cell.note, to: text)
                }
            } else {
                self.practiceItem.changeNoteTitle(for: cell.note.id, to: text)
            }
        }
        
        cell.textfieldNoteTitle.isHidden = true
        cell.labelNote.isHidden = false
        self.processNotes()
        self.tableViewMain.reloadData()
        self.noteEditingCell = nil
    }
}
