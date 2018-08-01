//
//  NoteCell.swift
//  Modacity
//
//  Created by BC Engineer on 23/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var constraintForCheckImageView: NSLayoutConstraint!
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
