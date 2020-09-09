//
//  AddTodoViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/09.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import Foundation

class AddTodoViewController: UIViewController {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /* 할 일 추가 */
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let title = txtTitle.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Please enter a title.", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        let description = txtDescription.text
        let todoObject = Todo(title: title, description: description, completed: false)
        todoList.append(todoObject)
        
        // 리스트 화면으로 돌아가기
        dismiss(animated: true, completion: nil)
    }
    
    /* 나가기 버튼 클릭 */
    @IBAction func exitButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
