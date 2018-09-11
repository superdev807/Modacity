//
//  PracticeHistoryCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 26/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PlaylistHistoryCellDelegate {
    func playlistHistoryCell(_ cell: PlaylistHistoryCell, editOnItem: PracticeDaily)
    func playlistHistoryCell(_ cell: PlaylistHistoryCell, deleteOnItem: PracticeDaily)
}

class PlaylistHistoryCell: UITableViewCell {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var totalPractice: UILabel!
    @IBOutlet weak var totalPracticeUnit: UILabel!
    
    @IBOutlet weak var constraintForDetailsListHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDetailsListContainer: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var constraintForContainerHeight: NSLayoutConstraint!
    
    var delegate: PlaylistHistoryCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with data:PlaylistHistoryData, editing: Bool) {
        
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.shadowColor = UIColor.black.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewContainer.layer.shadowOpacity = 0.4
        self.viewContainer.layer.shadowRadius = 3.0
        self.viewContainer.backgroundColor = Color(hexString: "#2e2d4f")
        
        self.labelDate.text = data.date.toString(format: "MMMM d").uppercased()
        let totalSeconds = data.practiceTotalSeconds ?? 0
        if data.practiceTotalSeconds > 60 {
            if data.practiceTotalSeconds < 600 {
                self.totalPractice.text = String(format: "%.1f", Double(totalSeconds) / 60.0)
            } else {
                self.totalPractice.text = "\(totalSeconds / 60)"
            }
            
            self.totalPracticeUnit.text = "MINUTES"
        } else {
            self.totalPractice.text = "\(totalSeconds)"
            self.totalPracticeUnit.text = "SECONDS"
        }
        
        self.viewDetailsListContainer.subviews.forEach {$0.removeFromSuperview()}
        var height: CGFloat = 0
        var lastView: UIView? = nil
        
        for row in data.practiceDataList {
            
            let view = PlaylistHistoryDetailsRowView()
            view.configure(with: row, editing: editing)
            view.delegate = self
            self.viewDetailsListContainer.addSubview(view)
            view.leadingAnchor.constraint(equalTo: self.viewDetailsListContainer.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.viewDetailsListContainer.trailingAnchor).isActive = true
            view.heightAnchor.constraint(equalToConstant: 36).isActive = true
            if let lastView = lastView {
                view.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
            } else {
                view.topAnchor.constraint(equalTo: self.viewDetailsListContainer.topAnchor).isActive = true
            }
            
            lastView = view
            height = height + 36
            
            if let improvements = row.improvements {
                for improvement in improvements {
                    let improvementAttributedStringText = NSMutableAttributedString(string: "Improved: ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoRegular, size: 12)!])
                    let improvementSuggestion = improvement.suggestion ?? ""
                    improvementAttributedStringText.append(NSAttributedString(string: improvementSuggestion, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 12)!]))
                    improvementAttributedStringText.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoRegular, size: 12)!]))
                    let hypothesisString = "“\(improvement.hypothesis ?? "")“"
                    improvementAttributedStringText.append(NSAttributedString(string: hypothesisString, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoItalic, size: 12)!]))
                    let label = UILabel()
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textColor = Color(hexString:"#908FE6")
                    label.attributedText = improvementAttributedStringText
                    label.numberOfLines = 0
                    self.viewDetailsListContainer.addSubview(label)
                    label.leadingAnchor.constraint(equalTo: self.viewDetailsListContainer.leadingAnchor, constant:0).isActive = true
                    label.trailingAnchor.constraint(equalTo: self.viewDetailsListContainer.trailingAnchor, constant:0).isActive = true
                    if let lastView = lastView {
                        label.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
                    }
                    lastView = label
                    height = height + improvementAttributedStringText.boundingRect(with: CGSize(width:UIScreen.main.bounds.size.width - 61,
                                                                                                height:CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.height
                }
            }
        }
        
        self.constraintForDetailsListHeight.constant = height
        self.constraintForContainerHeight.constant = height + 55
        self.layoutIfNeeded()
    }
    
    class func height(for data:PlaylistHistoryData, with width: CGFloat) -> CGFloat {
        var height: CGFloat = 49

        for row in data.practiceDataList {
            height = height + 36
            if let improvements = row.improvements {
                for improvement in improvements {
                    
                    let improvementAttributedStringText = NSMutableAttributedString(string: "Improved: ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoRegular, size: 12)!])
                    let improvementSuggestion = improvement.suggestion ?? ""
                    improvementAttributedStringText.append(NSAttributedString(string: improvementSuggestion, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoBlack, size: 12)!]))
                    improvementAttributedStringText.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoRegular, size: 12)!]))
                    let hypothesisString = "“\(improvement.hypothesis ?? "")“"
                    improvementAttributedStringText.append(NSAttributedString(string: hypothesisString, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.appFontLatoItalic, size: 12)!]))
                    height = height + improvementAttributedStringText.boundingRect(with: CGSize(width:UIScreen.main.bounds.size.width - 61,
                                                                                                height:CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.height
                }
            }
        }
        
        return (height + 15) + 5
    }
}

extension PlaylistHistoryCell: PlaylistHistoryDetailsRowViewDelegate {
    
    func playlistHistoryDetailsRow(_ view: PlaylistHistoryDetailsRowView, editOnItem: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.playlistHistoryCell(self, editOnItem: editOnItem)
        }
    }
    
    func playlistHistoryDetailsRow(_ view: PlaylistHistoryDetailsRowView, deleteOnItem: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.playlistHistoryCell(self, deleteOnItem: deleteOnItem)
        }
    }
    
}
