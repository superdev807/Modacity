//
//  PracticeNoteCell.swift
//  Modacity
//
//  Created by BC Engineer on 2/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PracticeNoteCellDelegate {
    func onNoteSwipeUp(note:Note, cell: PracticeNoteCell, indexPath: IndexPath)
}

class PracticeNoteCell: UICollectionViewCell {

    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var textViewNote: UITextView!
    
    var note: Note!
    var delegate: PracticeNoteCellDelegate!
    var indexPath: IndexPath!
    
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
    
    
}
