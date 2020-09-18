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

class AddTaskViewController: UIViewController {
    
    var indexRow: Int?
    var mode: taskmode = .create
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        
        [txtTitle, txtDate].forEach({ $0.addTarget(self, action: #selector(requiredTextChanged), for: .editingChanged) })
        [txtDate, txtTime].forEach({ $0.addTarget(self, action: #selector(dateTextTouched), for: .touchDown) })
    }
    
    @objc func dateTextTouched(_ textField: UITextField) {
        if textField == txtDate {
            datePicker.datePickerMode = .date
        } else {
            datePicker.datePickerMode = .time
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 모드에 따라 다르게 표시
        if mode == .edit {
            self.title = "Edit Task"
            btnSave.isEnabled = true
            // 데이터 채우기
            if let row = indexRow {
                txtTitle.text = todoList[row].title
                txtDescription.text = todoList[row].description
                txtDate.text = todoList[row].date
                txtTime.text = todoList[row].time
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
            let taskTitle = txtTitle.text, !taskTitle.isEmpty,
            let taskDate = txtDate.text, !taskDate.isEmpty
        else {
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
        let date = txtDate.text!
        let time = txtTime.text
        let description = txtDescription.text
        
        if let row = indexRow {
            todoList[row].title = title
            todoList[row].date = date
            todoList[row].time = time
            todoList[row].description = description
        } else {
            let todoObject = Todo(title: title, date: date, time: time, description: description, completed: false)
            todoList.append(todoObject)
        }
        
        // 리스트 화면으로 돌아가기
        self.navigationController?.popViewController(animated: true)
    }
    
    /* 날짜 형식 문자열 */
    func getDatePickerDateValue() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
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
