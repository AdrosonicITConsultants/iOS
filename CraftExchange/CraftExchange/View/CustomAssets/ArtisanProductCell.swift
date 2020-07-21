//
//  ArtisanProductCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class ArtisanProductCell: UITableViewCell {
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var inStock: UILabel!
    @IBOutlet weak var exclusive: UILabel!
    @IBOutlet weak var designedByImage: UIImageView!
    @IBOutlet weak var productDesc: UILabel!
    
    func configure(_ productObj: Product) {
        productTag.text = productObj.productTag ?? ""
        productDesc.text = productObj.productSpec ?? ""
        if productObj.productStatusId == 1 {
            inStock.isHidden = true
            exclusive.isHidden = false
        }else {
            inStock.isHidden = false
            exclusive.isHidden = true
        }
        if productObj.madeWithAnthran == 1 {
            designedByImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            designedByImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
    }
}
