//
//  PlayPracticeWalkthroughView.swift
//  Modacity
//
//  Created by BC Engineer on 11/6/18.
//  Copyright © 2018 crossover. All rights reserved.
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
    
    @IBOutlet weak var chartViewBarGraph: BarChartView!
    @IBOutlet weak var chartViewStarRatings: LineChartView!
    
    @IBOutlet weak var labelWeekDuration: UILabel!
    @IBOutlet weak var buttonPreviousWeek: UIButton!
    @IBOutlet weak var buttonNextWeek: UIButton!
    
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
        
        self.showValues()
    }
    
    func showValues() {
        
        let monday = self.date.weekDay(for: .mon)
        let sunday = self.date.addingTimeInterval(7 * 24 * 3600).weekDay(for: .sun)
        self.labelWeekDuration.text = "\(monday.toString(format: "MMM d yyyy")) - \(sunday.toString(format: "MMM d yyyy"))"
        
        if self.date.startOfDate().timeIntervalSince1970 == Date().startOfDate().timeIntervalSince1970 {
            self.buttonNextWeek.isHidden = true
        } else {
            self.buttonNextWeek.isHidden = false
        }
        
        setLineChart(values:[4,2,5,4, 3,4,2, 3, 5,1])
        setBarChart(dataPoints: ["MON", "TUE", "WED", "THR", "FRI", "SAT", "SUN"], values: [4,2,5,4, 3,4,2])
    }
    
    @IBAction func onPreviousWeek(_ sender: Any) {
        self.date = self.date.addingTimeInterval(-1 * 7 * 24 * 3600)
        self.showValues()
    }
    
    @IBAction func onNextWeek(_ sender: Any) {
        self.date = self.date.addingTimeInterval(7 * 24 * 3600)
        self.showValues()
    }
    
}


// MARK: - Show charts
extension StatisticsView {
    func setLineChart(values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
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
        
        chartViewStarRatings.xAxis.labelPosition = .bottom
        chartViewStarRatings.xAxis.drawGridLinesEnabled = false
        chartViewStarRatings.xAxis.drawAxisLineEnabled = true
        chartViewStarRatings.xAxis.drawLabelsEnabled = false
        
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
        
        chartViewStarRatings.animate(yAxisDuration: 1.5)
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

@objc(BarChartFormatter)
public class ChartAxisLineIntFormatter: NSObject, IAxisValueFormatter
{
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        return "\(Int(value)) ★"
    }
}


class BarChartIntFormatter: NSObject, IValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let correctValue = Int(value)
        return String(correctValue)
    }
}
