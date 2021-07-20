//
//  DateFormatter+Extensions.swift
//  todoList
//
//  Created by yurim on 2020/12/18.
//  Copyright © 2020 yurim. All rights reserved.
//

import Foundation

extension DateFormatter {
    func dateToString(_ date: Date) -> String {
        self.dateFormat = "yyyy-MM-dd"
        return string(from: date)
    }
    
    func stringToDate(_ dateString: String) -> Date? {
        self.dateFormat = "yyyy-MM-dd"
        return date(from: dateString)
    }
    
    func timeToString(_ time: Date) -> String {
        self.dateStyle = .none
        self.timeStyle = .short
        return string(from: time)
    }
}
