//
//  AdminChatEscalationCell.swift
//  CraftExchange
//
//  Created by Kalyan on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

class AdminChatEscalationCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var concern: UILabel!
    @IBOutlet weak var concernType: UILabel!
    @IBOutlet weak var isResolved: UILabel!
    
    func configure(_ escalationObj: AdminChatEscalationObject?) {
        date.text = Date().ttceFormatter2(isoDate: escalationObj?.date ?? "")
        concern.text = escalationObj?.text ?? ""
        concernType.text = escalationObj?.category ?? ""
        isResolved.text = escalationObj?.isResolved == 1 ? "Yes" : "No"
        
    }
    
}
