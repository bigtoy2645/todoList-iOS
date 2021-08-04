//
//  CalendarViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/18.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnScope: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Properties
    
    var delegate: SendDataDelegate?
    var todoScheduled: [String : [Todo]] = [:]
    var selectedDate = Date()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTasks.rowHeight = UITableView.automaticDimension
        
        // 이전에 선택한 날짜 표시
        calendar.select(selectedDate)
        
        // 달력 높이를 전체 뷰의 1/2로 초기화
        calendarHeightConstraint.constant = self.view.bounds.height / 2
        // 주말 Title 색상 변경
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = calendar.calendarWeekdayView.weekdayLabels[0].textColor
    }
    
    // MARK: - Tableview Delegate
    
    /* cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoScheduled[selectedDate.toString()]?.count ?? 0
    }
    
    /* section 타이틀 */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate.toString()
    }
    
    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
        guard let task = todoScheduled[selectedDate.toString()]?[indexPath.row] else { return cell }
        
        // cell 설정
        cell.bind(task: task)
        
        // 체크박스 선택 시 작업 추가
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Actions
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        // Complete 값 변경
        todoScheduled[selectedDate.toString()]?[indexPath.row].isCompleted.toggle()
        
        tblTasks.reloadData()
        calendar.reloadData()
    }
    
    /* Done 버튼 클릭 */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // DailyTasks 화면으로 돌아가기
        delegate?.sendData(scheduledTasks: todoScheduled, newDate: selectedDate)
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

// MARK: - Calendar Delegate

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tblTasks.reloadData()
    }
    
    /* Week/Month Scope 변경 시 달력 높이 변경 */
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    /* 달력 날짜에 이벤트 표시 */
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let tasks = todoScheduled[date.toString()], tasks.count > 0 { return 1 }
        return 0
    }
    
    /* 이벤트 색상 */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
            // 작업 미완료 시 빨간색으로 이벤트 표시
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            // 작업 완료 시 회색으로 이벤트 표시
            return [UIColor.systemGray2]
        }
        return nil
    }
    
    /* 날짜 선택 시 이벤트 색상 */
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
            // 작업 미완료 시 빨간색으로 이벤트 표시
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            // 작업 완료 시 회색으로 이벤트 표시
            return [UIColor.systemGray2]
        }
        return nil
    }
}
