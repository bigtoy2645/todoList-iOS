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
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var lblViewTitle: UILabel!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 모드에 따라 다르게 표시
        if mode == .edit {
            lblViewTitle.text = "Edit Task"
            // 데이터 채우기
            if let row = indexRow {
                txtTitle.text = todoList[row].title
                txtDescription.text = todoList[row].description
                txtDate.text = todoList[row].date
            }
        } else {
            lblViewTitle.text = "Create Task"
        }
    }
    
    /* 할 일 추가 */
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        if let title = txtTitle.text, title.isEmpty {
            let alert = UIAlertController(title: "Please enter a title.", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        let description = txtDescription.text
        let date = txtDate.text
        
        if let row = indexRow {
            todoList[row].title = txtTitle.text!
            todoList[row].description = description
            todoList[row].date = date
        } else {
            let todoObject = Todo(title: txtTitle.text!, description: description, completed: false, date: date)
            todoList.append(todoObject)
        }
        
        // 리스트 화면으로 돌아가기
        dismiss(animated: true, completion: nil)
    }
    
    /* 나가기 버튼 클릭 */
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([btnDone], animated: true)
        txtDate.inputAccessoryView = toolbar
        txtDate.inputView = datePicker
        
        datePicker.datePickerMode = .date
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        txtDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
}
