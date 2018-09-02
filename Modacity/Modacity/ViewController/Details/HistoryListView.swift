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

protocol HistoryListViewDelegate {
    func onAddOnHistoryListView(_ historyListView:HistoryListView)
    
    func onEditPracticeData(_ data: PracticeDaily)
    func onDeletePracticeData(_ data: PracticeDaily)
}

class PracticeHistoryData {
    let date: Date!
    let practices: [PracticeDaily]!
    let dailyPractice: Int
    
    init(date: Date, practices:[PracticeDaily], dailyPractice:Int) {
        self.date = date
        self.practices = practices
        self.dailyPractice = dailyPractice
    }
}

class HistoryListView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var labelNoPracticeData: UILabel!
    
    @IBOutlet weak var viewLoaderPanel: UIView!
    
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var constraintForHistoryViewTopActionsPanelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewTopActionsPanel: UIView!
    
    var delegate: HistoryListViewDelegate!
    var practicesCount = 0
    var practices = [[PracticeDaily]]()
    var dates = [Date]()
    var dailyPractices = [Int]()
    var editing = false
    
    var practiceHistoryDataList = [PracticeHistoryData]()
    
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
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 10))
        topView.backgroundColor = Color.clear
        self.tableViewMain.tableHeaderView = topView
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        bottomView.backgroundColor = Color.clear
        self.tableViewMain.tableFooterView = bottomView
        
//        self.constraintForHistoryViewTopActionsPanelHeight.constant = 0
//        self.viewTopActionsPanel.isHidden = true
    }
    
    func showHistory(for practiceId: String) {
        self.labelNoPracticeData.isHidden = true
        self.viewLoaderPanel.isHidden = true
        let data = PracticingDailyLocalManager.manager.practicingData(forPracticeItemId: practiceId)
        self.practiceHistoryDataList = []
        for date in data.keys {
            let time = date.date(format: "yy-MM-dd")
            var totalPracticesSeconds = 0
            if let dailyDatas = data[date] {
                for daily in dailyDatas {
                    totalPracticesSeconds = totalPracticesSeconds + daily.practiceTimeInSeconds
                }
                self.practiceHistoryDataList.append(PracticeHistoryData(date: time!, practices: dailyDatas.sorted(by: { (daily1, daily2) -> Bool in
                    return daily2.startedTime < daily1.startedTime
                }), dailyPractice: totalPracticesSeconds))
            }
        }
        
        self.practiceHistoryDataList.sort { (data1, data2) -> Bool in
            return data2.date.timeIntervalSince1970 < data1.date.timeIntervalSince1970
        }
        
        self.tableViewMain.reloadData()
        
        if self.practiceHistoryDataList.isEmpty {
            self.labelNoPracticeData.isHidden = false
            self.buttonEdit.isHidden = true
        } else {
            self.labelNoPracticeData.isHidden = true
            self.buttonEdit.isHidden = false
        }
    }
    
    @IBAction func onEdit(_ sender: Any) {
        editing = !editing
        if editing {
            self.buttonEdit.setTitle("Done", for: .normal)
            self.buttonEdit.setImage(nil, for: .normal)
        } else {
            self.buttonEdit.setTitle("", for: .normal)
            self.buttonEdit.setImage(UIImage(named: "btn_edit"), for: .normal)
        }
        self.tableViewMain.reloadData()
    }
    
    @IBAction func onAdd(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.onAddOnHistoryListView(self)
        }
    }
    
}

extension HistoryListView: UITableViewDelegate, UITableViewDataSource, PracticeHistoryCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.practiceHistoryDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PracticeHistoryCell") as! PracticeHistoryCell
        cell.configure(with: practiceHistoryDataList[indexPath.row].practices,
                       on: practiceHistoryDataList[indexPath.row].date,
                       for: practiceHistoryDataList[indexPath.row].dailyPractice,
                       editing: self.editing)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PracticeHistoryCell.height(for: practiceHistoryDataList[indexPath.row].practices, with: UIScreen.main.bounds.size.width)
    }
    
    func practiceHistoryCell(_ cell: PracticeHistoryCell, editOnPractice: PracticeDaily) {
        self.delegate.onEditPracticeData(editOnPractice)
    }
    
    func practiceHistoryCell(_ cell: PracticeHistoryCell, deleteOnPractice: PracticeDaily) {
        self.delegate.onDeletePracticeData(deleteOnPractice)
    }
    
}

