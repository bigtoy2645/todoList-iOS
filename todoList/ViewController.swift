//
//  ViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/07.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTodo: UITableView!
    var todoList: [Todo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO - 이전 데이터 불러오기
    }

    /* 할 일 추가 */
    @IBAction func clickedAddButton(_ sender: UIBarButtonItem) {
        // TODO - 데이터 입력받기
        let todoObject = Todo(title: "title", subTitle: "", completed: false)
        todoList.append(todoObject)
        reloadData()
    }
    
    func reloadData() {
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
        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"
        
        return cell
    }
    
}

