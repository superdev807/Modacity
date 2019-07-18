//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Charts

class PlaylistStatsView: UIView {

    @IBOutlet var viewContent: UIView!
    
    @IBOutlet weak var viewThisWeekTotalMinutesPanel: UIView!
    @IBOutlet weak var viewLastWeekTotalMinutesPanel: UIView!
    @IBOutlet weak var viewThisMonthTotalMinutesPanel: UIView!
    @IBOutlet weak var viewLastMonthTotalMinutesPanel: UIView!
    @IBOutlet weak var viewAverageSessionDurationPanel: UIView!
    
    @IBOutlet weak var labelThisWeekTotal: UILabel!
    @IBOutlet weak var labelLastWeekTotal: UILabel!
    @IBOutlet weak var labelThisMonthTotal: UILabel!
    @IBOutlet weak var labelLastMonthTotal: UILabel!
    @IBOutlet weak var labelAverageSessionDuration: UILabel!
    @IBOutlet weak var labelAverageDailyTime: UILabel!
    
    @IBOutlet weak var labelThisWeekUnit: UILabel!
    @IBOutlet weak var labelLastWeekUnit: UILabel!
    @IBOutlet weak var labelThisMonthUnit: UILabel!
    @IBOutlet weak var labelLastMonthUnit: UILabel!
    @IBOutlet weak var labelAverageSessionDurationUnit: UILabel!
    @IBOutlet weak var labelAverageDailyTimeUnit: UILabel!
    
    @IBOutlet weak var chartViewBarGraph: BarChartView!
    
    @IBOutlet weak var labelWeekDuration: UILabel!
    @IBOutlet weak var buttonPreviousWeek: UIButton!
    @IBOutlet weak var buttonNextWeek: UIButton!
    
    @IBOutlet weak var labelTotalTime: UILabel!
    @IBOutlet weak var labelTotalTimeUnit: UILabel!
    
    @IBOutlet weak var buttonDetailsBack: UIButton!
    @IBOutlet weak var labelDetailsTitle: UILabel!
    @IBOutlet weak var buttonDetailsForward: UIButton!
    @IBOutlet weak var viewDetailsList: UIView!
    
    @IBOutlet weak var constraintForPracticeDetailsHistoryPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var viewForPracticeDetailsHistoryPanel: UIView!
    
    let detailsPeriodKeys = ["this_week", "last_week", "this_month", "last_month"]
    var detailsPeriodKeyIndex = 0
    
    var playlistIdForStats: String!
    var practiceData: [String: [PracticeDaily]]! = nil
    
    var detailsData = [String:[String: [String:Int]]]()       // this_week: practice_item_id : [time:0, improvements:0]
    
