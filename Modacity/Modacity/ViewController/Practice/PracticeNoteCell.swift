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
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    var note: Note!
    var delegate: PracticeNoteCellDelegate!
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(note: Note, indexPath: IndexPath) {
        self.note = note
        self.labelNote.text = note.note
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
