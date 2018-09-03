//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Charts
import AVFoundation

class PlaylistHistoryDetailsRowView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var labelStarRating: UILabel!
    @IBOutlet weak var labelImprovements: UILabel!
    @IBOutlet weak var imageViewStarIcon: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var viewNormalEntry: UIView!
    @IBOutlet weak var labelManualEntry: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PlaylistHistoryDetailsRowView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func configure(with data: PlaylistPracticeHistoryData) {
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        
        if data.isManualPracticeEntry {
            self.labelManualEntry.isHidden = false
            self.viewNormalEntry.isHidden = true
            if data.practiceItemId.hasSuffix(":MANUAL") {
                if let practice = PracticeItemLocalManager.manager.practiceItem(forId: data.practiceItemId[0..<(data.practiceItemId.count - ":MANUAL".count)]) {
                    self.labelPracticeItemName.text = practice.name
                } else {
                    self.labelPracticeItemName.text = "(Deleted)"
                }
            } else if data.practiceItemId == PlaylistDailyLocalManager.manager.miscPracticeId {
                self.labelPracticeItemName.text = PlaylistDailyLocalManager.manager.miscPracticeItemName
            }
        } else {
            self.labelManualEntry.isHidden = true
            self.viewNormalEntry.isHidden = false
            self.labelPracticeItemName.text = ""
            if let practice = PracticeItemLocalManager.manager.practiceItem(forId: data.practiceItemId) {
                self.labelPracticeItemName.text = practice.name
            } else {
                self.labelPracticeItemName.text = "(Deleted)"
            }
            self.labelStarRating.text = formatter.string(from: data.calculateAverageRatings() as NSNumber) ?? "n/a"
            self.labelImprovements.text = "\(data.improvements.count)"
        }
        
        let timeInSecond = data.time ?? 0
        if timeInSecond > 0 && timeInSecond < 600 {
            self.labelTime.text = String(format: "%.1f", Double(timeInSecond) / 60.0)
        } else {
            self.labelTime.text = "\(timeInSecond / 60)"
        }
    }
}
