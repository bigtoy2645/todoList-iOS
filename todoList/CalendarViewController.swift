//
//  CalendarViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/18.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnScope: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전에 선택한 날짜 표시
        dateFormatter.dateFormat = defaultDateFormat
        let date: Date = dateFormatter.date(from: selectedDate) ?? Date()
        calendar.select(date)
        
        calendarHeightConstraint.constant = self.view.bounds.height / 2
    }
    
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = dateFormatter.string(from: date)
        tblTasks.reloadData()
    }
    
    /* cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoScheduled[selectedDate]?.count ?? 0
    }
    
    /* section 개수 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /* section 타이틀 */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate
    }
    
    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath)
        
        if let task = todoScheduled[selectedDate] {
            // Title 설정
            cell.textLabel?.text = task[indexPath.row].title
            // Image 설정
            if task[indexPath.row].isCompleted == true {
                cell.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
            } else {
                cell.imageView?.image = UIImage(systemName: "circle")
            }
        }
        
        return cell
    }
    
    /* Done 버튼 클릭 */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
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
    
    /* Week/Month Scope 변경 시 달력 높이 변경 */
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}
