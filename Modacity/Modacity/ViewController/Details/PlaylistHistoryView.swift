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
    
    var practicesCount = 0
    var practices = [[PracticeDaily]]()
    var dates = [Date]()
    var dailyPractices = [Int]()
    
    var practiceHistoryDataList = [PlaylistHistoryData]()
    
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
        
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 10))
        topView.backgroundColor = Color.clear
        self.tableViewMain.tableHeaderView = topView
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 20))
        bottomView.backgroundColor = Color.clear
        self.tableViewMain.tableFooterView = bottomView
    }
    
    func showHistory(for playlistId: String? = nil) {
        
        var data = [String:[PlaylistDaily]]()
        if playlistId == nil {
            data = PlaylistDailyLocalManager.manager.overallPracticeData()
        } else {
            data = PlaylistDailyLocalManager.manager.playlistPracticingData(forPlaylistId: playlistId!)
        }
        
        self.practiceHistoryDataList = []
        for date in data.keys {
            let time = date.date(format: "yy-MM-dd")
            var totalPracticesSeconds = 0
            
            let practiceData = PlaylistHistoryData()
            practiceData.date = time
            practiceData.practiceDataList = [String:PlaylistPracticeHistoryData]()
            
            if let dailyDatas = data[date] {
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
        }
        
        self.practiceHistoryDataList.sort { (data1, data2) -> Bool in
            return data2.date.timeIntervalSince1970 < data1.date.timeIntervalSince1970
        }
        
        self.tableViewMain.reloadData()
    }
}

extension PlaylistHistoryView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.practiceHistoryDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistHistoryCell") as! PlaylistHistoryCell
        cell.configure(with: self.practiceHistoryDataList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistHistoryCell.height(for: self.practiceHistoryDataList[indexPath.row], with: tableView.frame.size.width)
    }
    
}

