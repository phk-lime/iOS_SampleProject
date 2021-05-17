//
//  ViewController.swift
//  Calendar
//
//  Created by limefriends on 2021/05/07.
//

import UIKit
import FSCalendar

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(moveToToday))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "달력 토글", style: .plain, target: self, action: #selector(toggleClicked))
    
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.backgroundColor = UIColor(red: 241/255, green: 249/255, blue: 255/255, alpha: 1)
        calendar.appearance.selectionColor = .red
        calendar.appearance.todayColor = .blue
        
        // 날짜 다중 선택
        calendar.allowsMultipleSelection = false
        // 길게 눌러서 여러 날짜 선택
        calendar.swipeToChooseGesture.isEnabled = true
                
        // 달력 스크롤 여부
        calendar.scrollEnabled = true
        // 달력 스크롤 방향
        calendar.scrollDirection = .horizontal
        
        // 선택 영역 borderRadius
        //calendar.appearance.borderRadius = 0 // 사각형
        
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.subtitleSelectionColor = .black
        
        // 제스쳐로 달력 높이 줄이기
//        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
//        self.calendar.addGestureRecognizer(scopeGesture)
        
        // 제스쳐로 달력 높이 줄이기 with 테이블 뷰
        self.view.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .month
    }
    
    @objc func moveToToday() {
        self.calendar.setCurrentPage(Date(), animated: true)
        self.calendar.select(Date())
    }
    
    @objc func toggleClicked() {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        } else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    // MARK:- UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            default:
                break
            }
        }
        return shouldBegin
    }
}

extension ViewController: FSCalendarDelegate, FSCalendarDataSource {
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("--->선택한 날짜:", dateFormatter.string(from: date))
        // 선택한 날짜에 따라 달력 이동
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    // 날짜 선택 해제 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("--->선택해제 날짜:", dateFormatter.string(from: date))
    }
    
    // 날짜 타이틀 변경
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        switch dateFormatter.string(from: date) {
        case "2021-05-08":
            return "D-day"
        default:
            return nil
        }
    }
    
    // 날짜 서브 타이틀
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        switch dateFormatter.string(from: date) {
        case dateFormatter.string(from: Date()):
            return "오늘"
        case "2021-05-05":
            return "어린이날"
        case "2021-05-10":
            return "월급"
        case "2021-05-19":
            return "석가탄신일"
        default:
            return nil
        }
    }
    
    // 날짜별 선택 컬러 설정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        switch dateFormatter.string(from: date) {
        case "2021-05-05":
            return .green
        case "2021-05-10":
            return .blue
        case "2021-05-19":
            return .red
        default:
            return appearance.selectionColor
        }
    }
    
    // 날짜 선택 개수 설정
//    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        if calendar.selectedDates.count > 3 {
//            return false
//        } else {
//            return true
//        }
//    }
    
    // 선택 해제 설정
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //return false // 선택해제 불가능
        return true // 선택해제 가능
    }
    
    // 달력 높이 변경 delegate
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "👍 Hello, World"
        return cell
    }
}
