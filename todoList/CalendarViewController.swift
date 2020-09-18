//
//  CalendarViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/18.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 날짜 선택 제거
        calendar.today = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 이전에 선택한 날짜 표시
        calendar.select(selectedDate)
    }
    
    /* 날짜 선택 */
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        dismiss(animated: true, completion: nil)
    }

}
