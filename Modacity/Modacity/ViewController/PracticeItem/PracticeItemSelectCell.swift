//
//  PracticeItemSelectCell.swift
//  Modacity
//
//  Created by BC Engineer on 9/8/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol PracticeItemSelectCellDelegate {
    func onCellMenu(menuButton: UIButton, indexPath: IndexPath)
}

class PracticeItemSelectCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textfieldInputPracticeItemName: UITextField!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var labelLastPracticeTime: UILabel!
    
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
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: AppConfig.appConfigTimerGreenColor], range: range)
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
    }
    
    @IBAction func onEditingChangedOnPracticeItemNameField(_ sender: Any) {
        self.labelPracticeItemName.text = self.textfieldInputPracticeItemName.text
    }
    
    @IBAction func onCellMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onCellMenu(menuButton: self.buttonMenu, indexPath: self.indexPath)
        }
    }
    
}
