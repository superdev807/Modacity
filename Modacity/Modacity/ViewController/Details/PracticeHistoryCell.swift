//
//  PracticeHistoryCell.swift
//  Modacity
//
//  Created by Benjamin Chris on 26/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit

protocol PracticeHistoryCellDelegate {
    func practiceHistoryCell(_ cell: PracticeHistoryCell, editOnPractice: PracticeDaily)
    func practiceHistoryCell(_ cell: PracticeHistoryCell, deleteOnPractice: PracticeDaily)
}

class PracticeHistoryCell: UITableViewCell, PracticeHistoryDetailsRowViewDelegate {

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var totalPractice: UILabel!
    @IBOutlet weak var totalPracticeUnit: UILabel!
    
    @IBOutlet weak var constraintForDetailsListHeight: NSLayoutConstraint!
    @IBOutlet weak var viewDetailsListContainer: UIView!
    @IBOutlet weak var viewContainer: UIView!
    
    var delegate: PracticeHistoryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with data:[PracticeDaily], on date:Date, for total:Int, editing: Bool = false) {
        self.viewContainer.layer.cornerRadius = 5
        self.viewContainer.backgroundColor = Color(hexString: "#2e2d4f")
        
        self.viewContainer.layer.shadowColor = UIColor.black.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewContainer.layer.shadowOpacity = 0.4
        self.viewContainer.layer.shadowRadius = 3.0

        self.labelDate.text = date.localeDisplay(dateStyle: .long).uppercased()
        if total > 60 {
            if total < 600 {
                self.totalPractice.text = String(format: "%.1f", Double(total) / 60.0)
            } else {
                self.totalPractice.text = "\(total / 60)"
            }
            
            self.totalPracticeUnit.text = "MINUTES"
        } else {
            self.totalPractice.text = "\(total)"
            self.totalPracticeUnit.text = "SECONDS"
        }
        
        self.viewDetailsListContainer.subviews.forEach {$0.removeFromSuperview()}
        var height: CGFloat = 0
        var lastView: UIView? = nil
        for row in data {
            let view = PracticeHistoryDetailsRowView()
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
                    let improvementAttributedStringText = NSMutableAttributedString(string: "Improved: ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!])
                    let improvementSuggestion = improvement.suggestion ?? ""
                    improvementAttributedStringText.append(NSAttributedString(string: improvementSuggestion, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 12)!]))
                    improvementAttributedStringText.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!]))
                    let hypothesisString = "“\(improvement.hypothesis ?? "")“"
                    improvementAttributedStringText.append(NSAttributedString(string: hypothesisString, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoItalic, size: 12)!]))
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
    }
    
    class func height(for data:[PracticeDaily], with width: CGFloat) -> CGFloat {
        var height: CGFloat = 49
        for row in data {
            height = height + 36
            if let improvements = row.improvements {
                for improvement in improvements {
                    let improvementAttributedStringText = NSMutableAttributedString(string: "Improved: ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!])
                    let improvementSuggestion = improvement.suggestion ?? ""
                    improvementAttributedStringText.append(NSAttributedString(string: improvementSuggestion, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoBlack, size: 12)!]))
                    improvementAttributedStringText.append(NSAttributedString(string: " - ", attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoRegular, size: 12)!]))
                    let hypothesisString = "“\(improvement.hypothesis ?? "")“"
                    improvementAttributedStringText.append(NSAttributedString(string: hypothesisString, attributes: [NSAttributedStringKey.font: UIFont(name: AppConfig.UI.Fonts.appFontLatoItalic, size: 12)!]))
                    height = height + improvementAttributedStringText.boundingRect(with: CGSize(width:UIScreen.main.bounds.size.width - 61,
                                                                                                height:CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).size.height
                }
            }
        }
        return (height + 15) + 5
    }
    
    func practiceHistoryDetailsRow(_ view: PracticeHistoryDetailsRowView, editOnPractice: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.practiceHistoryCell(self, editOnPractice: editOnPractice)
        }
    }
    
    func practiceHistoryDetailsRow(_ view: PracticeHistoryDetailsRowView, deleteOnPractice: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.practiceHistoryCell(self, deleteOnPractice: deleteOnPractice)
        }
    }
}
