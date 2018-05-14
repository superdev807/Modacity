//
//  PracticeNoteDetailsViewController.swift
//  Modacity
//
//  Created by BC Engineer on 4/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class PracticeNoteDetailsViewController: UIViewController {

    @IBOutlet weak var labelNoteTitle: UILabel!
    @IBOutlet weak var textViewInputBox: UITextView!
    @IBOutlet weak var constraintForInputboxBottomSpace: NSLayoutConstraint!
    
    var playlistViewModel: PlaylistDetailsViewModel!
    var playlistPracticeEntry: PlaylistPracticeEntry!
    
    var practiceItem : PracticeItem!
    
    
    var noteIsForPlaylist = false
    var note: Note!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textViewInputBox.placeholder = "Add a note..."
        self.textViewInputBox.text = note.subTitle
        self.labelNoteTitle.text = note.note
        self.textViewInputBox.becomeFirstResponder()
        self.textViewInputBox.placeholderColor = Color.white.alpha(0.7)
        self.textViewInputBox.tintColor = Color.white
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
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
                self.playlistViewModel.changeNoteSubTitle(noteId: self.note.id, subTitle: self.textViewInputBox.text)
            } else {
                self.playlistPracticeEntry.practiceItem()?.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
            }
        } else {
            self.practiceItem.changeNoteSubTitle(for: self.note.id, subTitle: self.textViewInputBox.text)
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
            } else {
                self.practiceItem.deleteNote(for: self.note.id)
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
