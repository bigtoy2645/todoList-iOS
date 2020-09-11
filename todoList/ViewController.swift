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
    
    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "TodoCell")
        
        cell.textLabel?.text = "\(todoList[indexPath.row].title)"
        cell.detailTextLabel?.text = "\(todoList[indexPath.row].description ?? "")"
        
        return cell
    }
    
    /* 리스트 선택 시 체크 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 이미 체크되있는 경우 return
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                todoList[indexPath.row].completed = false
            }
            else{
                cell.accessoryType = .checkmark
                todoList[indexPath.row].completed = true
            }
        }
    }
    
    /* cell 삭제 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todoList.remove(at: indexPath.row)
        tblTodo.reloadData()
    }
    
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
    
    // userDefault 데이터 불러오기
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

