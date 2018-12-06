//
//  NoteCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 23/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol NoteCellDelegate {
    func onArchive(_ noteId:String)
    func onMenu(note: Note, buttonMenu: UIButton, cell: NoteCell)
    func onEditingEnd(cell: NoteCell, text: String)
    
    func openDetails(note: Note)
}

class NoteCell: UITableViewCell {
    
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var imageViewChecked: UIImageView!
    @IBOutlet weak var labelNoteCreated: UILabel!
    @IBOutlet weak var labelNoteSubTitle: UILabel!
    @IBOutlet weak var textfieldNoteTitle: UITextField!
    @IBOutlet weak var textViewNote: UITextView!
    @IBOutlet weak var textViewNoteSubTitle: UITextView!
    
    @IBOutlet weak var constraintForCheckImageView: NSLayoutConstraint!
    var delegate: NoteCellDelegate!
    var note: Note!
    var tapTerm: UITapGestureRecognizer!
    
    func configure(note: Note) {
        self.note = note
        if note.createdAt == nil {
            self.labelNoteCreated.text = ""
        } else {
            self.labelNoteCreated.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        }
        self.labelNoteSubTitle.text = note.subTitle
        self.labelNoteSubTitle.isHidden = true
        self.textViewNoteSubTitle.text = note.subTitle
        self.textViewNoteSubTitle.textContainer.lineFragmentPadding = 0
        self.textViewNoteSubTitle.textContainerInset = .zero
        self.textfieldNoteTitle.isHidden = true
        self.textViewNote.textContainer.lineFragmentPadding = 0
        self.textViewNote.textContainerInset = .zero
        self.textViewNote.isHidden = false
        
        if let recognizers = self.textViewNote.gestureRecognizers {
            
            for recognizer in recognizers {
                if recognizer is UITapGestureRecognizer {
                    self.textViewNote.removeGestureRecognizer(recognizer as UIGestureRecognizer)
                }
            }
        }
        
        self.tapTerm = UITapGestureRecognizer(target: self, action: #selector(tapTextView))
        
        self.tapTerm.delegate = self
        self.textViewNote.addGestureRecognizer(self.tapTerm)
        
        if note.archived {
            var attributedString = NSMutableAttributedString(string:note.note)
            if note.isDeliberatePracticeNote {
                attributedString = NSMutableAttributedString(attributedString: note.deliberatePracticeNoteProcess())
            } else {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)!], range: NSMakeRange(0, attributedString.length))
            }
            attributedString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.styleThick.rawValue), range: NSMakeRange(0, attributedString.length))
            attributedString.addAttribute(NSAttributedStringKey.strikethroughColor, value: Color.white, range: NSMakeRange(0, attributedString.length))
            self.labelNote.attributedText = attributedString
            self.textViewNote.attributedText = attributedString
            self.imageViewChecked.image = UIImage(named:"icon_checkmark_white_grayed")
            
        } else {
            
            var attributedString = NSMutableAttributedString(string:note.note)
            
            if note.isDeliberatePracticeNote {
                attributedString = NSMutableAttributedString(attributedString: note.deliberatePracticeNoteProcess())
            } else {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: Color.white, NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 14)!], range: NSMakeRange(0, attributedString.length))
            }
            self.labelNote.attributedText = attributedString
            self.textViewNote.attributedText = attributedString
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
        self.textViewNote.isHidden = true
        self.textfieldNoteTitle.isHidden = false
        self.textfieldNoteTitle.text = self.note.note
        self.textfieldNoteTitle.becomeFirstResponder()
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        self.delegate.onEditingEnd(cell: self, text: self.textfieldNoteTitle.text ?? "")
    }
    
    @objc func tapTextView(gesture: UITapGestureRecognizer) {
        if let textView = gesture.view as? UITextView {
            let tapLocation = gesture.location(in: textView)
            if let textPosition = textView.closestPosition(to: tapLocation) {
                if let attributes = textView.textStyling(at: textPosition, in: .forward) {
                    if let _ = attributes["NSLink"] {
                        ModacityDebugger.debug("Link clicked clicked")
                        return
                    } else {
                        ModacityDebugger.debug("Clicked outside of links.")
                        if delegate != nil {
                            delegate.openDetails(note: note)
                        }
                    }
                }
            }
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
