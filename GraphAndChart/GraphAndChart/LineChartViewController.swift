//
//  LineChartViewController.swift
//  GraphAndChart
//
//  Created by limefriends on 2021/05/06.
//

import UIKit
import Charts

class LineChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet var chartView: LineChartView!
    
    var options: [Option]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Multiple Lines Chart"
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]

        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false

        chartView.leftAxis.enabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        
        chartView.drawBordersEnabled = false
        chartView.setScaleEnabled(true)

        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
//        chartView.legend = l
        
        setDataCount(20, range: 200)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let colors = ChartColorTemplates.vordiplom()[0...2]
        
        let block: (Int) -> ChartDataEntry = { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(range) + 3)
            return ChartDataEntry(x: Double(i), y: val)
        }
        let dataSets = (0..<3).map { i -> LineChartDataSet in
            let yVals = (0..<count).map(block)
            let set = LineChartDataSet(entries: yVals, label: "DataSet \(i)")
            set.lineWidth = 2.5
            set.circleRadius = 4
            set.circleHoleRadius = 2
            let color = colors[i % colors.count]
            set.setColor(color)
            set.setCircleColor(color)
            
            return set
        }
        
        dataSets[0].lineDashLengths = [5, 5]
        dataSets[0].colors = ChartColorTemplates.vordiplom()
        dataSets[0].circleColors = ChartColorTemplates.vordiplom()
        
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7, weight: .light))
        chartView.data = data
    }
}
