//
//  PracticeHistoryCell.swift
//  Modacity
//
//  Created by BC Engineer on 26/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PlaylistHistoryCell: UITableViewCell {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var totalPractice: UILabel!
    @IBOutlet weak var totalPracticeUnit: UILabel!
    
    @IBOutlet weak var constraintForDetailsListHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDetailsListContainer: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with data:PlaylistHistoryData) {
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.layer.shadowColor = UIColor.black.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.viewContainer.layer.shadowOpacity = 0.7
        self.viewContainer.layer.shadowRadius = 4.0
        self.viewContainer.backgroundColor = Color(hexString: "#2e2d4f")
        
        self.labelDate.text = data.date.toString(format: "MMMM d").uppercased()
        let totalSeconds = data.practiceTotalSeconds ?? 0
        if data.practiceTotalSeconds > 60 {
            self.totalPractice.text = "\(totalSeconds / 60)"
            self.totalPracticeUnit.text = "MINUTES"
        } else {
            self.totalPractice.text = "\(totalSeconds)"
            self.totalPracticeUnit.text = "SECONDS"
        }
        
        self.viewDetailsListContainer.subviews.forEach {$0.removeFromSuperview()}
        var height: CGFloat = 0
        var lastView: UIView? = nil
        
        for key in data.practiceDataList.keys {
            if let row = data.practiceDataList[key] {
                let view = PlaylistHistoryDetailsRowView()
                view.configure(with: row)
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
            }
        }
        
        self.constraintForDetailsListHeight.constant = height
        
//        for row in data {
//            let view = PracticeHistoryDetailsRowView()
//            view.configure(with: row)
//            self.viewDetailsListContainer.addSubview(view)
//            view.leadingAnchor.constraint(equalTo: self.viewDetailsListContainer.leadingAnchor).isActive = true
//            view.trailingAnchor.constraint(equalTo: self.viewDetailsListContainer.trailingAnchor).isActive = true
//            view.heightAnchor.constraint(equalToConstant: 36).isActive = true
//            if let lastView = lastView {
//                view.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
//            } else {
//                view.topAnchor.constraint(equalTo: self.viewDetailsListContainer.topAnchor).isActive = true
//            }
//            lastView = view
//            height = height + 36
//
//            if let improvements = row.improvements {
//                for improvement in improvements {
//                    let improvementText = "Improved: \(improvement.suggestion ?? "") - “\(improvement.hypothesis ?? "")“"
//                    let label = UILabel()
//                    label.translatesAutoresizingMaskIntoConstraints = false
//                    label.textColor = Color(hexString:"#908FE6")
//                    label.text = improvementText
//                    label.font = UIFont.systemFont(ofSize: 12)
//                    label.numberOfLines = 0
//                    self.viewDetailsListContainer.addSubview(label)
//                    label.leadingAnchor.constraint(equalTo: self.viewDetailsListContainer.leadingAnchor, constant:10).isActive = true
//                    label.trailingAnchor.constraint(equalTo: self.viewDetailsListContainer.trailingAnchor, constant:-10).isActive = true
//                    if let lastView = lastView {
//                        label.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
//                    }
//                    lastView = label
//                    height = height + improvementText.measureSize(for: UIFont.systemFont(ofSize: 12),
//                                                                  constraindTo: CGSize(width:self.viewDetailsListContainer.frame.size.width - 20,
//                                                                                       height:CGFloat.greatestFiniteMagnitude)).height
//                }
//            }
//        }
//        self.constraintForDetailsListHeight.constant = height
    }
    
    class func height(for data:PlaylistHistoryData, with width: CGFloat) -> CGFloat {
        var height: CGFloat = 49
        for key in data.practiceDataList.keys {
            if let row = data.practiceDataList[key] {
                height = height + 36
//            if let improvements = row.improvements {
//                for improvement in improvements {
//                    let improvementText = "Improved: \(improvement.hypothesis) - \(improvement.suggestion)"
//                    height = height + improvementText.measureSize(for: UIFont.systemFont(ofSize: 12), constraindTo: CGSize(width:width - 66, height:CGFloat.greatestFiniteMagnitude)).height
//                }
//            }
            }
        }
        return height + 20
    }
}
