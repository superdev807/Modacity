//
//  PracticeNoteCell.swift
//  Modacity
//
//  Created by BC Engineer on 2/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeNoteCell: UICollectionViewCell {

    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(note: Note) {
        self.labelNote.text = note.note
        self.labelTime.text = Date(timeIntervalSince1970: Double(note.createdAt) ?? 0).toString(format: "MM/dd/yy")
        self.imageViewBackground.image = UIImage(named:"bg_note_box")?.stretchableImage(withLeftCapWidth: 24, topCapHeight: 24)
    }

}
