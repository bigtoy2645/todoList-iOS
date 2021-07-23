//
//  TodoTableViewCell.swift
//  todoList
//
//  Created by yurim on 2020/09/14.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TodoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckbox: CheckUIButton!
    
    static let nibName = "TodoTableViewCell"
    static let identifier = "TodoCell"
    
    var viewModel = TodoViewModel(Todo.empty)
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(task: Todo) {
        viewModel = TodoViewModel(task)
        
        // UI Binding
        setupBindings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        // Title
        viewModel.task
            .map { $0.title }
            .observe(on: MainScheduler.instance)
            .bind(to: lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        // Description
        viewModel.descriptionString
            .observe(on: MainScheduler.instance)
            .bind(to: lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        // Time, Description 비어있으면 숨김
        viewModel.task
            .map {
                if let time = $0.time, time.isEmpty == false { return false }
                if let description = $0.description, description.isEmpty == false { return false }
                return true
            }
            .observe(on: MainScheduler.instance)
            .bind(to: lblDescription.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 체크박스 버튼
        viewModel.checkImageString
            .map { UIImage(systemName: $0) }
            .observe(on: MainScheduler.instance)
            .bind(to: btnCheckbox.rx.backgroundImage())
            .disposed(by: disposeBag)
    }
}

class CheckUIButton : UIButton {
    var indexPath: IndexPath?
}
