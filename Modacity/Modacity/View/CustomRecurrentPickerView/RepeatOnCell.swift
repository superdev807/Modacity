//
//  RepeatOnCell.swift
//  Modacity
//
//  Created by Software Engineer on 4/12/19.
//  Copyright © 2019 Modacity, Inc. All rights reserved.
//

import UIKit

class RepeatOnCell: UICollectionViewCell {
    
    @IBOutlet weak var labelCaption: UILabel!
    @IBOutlet weak var viewBox: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(label: String, selected: Bool) {
        self.labelCaption.text = label
        
        self.viewBox.layer.cornerRadius = 16
        
        if selected {
            self.labelCaption.textColor = Color.white
            self.viewBox.layer.borderWidth = 0
            self.viewBox.backgroundColor = Color(hexString: "#5311ca")
        } else {
            self.viewBox.layer.borderColor = AppConfig.UI.AppColors.placeholderIconColorGray.cgColor
            self.viewBox.layer.borderWidth = 1
            self.labelCaption.textColor = Color.darkGray
            self.viewBox.backgroundColor = Color(hexString: "#dfdfdf")
        }
    }

}
