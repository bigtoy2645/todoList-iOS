//
//  TodoViewModel.swift
//  todoList
//
//  Created by yurim on 2021/07/20.
//  Copyright © 2021 yurim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TodoViewModel: NSObject {
    var task = BehaviorRelay<Todo>(value: Todo.empty)
    
    init(_ task: Todo) {
        BehaviorSubject<Todo>.just(task)
            .take(1)
            .subscribe(onNext: self.task.accept(_:))
    }
    
    lazy var checkImageString: Observable<String> = self.task.map { return $0.isCompleted ? "checkmark.circle.fill" : "circle" }
    lazy var descriptionString: Observable<String> = self.task.map {
        if $0.time == "" {
            return "\($0.description ?? "")"
        } else {
            return "\($0.time ?? "") \($0.description ?? "")"
        }
    }
}
