//
//  TodoCell.swift
//  todoList
//
//  Created by yurim on 2020/09/14.
//  Copyright © 2020 yurim. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckbox: CheckUIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /* Todo -> TodoCell */
    func updateValue(task: Todo) {
        // Title
        lblTitle.text = task.title
        
        // Description
        if task.time == "" {
            lblDescription.text = "\(task.description ?? "")"
        } else {
            lblDescription.text = "\(task.time ?? "") \(task.description ?? "")"
        }
        
        // 체크박스 버튼
        if task.isCompleted == true {
            btnCheckbox.setBackgroundImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            btnCheckbox.setBackgroundImage(UIImage(systemName:"circle"), for: .normal)
        }
    }

}

class CheckUIButton : UIButton {
    var indexPath: IndexPath?
}
