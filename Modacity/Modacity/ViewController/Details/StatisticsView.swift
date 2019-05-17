//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by Benjamin Chris on 11/6/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

import UIKit
import Charts

class StatisticsView: UIView {

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
    @IBOutlet weak var chartViewStarRatings: LineChartView!
    
    @IBOutlet weak var labelWeekDuration: UILabel!
    @IBOutlet weak var buttonPreviousWeek: UIButton!
    @IBOutlet weak var buttonNextWeek: UIButton!
    
    @IBOutlet weak var labelTotalTime: UILabel!
    @IBOutlet weak var labelTotalTimeUnit: UILabel!
    
    var practiceItemIdForStats: String!
    var practiceData: [String: [PracticeDaily]]! = nil
    
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
        Bundle.main.loadNibNamed("StatisticsView", owner: self, options: nil)
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
        
        initializeBarChart()
    }
    
    func showTotalTimeAndRaitingLine() {
        if self.practiceData != nil {
            var totalSeconds = 0
            var ratings = [Double:Double]()
            
            for date in self.practiceData.keys {
                if let dailyDatas = self.practiceData[date] {
                    for daily in dailyDatas {
                        totalSeconds = totalSeconds + daily.practiceTimeInSeconds
                        
                        if daily.rating != nil && daily.rating > 0 {
                            let ratingKey = (daily.entryDateString + " " + daily.fromTime).date(format: "yy-MM-dd HH:mm:ss")!.timeIntervalSince1970
                            ratings[ratingKey] = daily.rating
                        }
                    }
                }
            }
            
            print("ratings - \(ratings)")
            
            if totalSeconds > 0 && totalSeconds < 60 {
                self.labelTotalTime.text = "\(totalSeconds)"
                self.labelTotalTimeUnit.text = "TOTAL SECONDS"
            } else {
                self.labelTotalTime.text = String(format:"%.1f", Double(totalSeconds) / 60.0)
                self.labelTotalTimeUnit.text = "TOTAL MINUTES"
            }
            
            let sorted = ratings.sorted {$0.key < $1.key}
            var ratingsLine = [Double]()
            var ratingsTimeStamp = [TimeInterval]()
            
            for (timeStamp, value) in sorted {
                ratingsLine.append(value)
                ratingsTimeStamp.append(timeStamp)
            }
            
            if ratingsLine.count == 1 {
                ratingsLine.insert(0, at: 0)
                ratingsTimeStamp.insert(0, at: 0)
            }
            
            setRatingLineChart(values: ratingsLine, timeStamp: ratingsTimeStamp)
        } else {
            setRatingLineChart(values: [], timeStamp: [])
        }
    }
    
    func showSectionedValues() {
        
        if let data = self.practiceData {
            var thisWeekTotal = 0
            var lastWeekTotal = 0
            var thisMonthTotal = 0
            var lastMonthTotal = 0
            
            for date in data.keys {
                let time = date.date(format: "yy-MM-dd")
                if let dailyDatas = data[date] {
                    for daily in dailyDatas {
                        if time!.isThisWeek() {
                            thisWeekTotal = thisWeekTotal + daily.practiceTimeInSeconds
                        }
                        
                        if time!.isLastWeek() {
                            lastWeekTotal = lastWeekTotal + daily.practiceTimeInSeconds
                        }
                        
                        if time!.isThisMonth() {
                            thisMonthTotal = thisMonthTotal + daily.practiceTimeInSeconds
                        }
                        
                        if time!.isLastMonth() {
                            lastMonthTotal = lastMonthTotal + daily.practiceTimeInSeconds
                        }
                    }
                }
            }
            
            self.practiceCalculateLabelsFormatting(totalSeconds: thisWeekTotal, labelValue: self.labelThisWeekTotal, labelUnit: self.labelThisWeekUnit)
            self.practiceCalculateLabelsFormatting(totalSeconds: lastWeekTotal, labelValue: self.labelLastWeekTotal, labelUnit: self.labelLastWeekUnit)
            self.practiceCalculateLabelsFormatting(totalSeconds: thisMonthTotal, labelValue: self.labelThisMonthTotal, labelUnit: self.labelThisMonthUnit)
            self.practiceCalculateLabelsFormatting(totalSeconds: lastMonthTotal, labelValue: self.labelLastMonthTotal, labelUnit: self.labelLastMonthUnit)
        }
    }
    
    func showWeeklyValues() {
        
        var monday = self.date.weekDay(for: .mon)
        var sunday = monday.addingTimeInterval(6 * 24 * 3600)
        
        if self.date.weekDay == 1 {
            monday = self.date.weekDay(for: .mon).addingTimeInterval(-1 * 7 * 24 * 3600)
            sunday = monday.addingTimeInterval(6 * 24 * 3600)
        }
        
        self.labelWeekDuration.text = "\(monday.toString(format: "MMM d yyyy")) - \(sunday.toString(format: "MMM d yyyy"))"
        
        if self.date.startOfDate().timeIntervalSince1970 == Date().startOfDate().timeIntervalSince1970 {
            self.buttonNextWeek.isHidden = true
        } else {
            self.buttonNextWeek.isHidden = false
        }
        
        if self.practiceData != nil {
            var secondsData = [String:Int]()
            var sessionsCountInWeek = 0
            var totalTimeInWeek = 0
            
            for date in self.practiceData.keys {
                let time = date.date(format: "yy-MM-dd")
                if let dailyDatas = self.practiceData[date] {
                    for daily in dailyDatas {
                        if time!.timeIntervalSince1970 >= monday.timeIntervalSince1970 && time!.timeIntervalSince1970 <= sunday.timeIntervalSince1970 {
                            
                            sessionsCountInWeek = sessionsCountInWeek + 1
                            totalTimeInWeek = totalTimeInWeek + daily.practiceTimeInSeconds
                            
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
            
            if sessionsCountInWeek == 0 {
                self.labelAverageSessionDuration.text = "0"
                self.labelAverageSessionDurationUnit.text = "min"
            } else {
                let averageSessionDuration = totalTimeInWeek / sessionsCountInWeek
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
                let averageDailyTime = totalTimeInWeek / secondsData.keys.count
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
                    seconds.append(Double(value) / 60)
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
        self.showWeeklyValues()
    }
    
    @IBAction func onNextWeek(_ sender: Any) {
        self.date = self.date.addingTimeInterval(7 * 24 * 3600)
        self.showWeeklyValues()
    }
    
    func showStats(practice: String) {
        self.practiceItemIdForStats = practice
        let data = PracticingDailyLocalManager.manager.practicingData(forPracticeItemId: practice)
        
        self.practiceData = data
        
        self.showTotalTimeAndRaitingLine()
        self.showSectionedValues()
        self.showWeeklyValues()
    }
    
    func practiceCalculateLabelsFormatting(totalSeconds: Int, labelValue: UILabel, labelUnit: UILabel) {
        let displayFormat = AppUtils.totalPracticeTimeDisplay(seconds: totalSeconds)
        labelValue.text = displayFormat["value"]
        labelUnit.text = displayFormat["unit"]
    }
}


// MARK: - Show charts
extension StatisticsView {
    
    func setRatingLineChart(values: [Double], timeStamp: [TimeInterval]) {
        
        let formatter = BarChartFormatter()
        
        let xaxis:XAxis = XAxis()
        
        var dates = [String]()
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            let time = timeStamp[i]
            if time > 0 {
                if i == values.count - 1 || i == 0 {
                    let date = Date(timeIntervalSince1970: time)
                    dates.append(date.toString(format: "MMM d"))
                } else {
                    dates.append("")
                }
            } else {
                dates.append("")
            }
        }
        
        formatter.setValues(values: dates)
        xaxis.valueFormatter = formatter
        chartViewStarRatings.xAxis.valueFormatter = xaxis.valueFormatter
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        
        let gradientColors = [Color(hexString: "#6815CE").cgColor, Color(hexString: "#2B67F5").cgColor] as CFArray
        let colorLocations:[CGFloat] = [1.0, 0.0]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 0)
        chartDataSet.fillAlpha = 0.25
        chartDataSet.drawFilledEnabled = true
        chartDataSet.mode = .cubicBezier
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = 5
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.colors = [Color(hexString: "#2B67F5")]
        chartDataSet.drawValuesEnabled = false
        
        let chartData = LineChartData(dataSet: chartDataSet)
        chartViewStarRatings.data = chartData
        chartViewStarRatings.clipsToBounds = false
        chartViewStarRatings.xAxis.labelPosition = .bottom
        chartViewStarRatings.xAxis.drawGridLinesEnabled = false
        chartViewStarRatings.xAxis.drawAxisLineEnabled = true
        chartViewStarRatings.xAxis.drawLabelsEnabled = true
        
        chartViewStarRatings.chartDescription?.enabled = false
        chartViewStarRatings.rightAxis.enabled = false
        chartViewStarRatings.leftAxis.enabled = true
        chartViewStarRatings.legend.enabled = false
        
        chartViewStarRatings.leftAxis.drawGridLinesEnabled = true
        chartViewStarRatings.leftAxis.drawAxisLineEnabled = true
        chartViewStarRatings.leftAxis.drawLabelsEnabled = true
        chartViewStarRatings.leftAxis.labelTextColor = Color.white.alpha(0.5)
        
        chartViewStarRatings.leftAxis.granularityEnabled = true
        chartViewStarRatings.leftAxis.granularity = 1.0
        chartViewStarRatings.leftAxis.decimals = 0
        
        chartViewStarRatings.leftAxis.valueFormatter = ChartAxisLineIntFormatter()
        
        chartViewStarRatings.leftAxis.axisMinimum = 0.5
        chartViewStarRatings.leftAxis.axisMaximum = 5.5
        
        chartViewStarRatings.xAxis.spaceMin = 0.1
        chartViewStarRatings.xAxis.spaceMax = 0.1
        
        chartViewStarRatings.animate(yAxisDuration: 1.5)
        
        chartViewStarRatings.xAxis.granularityEnabled = true
        chartViewStarRatings.xAxis.granularity = 1.0
        chartViewStarRatings.xAxis.decimals = 0
        chartViewStarRatings.xAxis.labelTextColor = Color.white.alpha(0.5)
    }
    
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
    
    func setBarChart(dataPoints: [String], values: [Double])
    {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count
        {
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

@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter
{
    var names = [String]()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return names[Int(value)]
    }
    
    public func setValues(values: [String])
    {
        self.names = values
    }
}

@objc(ChartAxisLineIntFormatter)
public class ChartAxisLineIntFormatter: NSObject, IAxisValueFormatter
{
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return "\(Int(value)) ★"
    }
}

//@objc(ChartXAxisLineDateFormatter)
//public class ChartXAxisLineDateFormatter: NSObject, IAxisValueFormatter
//{
//    public func stringForValue(_ value: String, axis: AxisBase?) -> String
//    {
//        return value
//    }
//}


class BarChartIntFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if value == 0 {
            return ""
        }
        if value >= 1 {
            let correctValue = Int(value)
            return String(correctValue)
        } else {
            return String(format: "%.1f", value)
        }
    }
}
