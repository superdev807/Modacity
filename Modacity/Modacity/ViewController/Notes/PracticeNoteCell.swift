//
//  PracticeNoteCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 2/5/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PracticeNoteCellDelegate {
    func onNoteSwipeUp(note:Note, cell: PracticeNoteCell, indexPath: IndexPath)
    func openDetails(note: Note)
}

class PracticeNoteCell: UICollectionViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var textViewNote: UITextView!
    
    var note: Note!
    var delegate: PracticeNoteCellDelegate!
    var indexPath: IndexPath!
    var tapTerm: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(note: Note, indexPath: IndexPath) {
        self.note = note
        self.textViewNote.text = note.note
        self.textViewNote.textContainer.lineFragmentPadding = 0
        self.textViewNote.textContainerInset = .zero
        self.textViewNote.setContentOffset(.zero, animated: false)
        self.labelTime.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        self.imageViewBackground.image = UIImage(named:"bg_note_box")?.stretchableImage(withLeftCapWidth: 24, topCapHeight: 24)
        self.indexPath = indexPath
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
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
    }
    
    @objc func handleGesture() {
        self.delegate.onNoteSwipeUp(note:self.note, cell:self, indexPath: self.indexPath)
    }
    
    func startStraitUpAnimate(completed: @escaping ()->()) {
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y = self.frame.origin.y - self.frame.size.height
            self.alpha = 0
        }) { (finished) in
            if finished {
                completed()
            }
        }
    }
    
    @objc func tapTextView(gesture: UITapGestureRecognizer) {
        if let textView = gesture.view as? UITextView {
            let tapLocation = gesture.location(in: textView)
            if let textPosition = textView.closestPosition(to: tapLocation) {
                if let attributes = textView.textStyling(at: textPosition, in: .forward) {
                    if let _ = attributes["NSLink"] {
                        print("Link clicked clicked")
                        return
                    } else {
                        print("Clicked outside of links.")
                        if self.delegate != nil {
                            self.delegate.openDetails(note: note)
                        }
                    }
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
