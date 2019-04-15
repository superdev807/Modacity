//
//  OptionsPickerOptionCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/4/19.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

class OptionsPickerOptionCell: UITableViewCell {

    @IBOutlet weak var labelOption: UILabel!
    @IBOutlet weak var imageViewSelectTick: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(option: String, selected: Bool) {
        self.labelOption.text = option
        self.imageViewSelectTick.isHidden = !selected
    }
    
}
