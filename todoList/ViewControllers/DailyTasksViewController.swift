//
//  ViewController.swift
//  todoList
//
//  Created by yurim on 2020/09/07.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol SendDataDelegate {
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?)
    func sendData(scheduledTasks: [String : [Todo]], newDate: Date)
}

enum DefaultsKey {
    static let isFirstLaunch = "isFirstLaunch"
}

class DailyTasksViewController: UIViewController {
    
    @IBOutlet weak var tblTodo: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!
    
    private var todoSections: BehaviorRelay<[Task]> = BehaviorRelay(value: [])
    private var dataSource: RxTableViewSectionedReloadDataSource<Task>!
    var viewModel = TodoListViewModel()
    var disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTodo.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTodo.rowHeight = UITableView.automaticDimension
        
        // UI Binding
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 테이블 데이터 갱신
        tblTodo.reloadData()
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        dataSource = RxTableViewSectionedReloadDataSource<Task> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
            
            // cell 설정
            cell.bind(task: item)
            
            // 체크박스 선택 시 작업 추가
            cell.btnCheckbox.indexPath = indexPath
            cell.btnCheckbox.addTarget(self, action: #selector(self.checkboxSelection(_:)), for: .touchUpInside)
            return cell
        }
        
        Observable.zip(tblTodo.rx.modelSelected(Todo.self), tblTodo.rx.itemSelected)
            .bind { [weak self] (task, indexPath) in
                guard let addTaskVC = self?.storyboard?.instantiateViewController(identifier: AddTaskViewController.storyboardID) as? AddTaskViewController else { return }
                addTaskVC.editTask = task
                addTaskVC.indexPath = indexPath
                addTaskVC.delegate = self
                addTaskVC.currentDate = self?.viewModel.selectedDate.value
                
                self?.navigationController?.pushViewController(addTaskVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        tblTodo.rx.itemDeleted
            .bind { [weak self] indexPath in
                if indexPath.section == 0 {
                    self?.viewModel.removeScheduledTask(at: indexPath.row)
                } else {
                    self?.viewModel.removeAnytimeTask(at: indexPath.row)
                }
            }
            .disposed(by: disposeBag)
        
        tblTodo.rx.itemMoved
            .subscribe { sourceIndexPath, destinationIndexPath in
//                if sourceIndexPath.section == 0 {
//                    guard let scheduledTasks = todoScheduled[selectedDate] else { return }
//                    var sourceTask = scheduledTasks[sourceIndexPath.row]
//
//                    if destinationIndexPath.section == 0 {  // Scheduled -> Scheduled
//                        todoScheduled[selectedDate]?[sourceIndexPath.row] = scheduledTasks[destinationIndexPath.row]
//                        todoScheduled[selectedDate]?[destinationIndexPath.row] = sourceTask
//                    } else {                                // Scheduled -> Anytime
//                        todoScheduled[selectedDate]?.remove(at: sourceIndexPath.row)
//                        sourceTask.date = ""
//                        sourceTask.time = ""
//                        todoAnytime.insert(sourceTask, at: destinationIndexPath.row)
//                    }
//                } else {
//                    var sourceTask = todoAnytime[sourceIndexPath.row]
//
//                    if destinationIndexPath.section == 0 {  // Anytime -> Scheduled
//                        todoAnytime.remove(at: sourceIndexPath.row)
//                        sourceTask.date = selectedDate
//                        if todoScheduled[selectedDate] != nil {
//                            todoScheduled[selectedDate]?.insert(sourceTask, at: destinationIndexPath.row)
//                        } else {
//                            todoScheduled.updateValue([sourceTask], forKey: selectedDate)
//                        }
//                    } else {                                // Anytime -> Anytime
//                        todoAnytime[sourceIndexPath.row] = todoAnytime[destinationIndexPath.row]
//                        todoAnytime[destinationIndexPath.row] = sourceTask
//                    }
//                }
            }
            .disposed(by: disposeBag)
        
        dataSource.titleForHeaderInSection = { ds, index in
            let date = ds.sectionModels[index].date
            return date.isEmpty ? Section.anytime.rawValue : "\(Section.scheduled.rawValue) \(date)"
        }
        
        todoSections
            .observe(on: MainScheduler.instance)
            .bind(to: tblTodo.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.todoCurrent, viewModel.todoAnytime)
            .subscribe(onNext: { scheduled, anytime in
                let date = self.viewModel.selectedDate.value.toString()
                self.todoSections.accept([Task(date: date, items: scheduled), Task(date: "", items: anytime)])
            })
            .disposed(by: disposeBag)
        
        viewModel.selectedDate
            .subscribe(onNext: {
                let tasks = self.viewModel.todoScheduled.value[$0.toString()] ?? []
                self.viewModel.todoCurrent.accept(tasks)
                self.todoSections.accept([Task(date: $0.toString(), items: tasks),
                                          Task(date: "", items: self.viewModel.todoAnytime.value)])
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    /* 추가 버튼 클릭 */
    @IBAction func addTaskButtonPressed(_ sender: Any) {
        // Create Task 화면 표시
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: "addTask") as? AddTaskViewController else { return }
        addTaskVC.delegate = self
        addTaskVC.currentDate = viewModel.selectedDate.value
        
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
        calendarVC.todoScheduled = viewModel.todoScheduled.value
        calendarVC.selectedDate = viewModel.selectedDate.value
        
        let navController = UINavigationController(rootViewController: calendarVC)
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true, completion: nil)
    }
    
    /* 체크박스 선택 시 동작 */
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
        if indexPath.section == 0 {
            let newValue = viewModel.todoCurrent.value.enumerated()
                .map { index, element -> Todo in
                    var task = element
                    if index == indexPath.row { task.isCompleted.toggle() }
                    return task
                }
            
            viewModel.todoCurrent.accept(newValue)
        } else {
            let newValue = viewModel.todoAnytime.value.enumerated()
                .map { index, element -> Todo in
                    var task = element
                    if index == indexPath.row { task.isCompleted.toggle() }
                    return task
                }
            
            viewModel.todoAnytime.accept(newValue)
        }
    }
}

// MARK: - SendDataDelegate

extension DailyTasksViewController: SendDataDelegate {
    
