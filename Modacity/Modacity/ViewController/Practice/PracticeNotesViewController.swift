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
    func onMenu(note: Note, buttonMenu: UIButton)
}

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var imageViewChecked: UIImageView!
    @IBOutlet weak var labelNoteCreated: UILabel!
    
    var delegate: NoteCellDelegate!
    var note: Note!
    
    func configure(note: Note) {
        self.note = note
        self.labelNoteCreated.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
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
        self.delegate.onMenu(note: self.note, buttonMenu: sender)
    }
}

class PracticeNotesViewController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    var playlistViewModel: PlaylistDetailsViewModel!
    var practiceItem: PracticeItem!
    
    @IBOutlet weak var viewAddNoteContainer: UIView!
    @IBOutlet weak var textfieldAddNote: UITextField!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var notes = [Note]()
    var archivedNotes = [Note]()
    var showArchived = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.playlistViewModel != nil {
            self.playlistViewModel.storePlaylist()
            self.labelTitle.text = self.playlistViewModel.currentPracticeEntry.practiceItem()?.name ?? ""
        } else {
            self.labelTitle.text = self.practiceItem.name ?? ""
        }
        
        self.viewAddNoteContainer.layer.cornerRadius = 10
        self.textfieldAddNote.attributedPlaceholder = NSAttributedString(string: "Add a note...", attributes: [.foregroundColor: Color.white.alpha(0.5)])
        self.processNotes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddNote(_ sender: Any) {
        
        self.textfieldAddNote.resignFirstResponder()
        if self.textfieldAddNote.text != "" {
            self.playlistViewModel.addNoteToCurrent(self.textfieldAddNote.text!)
            self.textfieldAddNote.text = ""
            self.processNotes()
        }
    }
    
    func processNotes() {
        if let notes = self.playlistViewModel.currentPracticeEntry.notes {
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
}

extension PracticeNotesViewController: NoteCellDelegate, ButtonCellDelegate {
    func onArchive(_ noteId: String) {
        self.playlistViewModel.changeArchiveStatusForNote(noteId)
        self.processNotes()
        self.tableViewMain.reloadData()
    }
    
    func onToggleArchivedStatus() {
        self.showArchived = !self.showArchived
        self.processNotes()
        self.tableViewMain.reloadData()
    }
    
    func onMenu(note: Note, buttonMenu: UIButton) {
        DropdownMenuView.instance.show(in: self.view,
                                       on: buttonMenu,
                                       rows: [["icon":"icon_row_delete", "text":"Delete"]]) { (row) in
                                            self.playlistViewModel.deleteNote(note)
                                            self.processNotes()
                                            self.tableViewMain.reloadData()
                                        }
    }
}
