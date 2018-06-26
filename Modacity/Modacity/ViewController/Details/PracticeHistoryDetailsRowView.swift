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

class PracticeHistoryDetailsRowView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelStarRating: UILabel!
    @IBOutlet weak var labelImprovements: UILabel!
    
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
    
    func configure(with data: PracticeDaily) {
        let to = Date(timeIntervalSince1970: data.startedTime).addingTimeInterval(Double(data.practiceTimeInSeconds)).toString(format: "HH:mm")
        self.labelTime.text = "\(data.fromTime) - \(to)"
        self.labelStarRating.text = "\(data.rating)"
        self.labelImprovements.text = "\(data.improvements?.count ?? 0)"
    }
}
