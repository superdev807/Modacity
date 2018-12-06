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
    @IBOutlet weak var viewImprovementHeader: UIView!
    @IBOutlet weak var constraintBodyTopSpace: NSLayoutConstraint!
    
    var note: Note!
    var delegate: PracticeNoteCellDelegate!
    var indexPath: IndexPath!
    var tapTerm: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(note: Note, indexPath: IndexPath) {
        self.note = note
        
        self.textViewNote.textContainer.lineFragmentPadding = 0
        self.textViewNote.textContainerInset = .zero
        if note.createdAt == nil {
            self.labelTime.text = ""
        } else {
            self.labelTime.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        }
        
        if note.isDeliberatePracticeNote {
            self.viewImprovementHeader.isHidden = false
            self.constraintBodyTopSpace.constant = 20
            self.imageViewBackground.image = UIImage(named:"bg_note_improvement_box")?.stretchableImage(withLeftCapWidth: 24, topCapHeight: 24)
            
            self.textViewNote.attributedText = note.deliberatePracticeNoteProcess()
        } else {
            self.textViewNote.attributedText = NSAttributedString(string: note.note,
                                                                  attributes: [NSAttributedStringKey.font: AppConfig.UI.Fonts.latoItalic(with: 14), NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.noteTextColorInPractice])
            self.viewImprovementHeader.isHidden = true
            self.constraintBodyTopSpace.constant = 10
            self.imageViewBackground.image = UIImage(named:"bg_note_box")?.stretchableImage(withLeftCapWidth: 24, topCapHeight: 24)
        }
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
                        ModacityDebugger.debug("Link clicked clicked")
                        return
                    } else {
                        ModacityDebugger.debug("Clicked outside of links.")
                        if self.delegate != nil {
                            if !(note.isDeliberatePracticeNote) {
                                self.delegate.openDetails(note: note)
                            }
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
