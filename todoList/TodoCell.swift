//
//  TodoCell.swift
//  todoList
//
//  Created by yurim on 2020/09/14.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckbox: CheckUIButton!
    
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
            .bind(to: lblDescription.rx.text)
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
