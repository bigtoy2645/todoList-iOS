//
//  ViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/07.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

var todoList: [Todo] = []

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTodo: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이전 데이터 불러오기
        loadAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 데이터 저장
        saveAllData()
        // 테이블 데이터 갱신
        tblTodo.reloadData()
    }
    
    /* cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    /* cell 높이 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if todoList[indexPath.row].description == "" {
            return 45
        } else {
            return 65
        }
    }

    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        
        // cell 설정
        cell.lblTitle.text = "\(todoList[indexPath.row].title)"
        cell.lblDescription.text = "\(todoList[indexPath.row].description ?? "")"
        
        // 체크박스 버튼
        if todoList[indexPath.row].completed == true {
            cell.btnCheckbox.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            cell.btnCheckbox.setBackgroundImage(UIImage(systemName:"circle"), for: .normal)
        }

        // 체크박스 선택 시 작업 추가
        cell.btnCheckbox.tag = indexPath.row
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: UIButton) {
        todoList[sender.tag].completed.toggle() // Bool 값 변경
        tblTodo.reloadData()
    }
    
    /* 리스트 선택 시 수정 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO - Edit Task 화면 표시
    }
    
    /* cell 삭제 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todoList.remove(at: indexPath.row)
        tblTodo.reloadData()
    }
    
    /* 데이터 저장 */
    func saveAllData() {
        let data = todoList.map { [
            "title": $0.title,
            "description": $0.description ?? "",
            "complete": $0.completed,
            "date": $0.date ?? ""
            ]
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "items")
        userDefaults.synchronize()  // 동기화
    }
    
    /* 데이터 불러오기 */
    func loadAllData() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "items") as? [[String: AnyObject]] else {
            return
        }
        
        // list 배열에 저장하기
        todoList = data.map {
            let title = $0["title"] as? String
            let description = $0["description"] as? String
            let complete = $0["complete"] as? Bool
            let date = $0["date"] as? String
            
            return Todo(title: title!, description: description, completed: complete!, date: date)
        }
    }
}

