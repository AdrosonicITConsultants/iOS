//
//  AdminNotificationView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 04/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//


import Foundation
import UIKit
import Eureka

class AdminNotificationView: Cell<String>, CellType {

    @IBOutlet weak var customEnquiry: UILabel!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var Date: UILabel!
    
    public override func setup() {
            super.setup()
        }

        public override func update() {
            super.update()
        }
    }

    // The custom Row also has the cell: CustomCell and its correspond value
    final class AdminNotificationRow: Row<AdminNotificationView>, RowType {
        required public init(tag: String?) {
            super.init(tag: tag)
            // We set the cellProvider to load the .xib corresponding to our cell
            cellProvider = CellProvider<AdminNotificationView>(nibName: "AdminNotificationView")
        }
    }

