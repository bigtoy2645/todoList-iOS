//
//  ViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/07.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

protocol SendDataDelegate {
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?)
    func sendData(scheduledTasks: [String : [Todo]], newDate: String)
}

enum DefaultsKey {
    static let isFirstLaunch = "isFirstLaunch"
}

class DailyTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTodo: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!
    
    // MARK: - Instance Properties
    
    public let sectionTitle: [String] = ["Scheduled", "Anytime"]
    var selectedDate: String = ""
    let dateFormatter = DateFormatter()
    var todoScheduled: [String : [Todo]] = [:] {    // e.g. "2020-09-23" : [Todo]
        didSet {
            saveData(data: todoScheduled, key: sectionTitle[0])
        }
    }
    var todoAnytime: [Todo] = [] {
        didSet {
            saveData(data: todoAnytime, key: sectionTitle[1])
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오늘 날짜 설정
        selectedDate = dateFormatter.dateToString(Date())
        
        // 데이터 불러오기
        if nil != UserDefaults.standard.value(forKey: DefaultsKey.isFirstLaunch) {
            loadAllData()                       // 이전 데이터 불러오기
        } else {
            loadFirstData(date: selectedDate)   // 최초 설치 시 데이터 불러오기
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 테이블 데이터 갱신
        tblTodo.reloadData()
    }
    
    // MARK: - Tableview Delegate
    
    /* cell 개수 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return todoScheduled[selectedDate]?.count ?? 0  // 해당 날짜 cell 개수
        }
        return todoAnytime.count
    }
    
    /* cell 높이 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let task = getTask(indexPath: indexPath, selectedDate: selectedDate)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier, for: indexPath) as! TodoCell
        let task = getTask(indexPath: indexPath, selectedDate: selectedDate)
        
        // cell 설정
        cell.bind(task: task)
        
        // 체크박스 선택 시 작업 추가
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    /* cell 선택 시 수정 */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Edit Task 화면 표시
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: "addTask") as? AddTaskViewController else { return }
        addTaskVC.editTask = getTask(indexPath: indexPath, selectedDate: selectedDate)
        addTaskVC.indexPath = indexPath
        addTaskVC.delegate = self
        addTaskVC.currentDate = dateFormatter.stringToDate(selectedDate)
        
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
    
    /* cell 순서 변경 허용 */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* cell 순서 변경 시 조정 */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == 0 {
            guard let scheduledTasks = todoScheduled[selectedDate] else { return }
            var sourceTask = scheduledTasks[sourceIndexPath.row]
            
            if destinationIndexPath.section == 0 {  // Scheduled -> Scheduled
                todoScheduled[selectedDate]?[sourceIndexPath.row] = scheduledTasks[destinationIndexPath.row]
                todoScheduled[selectedDate]?[destinationIndexPath.row] = sourceTask
            } else {                                // Scheduled -> Anytime
                todoScheduled[selectedDate]?.remove(at: sourceIndexPath.row)
                sourceTask.date = ""
                sourceTask.time = ""
                todoAnytime.insert(sourceTask, at: destinationIndexPath.row)
            }
        } else {
            var sourceTask = todoAnytime[sourceIndexPath.row]
            
            if destinationIndexPath.section == 0 {  // Anytime -> Scheduled
                todoAnytime.remove(at: sourceIndexPath.row)
                sourceTask.date = selectedDate
                if todoScheduled[selectedDate] != nil {
                    todoScheduled[selectedDate]?.insert(sourceTask, at: destinationIndexPath.row)
                } else {
                    todoScheduled.updateValue([sourceTask], forKey: selectedDate)
                }
            } else {                                // Anytime -> Anytime
                todoAnytime[sourceIndexPath.row] = todoAnytime[destinationIndexPath.row]
                todoAnytime[destinationIndexPath.row] = sourceTask
            }
        }
    }
    
    // MARK: - Data Processing
    
    /* 데이터 저장 */
    func saveData<T: Encodable>(data: T, key: String) {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        if let jsonData = try? encoder.encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: key)
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
    
    /* 초기 데이터 불러오기 */
    func loadFirstData(date: String) {
        let userDefaults = UserDefaults.standard
        
        userDefaults.setValue(false, forKey: DefaultsKey.isFirstLaunch)
        todoScheduled.updateValue([Todo(title: "Create new task", date: selectedDate, time: "8:00 PM", description: "Click the plus button to add a scheduled task.")], forKey: selectedDate)
        todoAnytime.append(Todo(title: "Update your task", date: "", time: "", description: "This task has not yet been scheduled."))
        
        userDefaults.synchronize()
    }
    
    /* TableView IndexPath에 해당하는 Task를 구한다. */
    func getTask(indexPath: IndexPath, selectedDate: String) -> Todo {
        if indexPath.section == 0 {
            return todoScheduled[selectedDate]?[indexPath.row] ?? Todo.empty
        } else {
            return todoAnytime[indexPath.row]
        }
    }
    
    /* todoScheduled에 날짜 별로 객체를 추가한다. */
    func appendToScheduled(task: Todo, date: String) {
        if nil != todoScheduled[date] {
            todoScheduled[date]?.append(task)
        } else {
            todoScheduled.updateValue([task], forKey: date)
        }
    }
    
    // MARK: - Actions
    
    /* 추가 버튼 클릭 */
    @IBAction func addTaskButtonPressed(_ sender: Any) {
        // Create Task 화면 표시
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: "addTask") as? AddTaskViewController else { return }
        addTaskVC.delegate = self
        addTaskVC.currentDate = dateFormatter.stringToDate(selectedDate)
        
        self.navigationController?.pushViewController(addTaskVC, animated: true)
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
    
    /* 달력 버튼 클릭 */
    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        // Calendar 화면 표시
        guard let calendarVC = self.storyboard?.instantiateViewController(identifier: "calendarTask") as? CalendarViewController else { return }
        calendarVC.delegate = self
        calendarVC.todoScheduled = todoScheduled
        calendarVC.currentDate = dateFormatter.stringToDate(selectedDate)
        
        let navController = UINavigationController(rootViewController: calendarVC)
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true, completion: nil)
    }
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        // Complete 값 변경
        if indexPath.section == 0 {
            todoScheduled[selectedDate]?[indexPath.row].isCompleted.toggle()
        } else {
            todoAnytime[indexPath.row].isCompleted.toggle()
        }
        
        tblTodo.reloadData()
    }
}

