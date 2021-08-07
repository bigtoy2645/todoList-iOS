//
//  TodoListViewModelTests.swift
//  todoListTests
//
//  Created by yurim on 2021/08/06.
//  Copyright © 2021 yurim. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

class TodoListViewModelTests: XCTestCase {
    
    private var vm: TodoListViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        vm = TodoListViewModel()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_changeComplete() {
        vm.todoScheduled.accept(["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                                 Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                                 "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]])
        vm.selectedDate.accept("2021-08-10".toDate() ?? Date())
        
        let completeTasks = scheduler.createObserver([String: [Todo]].self)
        
        vm.todoScheduled
            .bind(to: completeTasks)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, 0),
            .next(220, 1)
        ])
        .subscribe(onNext: { [weak self] in self?.vm.changeComplete(section: .scheduled, row: $0) })
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(completeTasks.events, [
            .next(0, ["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                      Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                      "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(210, ["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                        "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(220, ["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true)],
                        "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]])
        ])
    }
    
    func test_insertTask() {
        vm.todoScheduled.accept(["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                                 Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                                 "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]])
        vm.selectedDate.accept("2021-08-11".toDate() ?? Date())
        
        let insertedTasks = scheduler.createObserver([String: [Todo]].self)
        
        vm.todoScheduled
            .bind(to: insertedTasks)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, "new1"),
            .next(220, "new2")
        ])
        .subscribe(onNext: { [weak self] in
            self?.vm.insert(task: Todo(title: $0, date: nil, time: nil, description: nil, isCompleted: true),
                            section: .scheduled,
                            row: 0,
                            date: "2021-08-10")
        })
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(insertedTasks.events, [
            .next(0, ["2021-08-10" : [Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                      Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                      "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(210, ["2021-08-10" : [Todo(title: "new1", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                        "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(220, ["2021-08-10" : [Todo(title: "new2", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                        Todo(title: "new1", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                        Todo(title: "", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                        "2021-08-11" : [Todo(title: "", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]])
        ])
    }
    
    func test_removeTask() {
        vm.todoScheduled.accept(["2021-08-10" : [Todo(title: "task1", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                                 Todo(title: "task2", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                                 "2021-08-11" : [Todo(title: "task3", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]])
        vm.selectedDate.accept("2021-08-11".toDate() ?? Date())
        
        let removedTasks = scheduler.createObserver([String: [Todo]].self)
        
        vm.todoScheduled
            .bind(to: removedTasks)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, "2021-08-10"),
            .next(220, "2021-08-11")
        ])
        .subscribe(onNext: { [weak self] in
            _ = self?.vm.remove(section: .scheduled, row: 0, date: $0)
        })
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(removedTasks.events, [
            .next(0, ["2021-08-10" : [Todo(title: "task1", date: "2021-08-10", time: nil, description: nil, isCompleted: true),
                                      Todo(title: "task2", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                      "2021-08-11" : [Todo(title: "task3", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(210, ["2021-08-10" : [Todo(title: "task2", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                        "2021-08-11" : [Todo(title: "task3", date: "2021-08-11", time: nil, description: nil, isCompleted: false)]]),
            .next(220, ["2021-08-10" : [Todo(title: "task2", date: "2021-08-10", time: nil, description: nil, isCompleted: false)],
                        "2021-08-11" : []])
        ])
    }
}
