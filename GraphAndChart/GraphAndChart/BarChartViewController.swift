//
//  BarChartViewController.swift
//  GraphAndChart
//
//  Created by limefriends on 2021/05/06.
//

import UIKit
import Charts

class BarChartViewController: UIViewController {
    @IBOutlet weak var barChartView: BarChartView!
    
    var months: [String]!
    var unitsSold: [Double]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        // 선택 안되게
//        chartDataSet.highlightEnabled = false
        // 줌 안되게
        barChartView.doubleTapToZoomEnabled = false
        
        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChartView.xAxis.setLabelCount(months.count, force: false)
        
        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false
        
        // 애니메이션
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeOutSine)
        
        // 리미티드 라인
        let line = ChartLimitLine(limit: 10.0, label: "리미티드 라인")
        barChartView.leftAxis.addLimitLine(line)
        
        // 맥시멈
        barChartView.leftAxis.axisMaximum = 30
        // 미니멈
        barChartView.leftAxis.axisMinimum = -10
        
        // 배경색
        // barChartView.backgroundColor = .green
        
        setChart(dataPoints: months, values: unitsSold)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "테스트")

        // 차트 컬러
        chartDataSet.colors = [.purple]

        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
}
