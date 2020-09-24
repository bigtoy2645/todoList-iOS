//
//  Todo.swift
//  todoList
//
//  Created by yurim on 2020/09/08.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

struct Todo {
    var title: String
    var date: String?
    var time: String?
    var description: String?
    var isCompleted: Bool
    
    /* Edit Task 값 Update */
    mutating func updateValue(title: String, date: String?, time: String?, description: String?) {
        self.title = title
        self.date = date
        self.time = time
        self.description = description
    }
}
