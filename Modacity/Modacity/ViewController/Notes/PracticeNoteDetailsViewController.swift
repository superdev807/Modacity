//
//  PracticeNoteDetailsViewController.swift
//  Modacity
//
//  Created by Benjamin Chris on 4/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import CHGInputAccessoryView

class PracticeNoteDetailsViewController: UIViewController {

    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var textViewInputBox: UITextView!
    @IBOutlet weak var constraintForInputboxBottomSpace: NSLayoutConstraint!
    
    var playlistViewModel: PlaylistContentsViewModel!
    var playlistPracticeEntry: PlaylistPracticeEntry!
    var playlist: Playlist!
    
    @IBOutlet weak var textViewNoteTitleEdit: UITextView!
    //    @IBOutlet weak var textfieldNoteTitleEdit: UITextField!
    
    var practiceItem : PracticeItem!
    
    var noteIsForPlaylist = false
    var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textViewInputBox.placeholder = "Add a note..."
        self.textViewInputBox.text = note.subTitle
        self.labelNoteTitle.text = note.note
        self.textViewNoteTitleEdit.text = note.note
        self.labelNoteTitle.isHidden = true
        self.textViewInputBox.becomeFirstResponder()
        self.textViewInputBox.placeholderColor = Color.white.alpha(0.7)
        self.textViewInputBox.tintColor = Color.white
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        self.textViewNoteTitleEdit.textContainerInset = .zero
        self.attachInputAccessoryView()
        self.processLabelAlignments()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onBack(_ sender:Any) {
        
        if self.playlistViewModel != nil {
            if self.noteIsForPlaylist {
                self.playlistViewModel.changeNoteTitle(noteId: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
                self.playlistViewModel.changeNoteSubTitle(noteId: self.note.id, subTitle: self.textViewInputBox.text)
            } else {
                self.playlistPracticeEntry.practiceItem()?.changeNoteTitle(for: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
                self.playlistPracticeEntry.practiceItem()?.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            }
        } else if self.practiceItem != nil {
            self.practiceItem.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            self.practiceItem.changeNoteTitle(for: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
        } else if self.playlist != nil {
            self.playlist.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            self.playlist.changeNoteTitle(for: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
        } else {
            GoalsLocalManager.manager.changeGoalTitleAndSubTitle(goalId: self.note.id, title: self.textViewNoteTitleEdit.text ?? "", subTitle: self.textViewInputBox.text)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onKeyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForInputboxBottomSpace.constant = -1 * keyboardSize.height
        }
    }
    
    @objc func onKeyboardWillChangeFrame(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraintForInputboxBottomSpace.constant = -1 * keyboardSize.height
        }
    }
    
    @objc func onKeyboardWillHide(notification: Notification) {
        self.constraintForInputboxBottomSpace.constant = 0
    }

    @IBAction func onDeleteNote(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.deletePlaylistNote(self.note)
                } else {
                    self.playlistViewModel.deleteNote(self.note, for: self.playlistPracticeEntry)
                }
            } else if self.practiceItem != nil {
                self.practiceItem.deleteNote(for: self.note.id)
            } else if self.playlist != nil {
                self.playlist.deleteNote(for: self.note.id)
            } else {
                GoalsLocalManager.manager.removeGoal(for:self.note.id)
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onStartEdit(_ sender: Any) {
        if self.textViewNoteTitleEdit.isHidden {
//            self.textViewNoteTitleEdit.isHidden = false
//            self.labelNoteTitle.isHidden = true
            self.textViewNoteTitleEdit.becomeFirstResponder()
        }
    }
    
    @IBAction func onDidEndOnExitOnField(_ sender: Any) {
        if "" != self.textViewNoteTitleEdit.text {
            self.labelNoteTitle.text = self.textViewNoteTitleEdit.text
            self.processLabelAlignments()
            if self.playlistViewModel != nil {
                if self.noteIsForPlaylist {
                    self.playlistViewModel.changeNoteTitle(noteId: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
                } else {
                    self.playlistPracticeEntry.practiceItem()?.changeNoteTitle(for: self.note.id, title: self.textViewNoteTitleEdit.text ?? "")
                }
            } else if self.practiceItem != nil {
                self.practiceItem.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            } else if self.playlist != nil {
                self.playlist.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            } else {
                GoalsLocalManager.manager.changeGoalTitleAndSubTitle(goalId: self.note.id, subTitle: self.textViewInputBox.text)
            }
//            self.textViewNoteTitleEdit.isHidden = true
//            self.labelNoteTitle.isHidden = false
        }
    }
}

extension PracticeNoteDetailsViewController: CHGInputAccessoryViewDelegate {
    
    func attachInputAccessoryView() {
        var inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        var flexible = CHGInputAccessoryViewItem.flexibleSpace()!
        let close = CHGInputAccessoryViewItem.button(withTitle: "Close")!
        close.tintColor = Color.black
        close.tag = 100
        inputAccessoryView.items = [flexible, close]
        inputAccessoryView.inputAccessoryViewDelegate = self
        self.textViewInputBox.inputAccessoryView = inputAccessoryView
        
        inputAccessoryView = CHGInputAccessoryView.inputAccessoryView() as! CHGInputAccessoryView
        flexible = CHGInputAccessoryViewItem.flexibleSpace()!
        let next = CHGInputAccessoryViewItem.button(withTitle: "Next")!
        next.tintColor = Color.black
        next.tag = 101
        inputAccessoryView.items = [flexible, next]
        inputAccessoryView.inputAccessoryViewDelegate = self
        self.textViewNoteTitleEdit.inputAccessoryView = inputAccessoryView
    }
    
    func didTap(_ item: CHGInputAccessoryViewItem!) {
        if item.tag == 100 {
            self.textViewInputBox.resignFirstResponder()
        } else if item.tag == 101 {
            self.onDidEndOnExitOnField(self)
            self.textViewInputBox.becomeFirstResponder()
        }
    }
    
    func processLabelAlignments() {
        let size = self.labelNoteTitle.text?.measureSize(for: self.labelNoteTitle.font, constraindTo: CGSize(width: UIScreen.main.bounds.size.width - 100, height: CGFloat.greatestFiniteMagnitude)).height ?? 24
        
        if size > CGFloat(24) {
            self.labelNoteTitle.textAlignment = .left
            self.textViewNoteTitleEdit.textAlignment = .left
        } else {
            self.labelNoteTitle.textAlignment = .center
            self.textViewNoteTitleEdit.textAlignment = .center
        }
    }
}

extension PracticeNoteDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.textViewNoteTitleEdit {
            self.labelNoteTitle.text = self.textViewNoteTitleEdit.text
            self.processLabelAlignments()
        }
    }
}
