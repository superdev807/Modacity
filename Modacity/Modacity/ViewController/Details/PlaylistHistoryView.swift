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

class PlaylistPracticeHistoryData {
    var practiceItemId: String!
    var time: Int!
    var averageRating: Double!
    var improvements = [ImprovedRecord]()
    var ratings = [Double]()
    var lastPracticeTime: TimeInterval!
    
    init() {
        
    }
    
    init(practiceId: String, time: Int, rating: Double, improvements: [ImprovedRecord], lastPracticeTime: TimeInterval) {
        self.practiceItemId = practiceId
        self.time = time
        self.averageRating = rating
        self.improvements = improvements
        self.lastPracticeTime = lastPracticeTime
    }
    
    func calculateAverageRatings() -> Double {
        var total = 0.0
        var count = 0
        for rating in ratings {
            if rating > 0 {
                total = total + rating
                count = count + 1
            }
        }
        
        if count > 0 {
            return total / Double(count)
        } else {
            return 0
        }
    }
}

class PlaylistHistoryData {
    var date: Date!
    var practiceTotalSeconds: Int!
    var practiceDataList: [String:PlaylistPracticeHistoryData]!
    
    init() {
        
    }
    
    init(date: Date, totalSeconds: Int, dataList: [String:PlaylistPracticeHistoryData]) {
        self.date = date
        self.practiceTotalSeconds = totalSeconds
        self.practiceDataList = dataList
    }
    
    func arrayOfData() -> [PlaylistPracticeHistoryData]? {
        if self.practiceDataList == nil {
            return nil
        } else {
            var array = [PlaylistPracticeHistoryData]()
            for (_, value) in self.practiceDataList {
                array.append(value)
            }
            
            return array.sorted(by: { (data1, data2) -> Bool in
                return data1.lastPracticeTime > data2.lastPracticeTime
            })
        }
        
    }
}

class PlaylistHistoryView: UIView {

    @IBOutlet var viewContent: UIView!
    @IBOutlet weak var tableViewMain: UITableView!
    
    var data = [String:[PlaylistDaily]]()
    var practicesCount = 0
    var practices = [[PracticeDaily]]()
    var dates = [Date]()
    var startIdx = 0
    var dailyPractices = [Int]()
    var practiceHistoryDataList = [PlaylistHistoryData]()
    var firstTimeLoading = true
    
    @IBOutlet weak var labelNoPracticeData: UILabel!
    let firstLoadingCount = 15
    let nextLoadingCount = 30
    
    @IBOutlet weak var viewLoaderPanel: UIView!
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
    }
    
    func loadPriData(for playlistId: String? = nil) {
        self.data = [String:[PlaylistDaily]]()
        if playlistId == nil {
            self.data = PlaylistDailyLocalManager.manager.overallPracticeData()
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
            } else {
                self.labelNoPracticeData.isHidden = true
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
            practiceData.practiceDataList = [String:PlaylistPracticeHistoryData]()
            
            if let dailyDatas = self.data[time.toString(format: "yy-MM-dd")] {
                for daily in dailyDatas {
                    totalPracticesSeconds = totalPracticesSeconds + daily.practiceTimeInSeconds
                    
                    if daily.practices != nil {
                        for practiceId in daily.practices {
                            if let practicingData = PracticingDailyLocalManager.manager.practicingData(forDataId: practiceId) {
                                if let practiceItemId = practicingData.practiceItemId {
                                    if let old = practiceData.practiceDataList[practiceItemId] {
                                        if practicingData.rating > 0 {
                                            old.ratings.append(practicingData.rating)
                                        }
                                        if let improvements = practicingData.improvements {
                                            old.improvements.append(contentsOf: improvements)
                                        }
                                        if old.lastPracticeTime < practicingData.startedTime {
                                            old.lastPracticeTime = practicingData.startedTime
                                        }
                                        old.time = old.time + practicingData.practiceTimeInSeconds
                                        practiceData.practiceDataList[practiceItemId] = old
                                    } else {
                                        let newData = PlaylistPracticeHistoryData()
                                        newData.practiceItemId = practiceItemId
                                        newData.time = practicingData.practiceTimeInSeconds
                                        newData.lastPracticeTime = practicingData.startedTime
                                        if practicingData.rating > 0 {
                                            newData.ratings.append(practicingData.rating)
                                        }
                                        if let improvements = practicingData.improvements {
                                            newData.improvements.append(contentsOf: improvements)
                                        }
                                        practiceData.practiceDataList[practiceItemId] = newData
                                    }
                                }
                            }
                        }
                    }
                }
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
        
        if self.firstTimeLoading {
            self.viewLoaderPanel.isHidden = true
            self.firstTimeLoading = false
        }
        
        self.labelNoPracticeData.isHidden = true
        
        DispatchQueue.global().async {
            let time = Date()
            
            self.data = [String:[PlaylistDaily]]()
            if playlistId == nil {
                self.data = PlaylistDailyLocalManager.manager.overallPracticeData()
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
}

extension PlaylistHistoryView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.practiceHistoryDataList.count + ((self.startIdx != -1 && self.practiceHistoryDataList.count > 0) ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.practiceHistoryDataList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistHistoryCell") as! PlaylistHistoryCell
            cell.configure(with: self.practiceHistoryDataList[indexPath.row])
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

