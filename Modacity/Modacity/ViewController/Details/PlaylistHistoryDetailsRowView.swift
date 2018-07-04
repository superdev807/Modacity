//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
        
        self.labelPracticeItemName.text = ""
        if let practice = PracticeItemLocalManager.manager.practiceItem(forId: data.practiceItemId) {
            self.labelPracticeItemName.text = practice.name
        }
        let timeInSecond = data.time ?? 0
        if timeInSecond > 0 && timeInSecond < 60 {
            self.labelTime.text = String(format: "%.1f", Double(timeInSecond) / 60.0)
        } else {
            self.labelTime.text = "\(timeInSecond / 60)"
        }
        self.labelStarRating.text = formatter.string(from: data.calculateAverageRatings() as NSNumber) ?? "n/a"
        self.labelImprovements.text = "\(data.improvements.count)"
        
    }
}