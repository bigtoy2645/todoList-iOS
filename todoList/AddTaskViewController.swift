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
    @IBOutlet weak var viewTaskDetails: UIStackView!
    
    let datePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DatePicker 생성
        addDatePicker(textField: txtDate, useTrash: false)
        addDatePicker(textField: txtTime, useTrash: true)
        
        // 선택된 날짜를 default로 설정
        dateFormatter.dateFormat = defaultDateFormat
        datePicker.date = dateFormatter.date(from: selectedDate) ?? Date()
        
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
            guard let index = indexPath else { return }
            let task = getTask(indexPath: index)
            txtTitle.text = task.title
            txtDescription.text = task.description
            txtDate.text = task.date
            txtTime.text = task.time
        } else {
            self.title = "Create Task"
            btnSave.isEnabled = false
            
            txtDate.text = getDatePickerDateValue()
        }
    }
    
    /* 필수 항목 입력 시 저장 버튼 활성화 */
    @objc func requiredTextChanged(_ textField: UITextField) {
        guard let taskTitle = txtTitle.text, !taskTitle.isEmpty else {
            btnSave.isEnabled = false
            return
        }
        btnSave.isEnabled = true
    }
    
    /* 할 일 추가/수정 */
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
        let title = txtTitle.text!
        let date = txtDate.text ?? ""
        let time = txtTime.text
        let description = txtDescription.text
        let todoObject = Todo(title: title, date: date, time: time, description: description, isCompleted: false)
        
        if let index = indexPath {  // Task 수정
            if index.section == 0 {
                if date != "" {
                    if var scheduledTask = todoScheduled[date] {
                        scheduledTask[index.row].updateValue(title: title, date: date, time: time, description: description)
                        todoScheduled[date] = scheduledTask
                    } else {
                        todoScheduled.updateValue([todoObject], forKey: date)
                    }
                } else {
                    // Scheduled -> Anytime
                    todoScheduled[date]?.remove(at: index.row)
                    todoAnytime.append(todoObject)
                }
            } else {
                if date == "" {
                    todoAnytime[index.row].updateValue(title: title, date: date, time: time, description: description)
                } else {
                    // Anytime -> Scheduled
                    todoAnytime.remove(at: index.row)
                    if var task = todoScheduled[date] {
                        task.append(todoObject)
                        todoScheduled[date] = task
                    } else {
                        todoScheduled.updateValue([todoObject], forKey: date)
                    }
                }
            }
        } else {                    // Task 추가
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
    
    /* Scheduled/Anytime 선택 */
    @IBAction func TimeToDoChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            txtDate.text = getDatePickerDateValue()
            viewTaskDetails.subviews[0].isHidden = false
            viewTaskDetails.subviews[1].isHidden = false
        } else {
            txtDate.text = ""
            txtTime.text = ""
            viewTaskDetails.subviews[0].isHidden = true
            viewTaskDetails.subviews[1].isHidden = true
        }
    }
    
    // MARK: 날짜/시간 API
    
    /* 날짜 형식 문자열 */
    func getDatePickerDateValue() -> String {
        dateFormatter.dateFormat = defaultDateFormat
        
        return dateFormatter.string(from: datePicker.date)
    }
    
    /* 시간 형식 문자열 */
    func getDatePickerTimeValue() -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: datePicker.date)
    }
    
    /* DatePicker 생성 */
    func addDatePicker(textField: UITextField, useTrash: Bool) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        if useTrash == true {
            toolbar.setItems([btnTrash, btnSpace, btnDone], animated: true)
        } else {
            toolbar.setItems([btnSpace, btnDone], animated: true)
        }
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    /* 날짜/시간 선택 시 Mode 변경 */
    @objc func dateTextTouched(_ textField: UITextField) {
        if textField == txtDate {
            datePicker.datePickerMode = .date
        } else {
            datePicker.datePickerMode = .time
        }
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
    
    /* 날짜/시간 제거 */
    @objc func trashPressed() {
        if txtDate.isFirstResponder {
            txtDate.text = ""
        } else if txtTime.isFirstResponder {
            txtTime.text = ""
        } else {}
        
        self.view.endEditing(true)
    }
}
