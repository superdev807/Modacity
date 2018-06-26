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

class HistoryListView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var practicesCount = 0
    var practices = [[PracticeDaily]]()
    var dates = [Date]()
    var dailyPractices = [Int]()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("HistoryListView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewMain.register(UINib(nibName: "PracticeHistoryCell", bundle: nil), forCellReuseIdentifier: "PracticeHistoryCell")
    }
    
    func showHistory(for practiceId: String) {
        
    }
}

extension HistoryListView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return practicesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeHistoryCell") as! PracticeHistoryCell
        cell.configure(with: practices[indexPath.row], on: dates[indexPath.row], for: dailyPractices[indexPath.row])
        return cell
    }
    
}

