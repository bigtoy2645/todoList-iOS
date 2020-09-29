//
//  Todo.swift
//  todoList
//
//  Created by yurim on 2020/09/08.
//  Copyright © 2020 yurim. All rights reserved.
//

import Foundation

struct Todo : Codable {
    var title: String
    var date: String?
    var time: String?
    var description: String?
    var isCompleted: Bool
    
    /* Edit Task 값 Update */
    mutating func updateValue(task: Todo) {
        self.title = task.title
        self.date = task.date
        self.time = task.time
        self.description = task.description
    }
}
