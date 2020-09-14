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
    @IBOutlet weak var lblDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        lblDate.textColor = UIColor.lightGray
//        lblDate.layer.borderColor = UIColor.lightGray.cgColor
//        lblDate.layer.borderWidth = 0.5
//        lblDate.layer.cornerRadius = 10
//        lblDate.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
