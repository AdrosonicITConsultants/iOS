//
//  OrderAvailabilityCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import UIKit
import Eureka

protocol AvailabilityCellProtocol {
  func availabilitySelected(tag: Int)
}

class OrderAvailabilityCellView: Cell<String>, CellType {

    var availabilityDelegate: AvailabilityCellProtocol?
    @IBOutlet weak var makeToOrderLbl: UILabel!
    @IBOutlet weak var inStockLbl: UILabel!
    @IBOutlet weak var makeToOrderBtn: UIButton!
    @IBOutlet weak var inStockBtn: UIButton!
    
    public override func setup() {
        super.setup()
        inStockBtn.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
        makeToOrderBtn.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
        makeToOrderBtn.layer.borderColor = UIColor.lightGray.cgColor
        inStockBtn.layer.borderColor = UIColor.lightGray.cgColor
        makeToOrderBtn.layer.borderWidth = 1
        inStockBtn.layer.borderWidth = 1
        makeToOrderBtn.dropShadow()
        inStockBtn.dropShadow()
        makeToOrderBtn.layer.cornerRadius = 60
        inStockBtn.layer.cornerRadius = 60
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func customButtonSelected(_ sender: Any) {
      availabilityDelegate?.availabilitySelected(tag: tag)
        let btn = sender as! UIButton
        if btn.layer.borderColor == UIColor.lightGray.cgColor {
            btn.layer.borderColor = UIColor().menuSelectorBlue().cgColor
            btn.layer.borderWidth = 5
        }else {
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.layer.borderWidth = 1
        }
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class OrderAvailabilityCell: Row<OrderAvailabilityCellView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<OrderAvailabilityCellView>(nibName: "OrderAvailabilityCell")
    }
}


