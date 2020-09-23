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
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 날짜 선택 제거
        calendar.today = nil
        
        // 이전에 선택한 날짜 표시
        dateFormatter.dateFormat = defaultDateFormat
        let date: Date = dateFormatter.date(from: selectedDate) ?? Date()
        calendar.select(date)
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
        
        // Title 설정
        if let task = todoScheduled[selectedDate] {
            cell.textLabel?.text = task[indexPath.row].title
        }
        
        return cell
    }
    
    // TODO - dismiss
    //    dismiss(animated: true, completion: nil)
}