    var date = Date()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PlaylistStatsView", owner: self, options: nil)
        self.addSubview(self.viewContent)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        
        self.viewContent.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.viewContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.viewContent.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.viewContent.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        configureUI()
    }
    
    func configureUI() {
        self.viewThisWeekTotalMinutesPanel.layer.cornerRadius = 5
        self.viewThisWeekTotalMinutesPanel.layer.borderColor = Color.white.alpha(0.1).cgColor
        
        self.viewLastWeekTotalMinutesPanel.layer.cornerRadius = 5
        self.viewLastWeekTotalMinutesPanel.layer.borderColor = Color.white.alpha(0.1).cgColor
        
        self.viewThisMonthTotalMinutesPanel.layer.cornerRadius = 5
        self.viewThisMonthTotalMinutesPanel.layer.borderColor = Color.white.alpha(0.1).cgColor
        
        self.viewLastMonthTotalMinutesPanel.layer.cornerRadius = 5
        self.viewLastMonthTotalMinutesPanel.layer.borderColor = Color.white.alpha(0.1).cgColor
        
        self.viewAverageSessionDurationPanel.layer.cornerRadius = 5
        self.viewAverageSessionDurationPanel.layer.borderColor = Color.white.alpha(0.1).cgColor
        
        self.viewForPracticeDetailsHistoryPanel.layer.cornerRadius = 5
        self.viewForPracticeDetailsHistoryPanel.layer.shadowColor = UIColor.black.cgColor
        self.viewForPracticeDetailsHistoryPanel.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewForPracticeDetailsHistoryPanel.layer.shadowOpacity = 0.4
        self.viewForPracticeDetailsHistoryPanel.layer.shadowRadius = 4.0
        self.viewForPracticeDetailsHistoryPanel.backgroundColor = Color(hexString: "#2e2d4f")
        
        self.constraintForPracticeDetailsHistoryPanelHeight.constant = 100
        initializeBarChart()
        
        self.showSelectedWeekValues()
    }
    
    func showSelectedWeekValues() {
        
        var monday = self.date.weekDay(for: .mon)
        var sunday = monday.addingTimeInterval(6 * 24 * 3600)
        
        if self.date.weekDay == 1 {
            monday = self.date.weekDay(for: .mon).addingTimeInterval(-1 * 7 * 24 * 3600)
            sunday = monday.addingTimeInterval(6 * 24 * 3600)
        }
        self.labelWeekDuration.text = "\(monday.localeDisplay(dateStyle: .medium)) - \(sunday.localeDisplay(dateStyle: .medium))"
//        self.labelWeekDuration.text = "\(monday.toString(format: "MMM d yyyy")) - \(sunday.toString(format: "MMM d yyyy"))"
        
        if self.date.startOfDate().timeIntervalSince1970 == Date().startOfDate().timeIntervalSince1970 {
            self.buttonNextWeek.isHidden = true
        } else {
            self.buttonNextWeek.isHidden = false
        }
        
        if self.practiceData != nil {
            var secondsData = [String:Int]()
            var totalSecondsInWeek = 0
            var entryCountInWeek = 0
            
            for date in self.practiceData.keys {
                let time = date.date(format: "yy-MM-dd")
                if let dailyDatas = self.practiceData[date] {
                    for daily in dailyDatas {
                        if time!.timeIntervalSince1970 >= monday.timeIntervalSince1970 && time!.timeIntervalSince1970 <= sunday.timeIntervalSince1970 {
                            totalSecondsInWeek = totalSecondsInWeek + daily.practiceTimeInSeconds
                            entryCountInWeek = entryCountInWeek + 1
                            if var val = secondsData[date] {
                                val = val + daily.practiceTimeInSeconds
                                secondsData[date] = val
                            } else {
                                secondsData[date] = daily.practiceTimeInSeconds
                            }
                        }
                    }
                }
            }
            
            if entryCountInWeek == 0 {
                self.labelAverageSessionDuration.text = "0"
                self.labelAverageSessionDurationUnit.text = "min"
            } else {
                let averageSessionDuration = totalSecondsInWeek / entryCountInWeek
                if averageSessionDuration > 0 && averageSessionDuration < 60 {
                    self.labelAverageSessionDuration.text = "\(averageSessionDuration)"
                    self.labelAverageSessionDurationUnit.text = "sec"
                } else {
                    self.labelAverageSessionDuration.text = String(format:"%.1f", Double(averageSessionDuration) / 60.0)
                    self.labelAverageSessionDurationUnit.text = "min"
                }
            }
            
            if secondsData.keys.count == 0 {
                self.labelAverageDailyTime.text = "0"
                self.labelAverageDailyTimeUnit.text = "min"
            } else {
                let averageDailyTime = totalSecondsInWeek / secondsData.keys.count
                if averageDailyTime > 0 && averageDailyTime < 60 {
                    self.labelAverageDailyTime.text = "\(averageDailyTime)"
                    self.labelAverageDailyTimeUnit.text = "sec"
                } else {
                    self.labelAverageDailyTime.text = String(format:"%.1f", Double(averageDailyTime) / 60.0)
                    self.self.labelAverageDailyTimeUnit.text = "min"
                }
            }
            
            var cal = monday
            var seconds = [Double]()
            while cal.timeIntervalSince1970 <= sunday.timeIntervalSince1970 {
                let key = cal.toString(format: "yy-MM-dd")
                if let value = secondsData[key] {
                    seconds.append(Double(value) / 60.0)
                } else {
                    seconds.append(0)
                }
                cal = cal.advanced(years: 0, months: 0, weeks: 0, days: 1, hours: 0, minutes: 0, seconds: 0)
            }
            
            setBarChart(dataPoints: ["MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"], values: seconds)
            
        } else {
            
            setBarChart(dataPoints: ["MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"], values: [0,0,0,0,0,0,0])
        }
    }
    
    @IBAction func onPreviousWeek(_ sender: Any) {
        self.date = self.date.addingTimeInterval(-1 * 7 * 24 * 3600)
        self.showSelectedWeekValues()
    }
    
    @IBAction func onNextWeek(_ sender: Any) {
        self.date = self.date.addingTimeInterval(7 * 24 * 3600)
        self.showSelectedWeekValues()
    }
    
    @IBAction func onPrevPeriod(_ sender: Any) {
        self.detailsPeriodKeyIndex = self.detailsPeriodKeyIndex - 1
        self.showSelectedPeriodStats()
    }
    
    @IBAction func onNextPeriod(_ sender: Any) {
        self.detailsPeriodKeyIndex = self.detailsPeriodKeyIndex + 1
        self.showSelectedPeriodStats()
    }
    
    func practiceCalculateLabelsFormatting(totalSeconds: Int, labelValue: UILabel, labelUnit: UILabel) {
        let displayFormat = AppUtils.totalPracticeTimeDisplay(seconds: totalSeconds)
        labelValue.text = displayFormat["value"]
        labelUnit.text = displayFormat["unit"]
    }
    
    func showOverallStats() {
        
        let data = PracticingDailyLocalManager.manager.overallPracticeData()
        
        var totalMinutes = 0
        var entryCount = 0
        var thisWeekTotal = 0
        var lastWeekTotal = 0
        var thisMonthTotal = 0
        var lastMonthTotal = 0
        
        self.detailsData = [String:[String: [String:Int]]]()
        
        for date in data.keys {
            let time = date.date(format: "yy-MM-dd")
            if let dailyDatas = data[date] {
                for practiceDailyData in dailyDatas {
                    entryCount = entryCount + 1
                    if let practiceItemId = practiceDailyData.practiceItemId {
                        
                        totalMinutes = totalMinutes + (practiceDailyData.practiceTimeInSeconds ?? 0)
                        
                        if time!.isThisWeek() {
                            thisWeekTotal = thisWeekTotal + (practiceDailyData.practiceTimeInSeconds ?? 0)
                            self.configureDetails(key: "this_week", practiceItemId: practiceItemId, practiceDailyData: practiceDailyData)
                        }
                        
                        if time!.isLastWeek() {
                            lastWeekTotal = lastWeekTotal + (practiceDailyData.practiceTimeInSeconds ?? 0)
                            self.configureDetails(key: "last_week", practiceItemId: practiceItemId, practiceDailyData: practiceDailyData)
                        }
                        
                        if time!.isThisMonth() {
                            thisMonthTotal = thisMonthTotal + (practiceDailyData.practiceTimeInSeconds ?? 0)
                            self.configureDetails(key: "this_month", practiceItemId: practiceItemId, practiceDailyData: practiceDailyData)
                        }
                        
                        if time!.isLastMonth() {
                            lastMonthTotal = lastMonthTotal + (practiceDailyData.practiceTimeInSeconds ?? 0)
                            self.configureDetails(key: "last_month", practiceItemId: practiceItemId, practiceDailyData: practiceDailyData)
                        }
                        
                    }
                }
            }
        }
        
        let dict = AppUtils.totalPracticeTimeDisplay(seconds: totalMinutes)
        self.labelTotalTime.text = dict["value"]
        self.labelTotalTimeUnit.text = "TOTAL \(dict["unit"] ?? "")"
        
        self.practiceCalculateLabelsFormatting(totalSeconds: thisWeekTotal, labelValue: self.labelThisWeekTotal, labelUnit: self.labelThisWeekUnit)
        self.practiceCalculateLabelsFormatting(totalSeconds: lastWeekTotal, labelValue: self.labelLastWeekTotal, labelUnit: self.labelLastWeekUnit)
        self.practiceCalculateLabelsFormatting(totalSeconds: thisMonthTotal, labelValue: self.labelThisMonthTotal, labelUnit: self.labelThisMonthUnit)
        self.practiceCalculateLabelsFormatting(totalSeconds: lastMonthTotal, labelValue: self.labelLastMonthTotal, labelUnit: self.labelLastMonthUnit)
        
        self.practiceData = data
        self.showSelectedWeekValues()
        self.showSelectedPeriodStats()
    }
    
    func showStats(playlistId: String) {
        
        self.playlistIdForStats = playlistId
        let data = PlaylistDailyLocalManager.manager.playlistPracticingData(forPlaylistId: playlistId)
        ModacityDebugger.debug("Statistics data - \(data)")
        
        var totalSeconds = 0
        var entryCount = 0
        var thisWeekTotal = 0
        var lastWeekTotal = 0
        var thisMonthTotal = 0
        var lastMonthTotal = 0
        
        self.detailsData = [String:[String: [String:Int]]]()
        
        for date in data.keys {
            let time = date.date(format: "yy-MM-dd")
            if let dailyDatas = data[date] {
                for daily in dailyDatas {
                    totalSeconds = totalSeconds + daily.practiceTimeInSeconds
                    entryCount = entryCount + 1
                    
                    if daily.practiceItemId != nil {
                        if time!.isThisWeek() {
                            thisWeekTotal = thisWeekTotal + daily.practiceTimeInSeconds
                            self.configureDetails(key: "this_week", practiceItemId: daily.practiceItemId, practiceDailyData: daily)

                        }
                     
                        if time!.isLastWeek() {
                            lastWeekTotal = lastWeekTotal + daily.practiceTimeInSeconds
                            self.configureDetails(key: "last_week", practiceItemId: daily.practiceItemId, practiceDailyData: daily)
                        }
                        
                        if time!.isThisMonth() {
                            thisMonthTotal = thisMonthTotal + daily.practiceTimeInSeconds
                            self.configureDetails(key: "this_month", practiceItemId: daily.practiceItemId, practiceDailyData: daily)
                        }
                        
                        if time!.isLastMonth() {
                            lastMonthTotal = lastMonthTotal + daily.practiceTimeInSeconds
                            self.configureDetails(key: "last_month", practiceItemId: daily.practiceItemId, practiceDailyData: daily)
                        }
                    }
                }
            }
        }
        
        let dict = AppUtils.totalPracticeTimeDisplay(seconds: totalSeconds)
        self.labelTotalTime.text = dict["value"]
        self.labelTotalTimeUnit.text = "TOTAL \(dict["unit"] ?? "")"
        
        if thisWeekTotal < 60 {
            self.labelThisWeekTotal.text = "\(thisWeekTotal)"
            self.labelThisWeekUnit.text = "SECONDS"
        } else {
            self.labelThisWeekTotal.text = "\(thisWeekTotal / 60)"
            self.labelThisWeekUnit.text = "MINUTES"
        }
        
        if lastWeekTotal < 60 {
            self.labelLastWeekTotal.text = "\(lastWeekTotal)"
            self.labelLastWeekUnit.text = "SECONDS"
        } else {
            self.labelLastWeekTotal.text = "\(lastWeekTotal / 60)"
            self.labelLastWeekUnit.text = "MINUTES"
        }
        
        if thisMonthTotal < 60 {
            self.labelThisMonthTotal.text = "\(thisMonthTotal)"
            self.labelThisMonthUnit.text = "SECONDS"
        } else {
            self.labelThisMonthTotal.text = "\(thisMonthTotal / 60)"
            self.labelThisMonthUnit.text = "MINUTES"
        }
        
        if lastMonthTotal < 60 {
            self.labelLastMonthTotal.text = "\(lastMonthTotal)"
            self.labelLastMonthUnit.text = "SECONDS"
        } else {
            self.labelLastMonthTotal.text = "\(lastMonthTotal / 60)"
            self.labelLastMonthUnit.text = "MINUTES"
        }
        
        self.practiceData = data
        self.showSelectedWeekValues()
        self.showSelectedPeriodStats()
    }
    
    func configureDetails(key: String, practiceItemId:String, practiceDailyData:PracticeDaily) {
        if detailsData[key] == nil {
            detailsData[key] = [String:[String:Int]]()
        }
        
        if let d = detailsData[key]![practiceItemId] {
            
            var newTime = 0
            var newImprovements = 0
            
            if let time = d["time"] {
                newTime = time + practiceDailyData.practiceTimeInSeconds
            }
            
            if let improvements = d["improvements"] {
                newImprovements = improvements + (practiceDailyData.improvements?.count ?? 0)
            }
            
            detailsData[key]![practiceItemId] = ["time": newTime, "improvements": newImprovements]
        } else {
            detailsData[key]![practiceItemId] = ["time": practiceDailyData.practiceTimeInSeconds, "improvements": (practiceDailyData.improvements?.count ?? 0)]
        }
    }
    
    func showSelectedPeriodStats() {
        self.viewDetailsList.subviews.forEach {$0.removeFromSuperview()}
        
        if self.detailsPeriodKeyIndex == 0 {
            self.buttonDetailsBack.isHidden = true
            self.buttonDetailsForward.isHidden = false
        } else if self.detailsPeriodKeyIndex == 3 {
            self.buttonDetailsBack.isHidden = false
            self.buttonDetailsForward.isHidden = true
        } else {
            self.buttonDetailsBack.isHidden = false
            self.buttonDetailsForward.isHidden = false
        }
        
        switch self.detailsPeriodKeyIndex {
        case 0:
            self.labelDetailsTitle.text = "THIS WEEK"
        case 1:
            self.labelDetailsTitle.text = "LAST WEEK"
        case 2:
            self.labelDetailsTitle.text = "THIS MONTH"
        case 3:
            self.labelDetailsTitle.text = "LAST MONTH"
        default:
            break
        }
        
        if let stats = detailsData[detailsPeriodKeys[detailsPeriodKeyIndex]] {
            var lastView: UIView? = nil
            for practiceItemId in stats.keys {
                let rowView = PracticeHistoryDetailsRowView()
                var practiceName = ""
                if practiceItemId == AppConfig.Constants.appConstantMiscPracticeItemId {
                    practiceName = AppConfig.Constants.appConstantMiscPracticeItemName
                } else {
                    if let practice = PracticeItemLocalManager.manager.practiceItem(forId: practiceItemId) {
                        practiceName = practice.name
                    } else {
                        practiceName = "(Deleted)"
                    }
                }
                rowView.configure(title: practiceName, time: stats[practiceItemId]!["time"] ?? 0, improvements: stats[practiceItemId]!["improvements"] ?? 0)
                self.viewDetailsList.addSubview(rowView)
                
                rowView.leadingAnchor.constraint(equalTo: self.viewDetailsList.leadingAnchor).isActive = true
                rowView.trailingAnchor.constraint(equalTo: self.viewDetailsList.trailingAnchor).isActive = true
                rowView.heightAnchor.constraint(equalToConstant: 36).isActive = true
                if let lastView = lastView {
                    rowView.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
                } else {
                    rowView.topAnchor.constraint(equalTo: self.viewDetailsList.topAnchor).isActive = true
                }
                lastView = rowView
            }
            self.constraintForPracticeDetailsHistoryPanelHeight.constant = CGFloat(73.5 + Double(stats.keys.count) * 36.0) + 20
        } else {
            let label = UILabel()
            label.textColor = Color.white
            label.text = "No data"
            label.translatesAutoresizingMaskIntoConstraints = false
            self.viewDetailsList.addSubview(label)
            label.leadingAnchor.constraint(equalTo: self.viewDetailsList.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: self.viewDetailsList.trailingAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 36).isActive = true
            label.topAnchor.constraint(equalTo: self.viewDetailsList.topAnchor).isActive = true
            self.constraintForPracticeDetailsHistoryPanelHeight.constant = CGFloat(73.5 + 36.0) + 20
        }
    }
}


