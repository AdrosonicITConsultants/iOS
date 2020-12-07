//
//  NotificationCell.swift
//  CraftExchange
//
//  Created by Kalyan on 03/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var enquiryIcon: UIImageView!
    
    @IBOutlet weak var enquiryId: UILabel!
    @IBOutlet weak var createdOn: UILabel! 
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