    /* Calendar -> DailyTasks */
    func sendData(scheduledTasks: [String : [Todo]], newDate: Date) {
        if !scheduledTasks.isEmpty {
            viewModel.todoScheduled.accept(scheduledTasks)
        }
        viewModel.selectedDate.accept(newDate)
    }
    
    /* AddTask -> DailyTasks */
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?) {
        let oldDate = oldTask?.date ?? ""
        let newDate = newTask.date ?? ""
        
        //        if let index = indexPath {      // Task 수정
        //            if index.section == 0 {
        //                if newDate != "" {      // Scheduled -> Scheduled
        //                    // 날짜 변경
        //                    if newDate != oldDate {
        //                        todoScheduled[oldDate]?.remove(at: index.row)
        //                        appendToScheduled(task: newTask, date: newDate)
        //                    } else {
        //                        todoScheduled[newDate]?[index.row].updateValue(task: newTask)
        //                    }
        //                } else {                // Scheduled -> Anytime
        //                    todoScheduled[oldDate]?.remove(at: index.row)
        //                    todoAnytime.append(newTask)
        //                }
        //            } else {
        //                if newDate != "" {      // Anytime -> Scheduled
        //                    todoAnytime.remove(at: index.row)
        //                    appendToScheduled(task: newTask, date: newDate)
        //                } else {                // Anytime -> Anytime
        //                    todoAnytime[index.row].updateValue(task: newTask)
        //                }
        //            }
        //        } else {                        // Task 추가
        //            if newDate != "" {
        //                appendToScheduled(task: newTask, date: newDate)
        //            } else {
        //                todoAnytime.append(newTask)
        //            }
        //        }
    }
}
