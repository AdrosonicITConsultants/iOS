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
        enquiryDate.text = obj.date ?? "NA"
        enquiryCode.text = obj.code ?? "NA"
        brand.text = obj.companyName ?? "NA"
        productCategory.text = obj.productCategory ?? "NA"
        weaveUsed.text = obj.weave ?? "NA"
    }
    
    
}
