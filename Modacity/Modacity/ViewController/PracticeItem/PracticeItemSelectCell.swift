//
//  PracticeItemSelectCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 9/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PracticeItemSelectCellDelegate {
    func onCellMenu(cell: PracticeItemSelectCell)
}

class PracticeItemSelectCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textfieldInputPracticeItemName: UITextField!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var labelLastPracticeTime: UILabel!
    
    var practiceItem: PracticeItem!
    var delegate: PracticeItemSelectCellDelegate? = nil
    
    var indexPath: IndexPath!
    
    func configure(with item: PracticeItem,
                   rate: Double,
                   keyword: String,
                   isSelected:Bool,
                   indexPath: IndexPath) {
        
        if keyword == "" {
            self.labelPracticeItemName.attributedText = nil
            self.labelPracticeItemName.text = item.name
        } else {
            let range = NSString(string:item.name.lowercased()).range(of: keyword.lowercased())
            let attributed = NSMutableAttributedString(string: item.name)
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: AppConfig.UI.AppColors.timerGreenColor], range: range)
            self.labelPracticeItemName.attributedText = attributed
        }
        
        if isSelected {
            self.imageViewIcon.image = UIImage(named:"icon_selected_gradient")
        } else {
            self.imageViewIcon.image = UIImage(named:"icon_plus")
        }
        
        self.textfieldInputPracticeItemName.text = item.name
        self.textfieldInputPracticeItemName.isHidden = true
        self.labelPracticeItemName.isHidden = false
        
        self.ratingView.contentMode = .scaleAspectFit
        if rate > 0 {
            self.ratingView.isHidden = false
            self.ratingView.rating = rate
        } else {
            self.ratingView.rating = 0
        }
        
        self.labelLastPracticeTime.text = item.lastPracticedTimeString()
        
        self.indexPath = indexPath
        
        self.practiceItem = item
    }
    
    @IBAction func onEditingChangedOnPracticeItemNameField(_ sender: Any) {
        self.labelPracticeItemName.text = self.textfieldInputPracticeItemName.text
    }
    
    @IBAction func onCellMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onCellMenu(cell: self)
        }
    }
    
    @IBAction func onDidEndOnExitOnPracticeItenNameField(_ sender: Any) {
        if self.textfieldInputPracticeItemName.text != "" {
            self.labelPracticeItemName.text = self.textfieldInputPracticeItemName.text
            self.practiceItem.name = self.textfieldInputPracticeItemName.text
            self.practiceItem.updateMe()
        }
        self.textfieldInputPracticeItemName.isHidden = true
        self.labelPracticeItemName.isHidden = false
    }
}
