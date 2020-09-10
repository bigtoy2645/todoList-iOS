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
        // TODO - 이전 데이터 불러오기
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            }
            else{
                cell.accessoryType = .checkmark
            }
        }
    }
    
    /* cell 삭제 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todoList.remove(at: indexPath.row)
        tblTodo.reloadData()
    }
    
}

