//
//  CalendarViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/18.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnScope: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Properties
    
    var dateFormatter = DateFormatter()
    
    var delegate: SendDataDelegate?
    var todoScheduled: [String : [Todo]] = [:]
    var currentDate: Date?
    var newDate: String = ""
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전에 선택한 날짜 표시
        let date = currentDate ?? Date()
        calendar.select(date)
        newDate = dateFormatter.dateToString(date)
        
        // 달력 높이를 전체 뷰의 1/2로 초기화
        calendarHeightConstraint.constant = self.view.bounds.height / 2
        // 주말 Title 색상 변경
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = calendar.calendarWeekdayView.weekdayLabels[0].textColor
    }
    
    // MARK: - Tableview Delegate
    
    /* cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoScheduled[newDate]?.count ?? 0
    }
    
    /* cell 높이 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let task = todoScheduled[newDate], task[indexPath.row].description == "", task[indexPath.row].time == "" {
            return 45
        }
        return 65
    }
    
    /* section 개수 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /* section 타이틀 */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return newDate
    }
    
    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! TodoCell
        guard let task = todoScheduled[newDate]?[indexPath.row] else { return cell }
        
        // cell 설정
        cell.bind(task: task)
        
        // 체크박스 선택 시 작업 추가
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Calendar Delegate
    
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        newDate = dateFormatter.dateToString(date)
        tblTasks.reloadData()
    }
    
    /* Week/Month Scope 변경 시 달력 높이 변경 */
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    /* 달력 날짜에 이벤트 표시 */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = dateFormatter.dateToString(date)
        if let tasks = todoScheduled[dateString], tasks.count > 0 { return 1 }
        return 0
    }
    
    /* 이벤트 색상 */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let dateString = dateFormatter.dateToString(date)
        if let tasks = todoScheduled[dateString] {
            // 작업 미완료 시 빨간색으로 이벤트 표시
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            // 작업 완료 시 회색으로 이벤트 표시
            return [UIColor.systemGray2]
        }
        return nil
    }
    
    /* 날짜 선택 시 이벤트 색상 */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let dateString = dateFormatter.dateToString(date)
        if let tasks = todoScheduled[dateString] {
            // 작업 미완료 시 빨간색으로 이벤트 표시
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            // 작업 완료 시 회색으로 이벤트 표시
            return [UIColor.systemGray2]
        }
        return nil
    }
    
    // MARK: - Actions
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        // Complete 값 변경
        todoScheduled[newDate]?[indexPath.row].isCompleted.toggle()
        
        tblTasks.reloadData()
        calendar.reloadData()
    }
    
    /* Done 버튼 클릭 */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // DailyTasks 화면으로 돌아가기
        delegate?.sendData(scheduledTasks: todoScheduled, newDate: newDate)
        dismiss(animated: true, completion: nil)
    }
    
    /* Week/Month Scope 변경 */
    @IBAction func changeScopeButtonPressed(_ sender: UIBarButtonItem) {
        if calendar.scope == .month {
            calendar.scope = .week
            btnScope.title = "Month"
        } else {
            calendar.scope = .month
            btnScope.title = "Week"
        }
    }
}
