//
//  EnquiryDetailRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class EnquiryDetailRowView: Cell<String>, CellType {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var prodDetailLbl: UILabel!
    @IBOutlet weak var designByLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusDotView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var faultyStrings: UIImageView!
    public override func setup() {
        super.setup()
        faultyStrings.isHidden = true
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class EnquiryDetailsRow: Row<EnquiryDetailRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<EnquiryDetailRowView>(nibName: "EnquiryDetailsRow")
    }
}

