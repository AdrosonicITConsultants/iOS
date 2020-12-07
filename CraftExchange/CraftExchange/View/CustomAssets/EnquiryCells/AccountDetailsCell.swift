//
//  AccountDetailsCell.swift
//  CraftExchange
//
//  Created by Kalyan on 07/12/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Eureka

class AccountDetailsCell: Cell<String>, CellType {
    
    @IBOutlet weak var AccountTitleLabel: UILabel!
    @IBOutlet weak var AccountDetailLabel: UILabel!
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
    }
    
}

final class AccountDetailsRow: Row<AccountDetailsCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AccountDetailsCell>(nibName: "AccountDetailsCell")
    }
}
