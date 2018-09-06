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

protocol PlaylistHistoryDetailsRowViewDelegate {
    func playlistHistoryDetailsRow(_ view: PlaylistHistoryDetailsRowView, editOnItem: PracticeDaily)
    func playlistHistoryDetailsRow(_ view: PlaylistHistoryDetailsRowView, deleteOnItem: PracticeDaily)
}

class PlaylistHistoryDetailsRowView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var labelPracticeItemName: UILabel!
    @IBOutlet weak var labelStarRating: UILabel!
    @IBOutlet weak var labelImprovements: UILabel!
    @IBOutlet weak var imageViewStarIcon: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var viewNormalEntry: UIView!
    @IBOutlet weak var labelManualEntry: UILabel!
    @IBOutlet weak var viewActions: UIView!
    
    var rowData: PracticeDaily? = nil
    var delegate: PlaylistHistoryDetailsRowViewDelegate? = nil
    
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
    
    func configure(with data: PracticeDaily, editing: Bool) {
        
        self.rowData = data
        
        let timeInSecond = data.practiceTimeInSeconds ?? 0
        if timeInSecond > 0 && timeInSecond < 600 {
            self.labelTime.text = String(format: "%.1f", Double(timeInSecond) / 60.0)
        } else {
            self.labelTime.text = "\(timeInSecond / 60)"
        }
        
        self.labelPracticeItemName.text = ""
        if data.isManual {
            if data.practiceItemId == PlaylistDailyLocalManager.manager.miscPracticeId {
                self.labelPracticeItemName.text = PlaylistDailyLocalManager.manager.miscPracticeItemName
            } else {
                if let practice = PracticeItemLocalManager.manager.practiceItem(forId: data.practiceItemId) {
                    self.labelPracticeItemName.text = practice.name
                } else {
                    self.labelPracticeItemName.text = "(Deleted)"
                }
            }
        } else {
            self.labelPracticeItemName.text = ""
            if let practice = PracticeItemLocalManager.manager.practiceItem(forId: data.practiceItemId) {
                self.labelPracticeItemName.text = practice.name
            } else {
                self.labelPracticeItemName.text = "(Deleted)"
            }
        }
        
        if editing {
            self.viewActions.isHidden = false
            self.viewNormalEntry.isHidden = true
            self.labelManualEntry.isHidden = true
            return
        } else {
            self.viewActions.isHidden = true
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        if data.isManual {
            self.labelManualEntry.isHidden = false
            self.viewNormalEntry.isHidden = true
        } else {
            self.labelManualEntry.isHidden = true
            self.viewNormalEntry.isHidden = false
            self.labelStarRating.text = formatter.string(from: (data.rating ?? 0) as NSNumber) ?? "n/a"
            self.labelImprovements.text = "\(data.improvements?.count ?? 0)"
        }
        
    }
    
    @IBAction func onEdit(_ sender: Any) {
        if let delegate = self.delegate {
            
            if let practiceItem = self.rowData?.practiceItem() {
                ModacityAnalytics.LogEvent(.PressedEditItemTime, params: ["Item Name": practiceItem.name])
            } else {
                ModacityAnalytics.LogEvent(.PressedEditItemTime)
            }
            
            delegate.playlistHistoryDetailsRow(self, editOnItem: self.rowData!)
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        if let delegate = self.delegate {
            if let practiceItem = self.rowData?.practiceItem() {
                ModacityAnalytics.LogEvent(.PressedDeleteItemTime, params: ["Item Name": practiceItem.name])
            } else {
                ModacityAnalytics.LogEvent(.PressedDeleteItemTime)
            }
            delegate.playlistHistoryDetailsRow(self, deleteOnItem: self.rowData!)
        }
    }
    
}