// MARK: - SendDataDelegate

extension DailyTasksViewController: SendDataDelegate {
    
    /* Calendar -> DailyTasks */
    func sendData(scheduledTasks: [String : [Todo]], newDate: String) {
        if scheduledTasks.count > 0 {
            todoScheduled = scheduledTasks
        }
        if "" != newDate {
            selectedDate = newDate
        }
    }
    
    /* AddTask -> DailyTasks */
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?) {
        let oldDate = oldTask?.date ?? ""
        let newDate = newTask.date ?? ""
        
        if let index = indexPath {      // Task 수정
            if index.section == 0 {
                if newDate != "" {      // Scheduled -> Scheduled
                    // 날짜 변경
                    if newDate != oldDate {
                        todoScheduled[oldDate]?.remove(at: index.row)
                        appendToScheduled(task: newTask, date: newDate)
                    } else {
                        todoScheduled[newDate]?[index.row].updateValue(task: newTask)
                    }
                } else {                // Scheduled -> Anytime
                    todoScheduled[oldDate]?.remove(at: index.row)
                    todoAnytime.append(newTask)
                }
            } else {
                if newDate != "" {      // Anytime -> Scheduled
                    todoAnytime.remove(at: index.row)
                    appendToScheduled(task: newTask, date: newDate)
                } else {                // Anytime -> Anytime
                    todoAnytime[index.row].updateValue(task: newTask)
                }
            }
        } else {                        // Task 추가
            if newDate != "" {
                appendToScheduled(task: newTask, date: newDate)
            } else {
                todoAnytime.append(newTask)
            }
        }
    }
}
