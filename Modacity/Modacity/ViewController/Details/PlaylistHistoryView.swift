//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity. All rights reserved.
//

import UIKit
import Charts
import AVFoundation

protocol PlaylistHistoryListViewDelegate {
    func onAddOnPlaylistHistoryListView(_ historyListView:PlaylistHistoryView, playlistId: String?)
    
    func onEditPlaylistPracticeData(_ data: PracticeDaily, playlistId: String?)
    func onDeletePlaylistPracticeData(_ data: PracticeDaily, playlistId: String?)
}

class PlaylistHistoryData {
    var date: Date!
    var practiceTotalSeconds: Int!
    var practiceDataList = [PracticeDaily]()
    
    init() {}
}

class PlaylistHistoryView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var constraintForHistoryViewTopActionsPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTopActionsPanel: UIView!
    @IBOutlet weak var labelNoPracticeData: UILabel!
    @IBOutlet weak var viewLoaderPanel: UIView!
    
    var data = [String:[PracticeDaily]]()
    var practicesCount = 0
    var practices = [[PracticeDaily]]()
    var dates = [Date]()
    var startIdx = 0
    var dailyPractices = [Int]()
    var practiceHistoryDataList = [PlaylistHistoryData]()
    var firstTimeLoading = true
    var editing = false
    
    var playlistId: String? = nil
    
    let firstLoadingCount = 15
    let nextLoadingCount = 30
    var delegate: PlaylistHistoryListViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PlaylistHistoryView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        self.tableViewMain.register(UINib(nibName: "PlaylistHistoryCell", bundle: nil), forCellReuseIdentifier: "PlaylistHistoryCell")
        self.tableViewMain.register(UINib(nibName: "LoadMoreCell", bundle: nil), forCellReuseIdentifier: "LoadMoreCell")
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 10))
        topView.backgroundColor = Color.clear
        self.tableViewMain.tableHeaderView = topView
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        bottomView.backgroundColor = Color.clear
        self.tableViewMain.tableFooterView = bottomView
        
