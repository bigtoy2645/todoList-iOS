//
//  AddTodoViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/09.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var viewTaskDetails: UIStackView!
    @IBOutlet weak var segctrlTime: UISegmentedControl!
    
    // MARK: - Instance Properties
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    
    var delegate: SendDataDelegate?
    var editTask: Todo?
    var indexPath: IndexPath?
    var currentDate: Date?
    
    var disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Binding
        setupBindings()
        
        // DatePicker 생성
        addDatePicker()
        addTimePicker()
        
        // Title Focus
        txtTitle.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let task = editTask else {
            self.title = "Create Task"
            btnSave.isEnabled = false
            return
        }
        
        // 모드에 따라 다르게 표시
        self.title = "Edit Task"
        btnSave.isEnabled = true
        
        // Scheduled / Anytime
        if let date = task.date, !date.isEmpty {
            segctrlTime.selectedSegmentIndex = 0
        } else {
            segctrlTime.selectedSegmentIndex = 1
        }
        segctrlTime.sendActions(for: .valueChanged)
        
        // 데이터 채우기
        txtTitle.text = task.title
        txtDescription.text = task.description
        txtDate.text = task.date
        txtTime.text = task.time
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        txtTitle.rx.text
            .observe(on: MainScheduler.instance)
            .map {
                guard let title = $0, !title.isEmpty else { return false }
                return true
            }
            .bind(to: btnSave.rx.isEnabled)
            .disposed(by: disposeBag)
        
        segctrlTime.rx.selectedSegmentIndex
            .observe(on: MainScheduler.instance)
            .map { return ($0 == 0 ? false : true) }
            .subscribe(onNext: {
                self.viewTaskDetails.subviews[0].isHidden = $0
                self.viewTaskDetails.subviews[1].isHidden = $0
            })
            .disposed(by: disposeBag)
        
        datePicker.rx.date
            .observe(on: MainScheduler.instance)
            .map { self.dateFormatter.dateToString($0) }
            .bind(to: txtDate.rx.text)
            .disposed(by: disposeBag)
        
        timePicker.rx.date
            .observe(on: MainScheduler.instance)
            .map { self.dateFormatter.timeToString($0) }
            .bind(to: txtTime.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - DatePicker
    
    func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnSpace, btnDone], animated: true)
        
        txtDate.inputView = datePicker
        txtDate.inputAccessoryView = toolbar
        
        // 선택된 날짜를 default로 설정
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.date = currentDate ?? Date()
    }
    
    func addTimePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnTrash, btnSpace, btnDone], animated: true)
        
        txtTime.inputView = timePicker
        txtTime.inputAccessoryView = toolbar
        
        // 선택된 날짜를 default로 설정
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.date = currentDate ?? Date()
    }
    
    // MARK: - Actions
    
    /* 할 일 추가/수정 */
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
        let todoObject = Todo(title: txtTitle.text!,
                              date: txtDate.text,
                              time: txtTime.text,
                              description: txtDescription.text)
        
        // DailyTasks 화면으로 돌아가기
        delegate?.sendData(oldTask: editTask, newTask: todoObject, indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    /* 날짜/시간 선택 완료 */
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
    /* 시간 제거 */
    @objc func trashPressed() {
        txtTime.text = ""
        self.view.endEditing(true)
    }
    
}
