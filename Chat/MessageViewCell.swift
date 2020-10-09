//
//  MessageViewCell.swift
//  Chat
//
//  Created by Siarhei on 23.01.2020.
//  Copyright © 2020 Siarhei. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {

    @IBOutlet weak var message: InsetLabel!
    @IBOutlet weak var heightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var time: UILabel!
    
    
    var height: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.message.layer.borderWidth = 1
        self.message.layer.borderColor = UIColor.black.cgColor
        self.message.layer.cornerRadius = self.message.bounds.height / 2
    }
}
