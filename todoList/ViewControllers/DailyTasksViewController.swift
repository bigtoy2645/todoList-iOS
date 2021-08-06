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
            .bind { indexPath in
                if indexPath.section == 0 {
                    var scheduled = self.viewModel.todoScheduled.value
                    let date = self.viewModel.selectedDate.value.toString()
                    scheduled[date]?.remove(at: indexPath.row)
                    self.viewModel.todoScheduled.accept(scheduled)
                } else {
                    var anytime = self.viewModel.todoAnytime.value
                    anytime.remove(at: indexPath.row)
                    self.viewModel.todoAnytime.accept(anytime)
                }
            }
            .disposed(by: disposeBag)
        
        tblTodo.rx.itemMoved
            .subscribe { srcIndexPath, dstIndexPath in
                var anytime = self.viewModel.todoAnytime.value
                var scheduled = self.viewModel.todoScheduled.value
                let date = self.viewModel.selectedDate.value.toString()
                var task = Todo.empty
                
                if srcIndexPath.section == 0 {  // Scheduled
                    task = scheduled[date]?.remove(at: srcIndexPath.row) ?? Todo.empty
                } else {                        // Anytime
                    task = anytime.remove(at: srcIndexPath.row)
                }
                
                if dstIndexPath.section == 0 {  // Scheduled
                    task.date = date
                    scheduled[date]?.insert(task, at: dstIndexPath.row)
                } else {                        // Anytime
                    task.date = ""
                    task.time = ""
                    anytime.insert(task, at: dstIndexPath.row)
                }
                
                self.viewModel.todoScheduled.accept(scheduled)
                self.viewModel.todoAnytime.accept(anytime)
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
        
        // 할일이나 날짜가 변경되면 테이블 업데이트
        Observable.combineLatest(viewModel.todoScheduled, viewModel.todoAnytime, viewModel.selectedDate)
            .subscribe(onNext: { scheduled, anytime, date in
                let dateString = date.toString()
                self.todoSections.accept([Task(date: dateString, items: scheduled[dateString] ?? []),
                                          Task(date: "", items: anytime)])
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    /* 추가 버튼 클릭 */
    @IBAction func addTaskButtonPressed(_ sender: UIButton) {
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
            var tasks = viewModel.todoScheduled.value
            let date = viewModel.selectedDate.value.toString()
            tasks[date]?[indexPath.row].isCompleted.toggle()
            viewModel.todoScheduled.accept(tasks)
        } else {
            var tasks = viewModel.todoAnytime.value
            tasks[indexPath.row].isCompleted.toggle()
            viewModel.todoAnytime.accept(tasks)
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
        var anytime = viewModel.todoAnytime.value
        var scheduled = viewModel.todoScheduled.value
        let oldDate = oldTask?.date ?? ""
        let newDate = newTask.date ?? ""
        
        // OldTask 제거
        if let _ = oldTask, let index = indexPath {
            if oldDate.isEmpty {    // Anytime
                anytime.remove(at: index.row)
            } else {                // Scheduled
                scheduled[oldDate]?.remove(at: index.row)
            }
        }
        
        // NewTask 추가
        if newDate.isEmpty {    // Anytime
            anytime.insert(newTask, at: indexPath?.row ?? anytime.count)
        } else {                // Scheduled
            var newDateTasks = scheduled[newDate] ?? []
            newDateTasks.insert(newTask, at: indexPath?.row ?? newDateTasks.count)
            scheduled[newDate] = newDateTasks
        }
        
        viewModel.todoAnytime.accept(anytime)
        viewModel.todoScheduled.accept(scheduled)
    }
}
