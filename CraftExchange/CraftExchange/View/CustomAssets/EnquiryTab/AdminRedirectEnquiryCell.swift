//
//  AdminRedirectEnquiryCell.swift
//  CraftExchange
//
//  Created by Kalyan on 25/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

class AdminRedirectEnquiryCell: UITableViewCell {

    @IBOutlet weak var enquiryDate: UILabel!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var brand: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var weaveUsed: UILabel!
    
    func configure(_ obj: AdminRedirectEnquiry) {
        enquiryDate.text = obj.date ?? ""
        enquiryCode.text = obj.code ?? ""
        brand.text = obj.companyName ?? ""
        productCategory.text = obj.productCategory ?? ""
        weaveUsed.text = obj.weave ?? ""
    }
    
    
}
