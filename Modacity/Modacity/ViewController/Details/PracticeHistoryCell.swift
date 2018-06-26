//
//  PracticeHistoryCell.swift
//  Modacity
//
//  Created by BC Engineer on 26/6/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class PracticeHistoryCell: UITableViewCell {

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
    
    func configure(with data:[PracticeDaily], on date:Date, for total:Int) {
        self.labelDate.text = date.toString(format: "MMMM d")
        if total > 60 {
            self.totalPractice.text = "\(total / 60)"
            self.totalPracticeUnit.text = "MINUTES"
        } else {
            self.totalPractice.text = "\(total)"
            self.totalPracticeUnit.text = "SECONDS"
        }
        
        self.viewDetailsListContainer.subviews.forEach {$0.removeFromSuperview()}
        
        var lastView: UIView? = nil
        for row in data {
            let view = PracticeHistoryDetailsRowView()
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
        }
    }
    
}
