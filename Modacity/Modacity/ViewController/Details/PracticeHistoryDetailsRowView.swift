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

class PracticeHistoryDetailsRowView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelStarRating: UILabel!
    @IBOutlet weak var labelImprovements: UILabel!
    @IBOutlet weak var imageViewStarIcon: UIImageView!
    @IBOutlet weak var imageViewImproveIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PracticeHistoryDetailsRowView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    func configure(title: String, time: Int, improvements:Int) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        self.imageViewStarIcon.image = UIImage(named: "icon_details_small_clock")
        self.labelTime.text = title
        if time > 0 && time < 60 {
            self.labelStarRating.text = String(format:"%.1f", Double(time) / 60.0)
        } else {
            self.labelStarRating.text = "\(time / 60)"
        }
        self.labelImprovements.text = "\(improvements)"
        
    }
    
    func configure(with data: PracticeDaily) {
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        self.imageViewStarIcon.image = UIImage(named: "icon_details_small_star")
        
        let from = data.fromTime!.date(format: "HH:mm:ss")?.toString(format: "h:mm a") ?? ""
        let to = Date(timeIntervalSince1970: data.startedTime).addingTimeInterval(Double(data.practiceTimeInSeconds)).toString(format: "h:mm a")
        self.labelTime.text = "\(from) - \(to)"
        self.labelStarRating.text = formatter.string(from: data.rating as NSNumber) ?? "n/a"
        self.labelImprovements.text = "\(data.improvements?.count ?? 0)"
        
    }
}
