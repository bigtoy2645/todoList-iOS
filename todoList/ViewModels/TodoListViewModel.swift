//
//  TodoListViewModel.swift
//  todoList
//
//  Created by yurim on 2021/07/29.
//  Copyright © 2021 yurim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum Section: String {
    case scheduled = "Scheduled"
    case anytime = "Anytime"
}

class TodoListViewModel: NSObject {
    var todoScheduled = BehaviorRelay<[String : [Todo]]>(value: [:])    // e.g. "2020-09-23" : [Todo]
    var todoAnytime = BehaviorRelay<[Todo]>(value: [])
    var selectedDate = BehaviorRelay<Date>(value: Date())
    
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        // 데이터 불러오기
        if nil != UserDefaults.standard.value(forKey: DefaultsKey.isFirstLaunch) {
            loadAllData()   // 이전 데이터 불러오기
        } else {
            loadFirstData() // 최초 설치 시 데이터 불러오기
        }
        
        // 데이터 갱신 시 저장
        _ = todoScheduled
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Section.scheduled.rawValue)
            })
            .disposed(by: disposeBag)
        
        _ = todoAnytime
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Section.anytime.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Processing
    
    /* 데이터 저장 */
    func saveData<T: Encodable>(data: T, key: String) {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        if let jsonData = try? encoder.encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: key)
            }
        }
        // 동기화
        userDefaults.synchronize()
    }
    
    /* 데이터 불러오기 */
    func loadAllData() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // Scheduled
        if let jsonString = userDefaults.value(forKey: Section.scheduled.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let scheduledData = try? decoder.decode([String : [Todo]].self, from: jsonData) {
                todoScheduled.accept(scheduledData)
            }
        }
        
        // Anytime
        if let jsonString = userDefaults.value(forKey: Section.anytime.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let anytimeData = try? decoder.decode([Todo].self, from: jsonData) {
                todoAnytime.accept(anytimeData)
            }
        }
    }
    
    /* 초기 데이터 불러오기 */
    func loadFirstData() {
        let userDefaults = UserDefaults.standard
        let date = selectedDate.value.toString()
        
        userDefaults.setValue(false, forKey: DefaultsKey.isFirstLaunch)
        self.todoScheduled.accept([date : [Todo(title: "Create new task",
                                                date: date,
                                                time: "8:00 PM",
                                                description: "Click the plus button to add a scheduled task.")]])
        self.todoAnytime.accept([Todo(title: "Update your task", date: "", time: "", description: "This task has not yet been scheduled.")])
        userDefaults.synchronize()
    }
}