// MARK: - Show charts
extension PlaylistStatsView {
    
    func initializeBarChart() {
        chartViewBarGraph.noDataText = "You need to provide data for the chart."
        
        let formatter = BarChartFormatter()
        formatter.setValues(values: ["MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"])
        let xaxis:XAxis = XAxis()
        xaxis.valueFormatter = formatter
        chartViewBarGraph.xAxis.valueFormatter = xaxis.valueFormatter
        
        chartViewBarGraph.xAxis.labelPosition = .bottom
        chartViewBarGraph.xAxis.drawGridLinesEnabled = false
        chartViewBarGraph.xAxis.drawAxisLineEnabled = false
        
        chartViewBarGraph.xAxis.granularityEnabled = true
        chartViewBarGraph.xAxis.granularity = 1.0
        chartViewBarGraph.xAxis.decimals = 0
        
        chartViewBarGraph.chartDescription?.enabled = false
        chartViewBarGraph.rightAxis.enabled = false
        chartViewBarGraph.legend.enabled = false
        
        chartViewBarGraph.leftAxis.drawGridLinesEnabled = false
        chartViewBarGraph.leftAxis.drawAxisLineEnabled = false
        chartViewBarGraph.leftAxis.drawLabelsEnabled = false
        
        chartViewBarGraph.leftAxis.granularityEnabled = true
        chartViewBarGraph.leftAxis.granularity = 1.0
        chartViewBarGraph.leftAxis.decimals = 0
        
        chartViewBarGraph.rightAxis.drawGridLinesEnabled = false
        chartViewBarGraph.rightAxis.drawAxisLineEnabled = false
        
        chartViewBarGraph.xAxis.labelTextColor = Color.white.alpha(0.5)
    }
    
    func setBarChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: nil)
        var valueColors = [UIColor]()
        var barColors = [UIColor]()
        for _ in dataEntries {
            valueColors.append(Color.white.alpha(0.5))
            barColors.append(Color(hexString: "#2E64E5"))
        }
        chartDataSet.valueColors = valueColors
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 8)
        chartDataSet.colors = barColors
        
        let valueFormatter = BarChartIntFormatter()
        chartDataSet.valueFormatter = valueFormatter
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.5
        
        chartViewBarGraph.data?.notifyDataChanged()
        chartViewBarGraph.data = chartData
        
        chartViewBarGraph.animate(yAxisDuration: 1.5)
    }
}
