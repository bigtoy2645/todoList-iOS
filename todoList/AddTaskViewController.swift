//
//  AddTodoViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/09.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import Foundation

enum taskmode {
    case create
    case edit
}

let defaultDateFormat = "YYYY-MM-dd"

class AddTaskViewController: UIViewController {
    
    var indexPath: IndexPath?
    var mode: taskmode = .create
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DatePicker 생성
        createDatePicker()
        
        // callback 추가
        txtTitle.addTarget(self, action: #selector(requiredTextChanged), for: .editingChanged)
        [txtDate, txtTime].forEach({ $0.addTarget(self, action: #selector(dateTextTouched), for: .touchDown) })
        
        // Title Focus
        txtTitle.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 모드에 따라 다르게 표시
        if mode == .edit {
            self.title = "Edit Task"
            btnSave.isEnabled = true
            // 데이터 채우기
            if let index = indexPath {
                let task = getTask(indexPath: index)
                txtTitle.text = task.title
                txtDescription.text = task.description
                txtDate.text = task.date
                txtTime.text = task.time
            }
        } else {
            self.title = "Create Task"
            btnSave.isEnabled = false
            txtDate.text = getDatePickerDateValue()
        }
    }
    
    /* 필수 항목 입력 시 저장 버튼 활성화 */
    @objc func requiredTextChanged(_ textField: UITextField) {
        guard
            let taskTitle = txtTitle.text, !taskTitle.isEmpty
            else {
                btnSave.isEnabled = false
                return
        }
        btnSave.isEnabled = true
    }
    
    /* 날짜/시간 선택 시 Mode 변경 */
    @objc func dateTextTouched(_ textField: UITextField) {
        if textField == txtDate {
            datePicker.datePickerMode = .date
        } else {
            datePicker.datePickerMode = .time
        }
    }
    
    /* 할 일 추가/수정 */
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
        let title = txtTitle.text!
        let date = txtDate.text ?? ""
        let time = txtTime.text
        let description = txtDescription.text
        
        // TODO - 리팩토링
        
        if let index = indexPath {
            // Task 수정
            if index.section == 0 {
                if date != "" {
                    if var scheduledTask = todoScheduled[date] {
                        scheduledTask[index.row].title = title
                        scheduledTask[index.row].date = date
                        scheduledTask[index.row].time = time
                        scheduledTask[index.row].description = description
                        todoScheduled[date] = scheduledTask
                    } else {
                        todoScheduled.updateValue([Todo(title: title, date: date, time: time, description: description, completed: false)], forKey: date)
                    }
                } else {
                    // Scheduled -> Anytime
                    todoScheduled[date]?.remove(at: index.row)
                    let todoObject = Todo(title: title, date: date, time: time, description: description, completed: false)
                    todoAnytime.append(todoObject)
                }
            } else {
                // Anytime
                if date == "" {
                    todoAnytime[index.row].title = title
                    todoAnytime[index.row].date = date
                    todoAnytime[index.row].time = time
                    todoAnytime[index.row].description = description
                } else {
                    // Anytime -> Scheduled
                    todoAnytime.remove(at: index.row)
                    let todoObject = Todo(title: title, date: date, time: time, description: description, completed: false)
                    if var task = todoScheduled[date] {
                        task.append(todoObject)
                        todoScheduled[date] = task
                    } else {
                        todoScheduled.updateValue([todoObject], forKey: date)
                    }
                }
            }
        } else {
            // Task 추가
            let todoObject = Todo(title: title, date: date, time: time, description: description, completed: false)
            if date != "" {
                if var task = todoScheduled[date] {
                    task.append(todoObject)
                    todoScheduled[date] = task
                } else {
                    todoScheduled.updateValue([todoObject], forKey: date)
                }
            } else {
                todoAnytime.append(todoObject)
            }
        }
        
        // 리스트 화면으로 돌아가기
        self.navigationController?.popViewController(animated: true)
    }
    
    /* 날짜 형식 문자열 */
    func getDatePickerDateValue() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = defaultDateFormat
        
        return formatter.string(from: datePicker.date)
    }
    
    /* 시간 형식 문자열 */
    func getDatePickerTimeValue() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter.string(from: datePicker.date)
    }
    
    /* DatePicker 생성 */
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnDone], animated: true)
        
        txtDate.inputView = datePicker
        txtTime.inputView = datePicker
        
        txtDate.inputAccessoryView = toolbar
        txtTime.inputAccessoryView = toolbar
    }
    
    /* 날짜/시간 선택 완료 */
    @objc func donePressed() {
        // TextField에 따라 다르게 표시
        if txtDate.isFirstResponder {
            txtDate.text = getDatePickerDateValue()
        } else if txtTime.isFirstResponder {
            txtTime.text = getDatePickerTimeValue()
        } else {}
        
        self.view.endEditing(true)
    }
}
