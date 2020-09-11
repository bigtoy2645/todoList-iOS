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
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createDatePicker()
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
        let todoObject = Todo(title: txtTitle.text!, description: description, completed: false, date: date)
        todoList.append(todoObject)
        
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