//        self.constraintForHistoryViewTopActionsPanelHeight.constant = 0
//        self.viewTopActionsPanel.isHidden = true
    }
    
    func clear() {
        self.startIdx = 0
        self.data = [String:[PracticeDaily]]()
        self.practices = [[PracticeDaily]]()
        self.practicesCount = 0
        self.dates = [Date]()
        
        self.dailyPractices = [Int]()
        self.practiceHistoryDataList = [PlaylistHistoryData]()
        self.firstTimeLoading = true
        
    }
    
    func loadPriData(for playlistId: String? = nil) {
        self.data = [String:[PracticeDaily]]()
        if playlistId == nil {
            self.data = PracticingDailyLocalManager.manager.overallPracticeData()
        } else {
            self.data = PlaylistDailyLocalManager.manager.playlistPracticingData(forPlaylistId: playlistId!)
        }
        
        for date in self.data.keys {
            if let time = date.date(format: "yy-MM-dd") {
                self.dates.append(time)
            }
        }
        
        self.dates.sort { (date1, date2) -> Bool in
            return date1 > date2
        }
        
        DispatchQueue.main.async {
            if self.data.isEmpty {
                self.labelNoPracticeData.text = "No practice data"
                self.labelNoPracticeData.isHidden = false
                self.buttonEdit.isHidden = true
            } else {
                self.labelNoPracticeData.isHidden = true
                self.buttonEdit.isHidden = false
            }
        }
    }
    
    func loadNextData() {
        if self.startIdx == -1 {
            return
        }
        
        var idx = self.startIdx
        while idx < self.startIdx + ((self.startIdx == 0) ? firstLoadingCount : nextLoadingCount) && idx < self.dates.count {
            
            let time = self.dates[idx]
            
            var totalPracticesSeconds = 0
            
            let practiceData = PlaylistHistoryData()
            practiceData.date = time
            practiceData.practiceDataList = [PracticeDaily]()
            
            if let dailyDatas = self.data[time.toString(format: "yy-MM-dd")] {
                for daily in dailyDatas {
                    totalPracticesSeconds = totalPracticesSeconds + daily.practiceTimeInSeconds

//                    if daily.practices != nil {
//                        for practiceId in daily.practices {
//                            if let practicingData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceId) {
                                practiceData.practiceDataList.append(daily)
//                            }
//                        }
//                    }
                }
            }
            
            practiceData.practiceDataList.sort { (data1, data2) -> Bool in
                return data1.startedTime > data2.startedTime
            }
            
            practiceData.practiceTotalSeconds = totalPracticesSeconds
            self.practiceHistoryDataList.append(practiceData)
            
            idx = idx + 1
        }
        
        self.practiceHistoryDataList.sort { (data1, data2) -> Bool in
            return data2.date.timeIntervalSince1970 < data1.date.timeIntervalSince1970
        }
        
        if idx == self.dates.count {
            self.startIdx = -1
        } else {
            self.startIdx = idx
        }
    }
    
    func showHistory(for playlistId: String? = nil) {
        
        self.playlistId = playlistId
        
        if self.firstTimeLoading {
            self.viewLoaderPanel.isHidden = true
            self.firstTimeLoading = false
        }

        self.labelNoPracticeData.isHidden = true

        DispatchQueue.global().async {
            let time = Date()
            
            self.data = [String:[PracticeDaily]]()
            if playlistId == nil {
                self.data = PracticingDailyLocalManager.manager.overallPracticeData()
            } else {
                self.data = PlaylistDailyLocalManager.manager.playlistPracticingData(forPlaylistId: playlistId!)
            }
            
            print("Took time to load - \(Date().timeIntervalSince1970 - time.timeIntervalSince1970)")
            
            self.loadPriData(for: playlistId)
            
            self.practiceHistoryDataList = []
            
            self.loadNextData()
            
            print("Took time to load and process - \(Date().timeIntervalSince1970 - time.timeIntervalSince1970)")
            
            DispatchQueue.main.async {
                print("Took time to load and process, show - \(Date().timeIntervalSince1970 - time.timeIntervalSince1970)")
                self.viewLoaderPanel.isHidden = true
                self.tableViewMain.reloadData()
            }
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
        ModacityAnalytics.LogEvent(.PressedAddEntry)
        if let delegate = self.delegate {
            delegate.onAddOnPlaylistHistoryListView(self, playlistId: self.playlistId)
        }
    }
}

extension PlaylistHistoryView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.practiceHistoryDataList.count + ((self.startIdx != -1 && self.practiceHistoryDataList.count > 0) ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.practiceHistoryDataList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistHistoryCell") as! PlaylistHistoryCell
            cell.configure(with: self.practiceHistoryDataList[indexPath.row], editing: self.editing)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell") as! LoadMoreCell
            cell.viewContainer.layer.cornerRadius = 5
            cell.viewContainer.layer.shadowColor = UIColor.black.cgColor
            cell.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.viewContainer.layer.shadowOpacity = 0.4
            cell.viewContainer.layer.shadowRadius = 4.0
            cell.viewContainer.backgroundColor = Color(hexString: "#2e2d4f")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < self.practiceHistoryDataList.count {
            return PlaylistHistoryCell.height(for: self.practiceHistoryDataList[indexPath.row], with: UIScreen.main.bounds.size.width)
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.practiceHistoryDataList.count {
            DispatchQueue.global().async {
                self.loadNextData()
                DispatchQueue.main.async {
                    self.tableViewMain.reloadData()
                }
            }
        }
    }
    
}

extension PlaylistHistoryView: PlaylistHistoryCellDelegate {
    
    func playlistHistoryCell(_ cell: PlaylistHistoryCell, editOnItem: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.onEditPlaylistPracticeData(editOnItem, playlistId: self.playlistId)
        }
    }
    
    func playlistHistoryCell(_ cell: PlaylistHistoryCell, deleteOnItem: PracticeDaily) {
        if let delegate = self.delegate {
            delegate.onDeletePlaylistPracticeData(deleteOnItem, playlistId: self.playlistId)
        }
    }
    
}
