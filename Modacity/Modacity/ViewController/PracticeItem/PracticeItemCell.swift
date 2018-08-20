//
//  PracticeItemCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 9/8/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PracticeItemCellDelegate {
    func onCellMenu(cell: PracticeItemCell)
}

class PracticeItemCell: UITableViewCell {
    
    @IBOutlet weak var labelPracticeName: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var buttonMenu: UIButton!
    @IBOutlet weak var buttonHeart: UIButton!
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var textfieldNameEdit: UITextField!
    
    @IBOutlet weak var labelPracticeItemLastPracticed: UILabel!
    var delegate: PracticeItemCellDelegate? = nil
    var practiceItem: PracticeItem!
    
    func configure(with practiceItem: PracticeItem, keyword: String) {
        if keyword == "" {
            self.labelPracticeName.attributedText = nil
            self.labelPracticeName.text = practiceItem.name
        } else {
            let range = NSString(string:practiceItem.name.lowercased()).range(of: keyword.lowercased())
            let attributed = NSMutableAttributedString(string: practiceItem.name)
            attributed.addAttributes([NSAttributedStringKey.foregroundColor: AppConfig.appConfigTimerGreenColor], range: range)
            self.labelPracticeName.attributedText = attributed
        }
        
        self.ratingView.rating = PracticeItemLocalManager.manager.ratingValue(for: practiceItem.id) ?? 0
        self.labelPracticeItemLastPracticed.text = practiceItem.lastPracticedTimeString()
        self.practiceItem = practiceItem
        self.textfieldNameEdit.isHidden = true
        self.labelPracticeName.isHidden = false
        self.changeHeartIconImage()
    }
    
    @IBAction func onCellMenu(_ sender: Any) {
        if self.delegate != nil {
            self.delegate!.onCellMenu(cell: self)
        }
    }
    
    func changeHeartIconImage() {
        if !PracticeItemLocalManager.manager.isFavoritePracticeItem(for: self.practiceItem.id) {
            self.buttonHeart.setImage(UIImage(named:"icon_heart"), for: .normal)
            self.buttonHeart.alpha = 0.3
        } else {
            self.buttonHeart.setImage(UIImage(named:"icon_heart_red"), for: .normal)
            self.buttonHeart.alpha = 1
        }
    }
    
    @IBAction func onEditingDidEnd(_ sender: Any) {
        if self.textfieldNameEdit.text != "" {
            self.labelPracticeName.text = self.textfieldNameEdit.text
            self.practiceItem.name = self.textfieldNameEdit.text
            self.practiceItem.updateMe()
        }
        self.textfieldNameEdit.isHidden = true
        self.labelPracticeName.isHidden = false
    }
    
    @IBAction func onHeart(_ sender:Any) {
        PracticeItemLocalManager.manager.setFavoritePracticeItem(forItemId: self.practiceItem.id)
        self.changeHeartIconImage()
    }
}

class PracticeItemHeaderCell: UITableViewCell {
    
    @IBOutlet weak var viewStoreNewItemPanel: UIView!
    @IBOutlet weak var labelStoreNewItem: UILabel!
    
    func configure(with keyword:String) {
        self.viewStoreNewItemPanel.layer.cornerRadius = 25
        self.labelStoreNewItem.text = keyword
    }
    
}
