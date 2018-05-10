//
//  PracticeNoteCell.swift
//  Modacity
//
//  Created by BC Engineer on 2/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PracticeNoteCellDelegate {
    func onNoteSwipeUp(_ note:Note)
}

class PracticeNoteCell: UICollectionViewCell {

    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    var note: Note!
    var delegate: PracticeNoteCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(note: Note) {
        self.note = note
        self.labelNote.text = note.note
        self.labelTime.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        self.imageViewBackground.image = UIImage(named:"bg_note_box")?.stretchableImage(withLeftCapWidth: 24, topCapHeight: 24)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
    }
    
    @objc func handleGesture() {
        self.delegate.onNoteSwipeUp(self.note)
    }
    

}
