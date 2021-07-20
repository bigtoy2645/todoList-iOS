//
//  AddTodoViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/09.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import Foundation

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
    var dateFormatter = DateFormatter()
    
    var delegate: SendDataDelegate?
    var editTask: Todo?
    var indexPath: IndexPath?
    var currentDate: Date?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DatePicker 생성
        datePicker.preferredDatePickerStyle = .wheels
        addDatePicker(textField: txtDate, useTrash: false)
        addDatePicker(textField: txtTime, useTrash: true)
        
        // 선택된 날짜를 default로 설정
        datePicker.date = currentDate ?? Date()
        
        // callback 추가
        txtTitle.addTarget(self, action: #selector(requiredTextChanged), for: .editingChanged)
        [txtDate, txtTime].forEach({ $0.addTarget(self, action: #selector(dateTextTouched), for: .touchDown) })
        segctrlTime.addTarget(self, action: #selector(timeToDoChanged(_:)), for: .valueChanged)
        
        // Title Focus
        txtTitle.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 모드에 따라 다르게 표시
        if let task = editTask {
            self.title = "Edit Task"
            btnSave.isEnabled = true
            
            // Scheduled / Anytime
            if task.date != nil, task.date != "" {
                segctrlTime.selectedSegmentIndex = 0
            } else {
                segctrlTime.selectedSegmentIndex = 1
            }
            timeToDoChanged(segctrlTime)
            
            // 데이터 채우기
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
    
    // MARK: - Get Date/Time
    
    /* 날짜 형식 문자열 */
    func getDatePickerDateValue() -> String {
        return dateFormatter.dateToString(datePicker.date)
    }
    
    /* 시간 형식 문자열 */
    func getDatePickerTimeValue() -> String {
        return dateFormatter.timeToString(datePicker.date)
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
    
    // MARK: - Actions
    
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
        let date = txtDate.text
        let time = txtTime.text
        let description = txtDescription.text
        let todoObject = Todo(title: title, date: date, time: time, description: description, isCompleted: false)
        
        // DailyTasks 화면으로 돌아가기
        delegate?.sendData(oldTask: editTask, newTask: todoObject, indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    /* Scheduled/Anytime 선택 */
    @objc func timeToDoChanged(_ segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
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
        if txtTime.isFirstResponder {
            txtTime.text = ""
        } else {}
        
        self.view.endEditing(true)
    }
    
}
