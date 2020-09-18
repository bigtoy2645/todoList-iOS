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
    var date: String
    var time: String?
    var description: String?
    var completed: Bool
}

struct DailyTask {
    var date: Date
    var scheduled: [Todo]
    var anytime: [Todo]
}
