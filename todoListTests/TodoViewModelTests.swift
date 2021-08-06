//
//  todoListTests.swift
//  todoListTests
//
//  Created by yurim on 2021/08/06.
//  Copyright © 2021 yurim. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

class TodoViewModelTests: XCTestCase {

    private var vm: TodoViewModel!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        vm = TodoViewModel(Todo.empty)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        vm = nil
    }
    
    func test_checkImageString() {
        let image = scheduler.createObserver(String.self)
        
        vm.checkImageString
            .bind(to: image)
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(210, Todo(title: "", date: "", time: "", description: "", isCompleted: true)),
            .next(220, Todo(title: "", date: "", time: "", description: "", isCompleted: false)),
            .next(230, Todo(title: "", date: "", time: "", description: "", isCompleted: true))
        ])
        .bind(to: vm.task)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(image.events, [
            .next(0, "circle"),
            .next(210, "checkmark.circle.fill"),
            .next(220, "circle"),
            .next(230, "checkmark.circle.fill")
            ])
    }
}
