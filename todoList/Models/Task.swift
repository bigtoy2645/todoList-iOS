//
//  Task.swift
//  todoList
//
//  Created by yurim on 2021/08/01.
//  Copyright © 2021 yurim. All rights reserved.
//

import Foundation
import RxDataSources

struct Task {
    var date: String
    var items: [Todo]
}

extension Task: SectionModelType {
    typealias Item = Todo
    
    init(original: Task, items: [Item]) {
        self = original
        self.items = items
    }
}
