//
//  PracticeMusicQuoteCell.swift
//  Modacity
//
//  Created by BC Engineer on 2/5/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeMusicQuoteCell: UICollectionViewCell {

    @IBOutlet weak var labelNote: UILabel!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(note: String, name:String) {
        self.imageViewBackground.image = UIImage(named:"img_quote_box")?.stretchableImage(withLeftCapWidth: 45, topCapHeight: 20)
        self.labelNote.text = note
        self.labelName.text = "- \(name)"
    }

}
