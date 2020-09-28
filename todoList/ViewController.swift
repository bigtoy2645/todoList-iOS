//
//  ViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/07.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

var todoScheduled: [String : [Todo]] = [:]  // e.g. "2020-09-23" : [Todo]
var todoAnytime: [Todo] = []
var selectedDate: String = ""

/* TableView IndexPath에 해당하는 Task를 구한다. */
func getTask(indexPath: IndexPath) -> Todo {
    if indexPath.section == 0 {
        return todoScheduled[selectedDate]?[indexPath.row] ?? Todo(title: "", date: "", time: "", description: "", isCompleted: false)
    } else {
        return todoAnytime[indexPath.row]
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTodo: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!
    
    let sectionTitle: [String] = ["Scheduled", "Anytime"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오늘 날짜 설정
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultDateFormat
        selectedDate = dateFormatter.string(from: Date())
        
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
        // 해당 날짜 cell 개수
        if section == 0 {
            return todoScheduled[selectedDate]?.count ?? 0
        }
        
        return todoAnytime.count
    }
    
    /* cell 높이 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let task = getTask(indexPath: indexPath)
        if task.description == "", task.time == "" {
            return 45
        }
        return 65
    }
    
    /* section 개수 */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /* section 타이틀 */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "\(sectionTitle[section]) \(selectedDate)"
        }
        
        return sectionTitle[section]
    }
    
    /* cell 그리기 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        let task = getTask(indexPath: indexPath)
        
        // cell 설정
        cell.lblTitle.text = "\(task.title)"
        if task.time == "" {
            cell.lblDescription.text = "\(task.description ?? "")"
        } else {
            cell.lblDescription.text = "\(task.time ?? "") \(task.description ?? "")"
        }
        
        // 체크박스 버튼
        if task.isCompleted == true {
            cell.btnCheckbox.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            cell.btnCheckbox.setBackgroundImage(UIImage(systemName:"circle"), for: .normal)
        }
        
        // 체크박스 선택 시 작업 추가
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        // Complete 값 변경
        if indexPath.section == 0 {
            if var task = todoScheduled[selectedDate] {
                task[indexPath.row].isCompleted.toggle()
                todoScheduled[selectedDate] = task
            }
        } else {
            todoAnytime[indexPath.row].isCompleted.toggle()
        }
        
        tblTodo.reloadData()
    }
    
    /* cell 선택 시 수정 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Edit Task 화면 표시
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: "addTask") as? AddTaskViewController else { return }
        addTaskVC.mode = .edit
        addTaskVC.indexPath = indexPath
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    /* 추가 버튼 클릭 */
    @IBAction func addTaskButtonPressed(_ sender: Any) {
        // Create Task 화면 표시
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: "addTask") as? AddTaskViewController else { return }
        addTaskVC.mode = .create
        addTaskVC.indexPath = nil
        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    /* cell 삭제 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            todoScheduled[selectedDate]?.remove(at: indexPath.row)
        } else {
            todoAnytime.remove(at: indexPath.row)
        }
        
        tblTodo.reloadData()
    }
    
    /* 수정 버튼 클릭 */
    @IBAction func editTableButtonPressed(_ sender: UIBarButtonItem) {
        if tblTodo.isEditing {
            btnEditTable.title = "Edit"
            tblTodo.setEditing(false, animated: true)
        } else {
            btnEditTable.title = "Done"
            tblTodo.setEditing(true, animated: true)
        }
    }
    
    /* cell 순서 변경 허용 */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* cell 순서 변경 시 조정 */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 {
            guard var scheduledTasks = todoScheduled[selectedDate] else { return }
            var sourceTask = scheduledTasks[sourceIndexPath.row]
            
            if destinationIndexPath.section == 0 {  // Scheduled -> Scheduled
                scheduledTasks[sourceIndexPath.row] = scheduledTasks[destinationIndexPath.row]
                scheduledTasks[destinationIndexPath.row] = sourceTask
            } else {                                // Scheduled -> Anytime
                scheduledTasks.remove(at: sourceIndexPath.row)
                todoScheduled[selectedDate] = scheduledTasks
                sourceTask.date = ""
                sourceTask.time = ""
                todoAnytime.insert(sourceTask, at: destinationIndexPath.row)
            }
        } else {
            var sourceTask = todoAnytime[sourceIndexPath.row]
            
            if destinationIndexPath.section == 0 {  // Anytime -> Scheduled
                todoAnytime.remove(at: sourceIndexPath.row)
                sourceTask.date = selectedDate
                if var tasks = todoScheduled[selectedDate] {
                    tasks.insert(sourceTask, at: destinationIndexPath.row)
                    todoScheduled[selectedDate] = tasks
                } else {
                    todoScheduled.updateValue([sourceTask], forKey: selectedDate)
                }
            } else {                                // Anytime -> Anytime
                todoAnytime[sourceIndexPath.row] = todoAnytime[destinationIndexPath.row]
                todoAnytime[destinationIndexPath.row] = sourceTask
            }
        }
    }
    
    /* 데이터 저장 */
    func saveAllData() {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        // Scheduled
        if let jsonData = try? encoder.encode(todoScheduled) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: sectionTitle[0])
            }
        }
        
        // Anytime
        if let jsonData = try? encoder.encode(todoAnytime) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: sectionTitle[1])
            }
        }
        
        // 동기화
        userDefaults.synchronize()
    }
    
    /* 데이터 불러오기 */
    func loadAllData() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // Scheduled
        if let jsonString = userDefaults.value(forKey: sectionTitle[0]) as? String {
            if let jsonData = jsonString.data(using: .utf8), let scheduledData = try? decoder.decode([String : [Todo]].self, from: jsonData) {
                todoScheduled = scheduledData
            }
        }
        
        // Anytime
        if let jsonString = userDefaults.value(forKey: sectionTitle[1]) as? String {
            if let jsonData = jsonString.data(using: .utf8), let anytimeData = try? decoder.decode([Todo].self, from: jsonData) {
                todoAnytime = anytimeData
            }
        }
    }
}

