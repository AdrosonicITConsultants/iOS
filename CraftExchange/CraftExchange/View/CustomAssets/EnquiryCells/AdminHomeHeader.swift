//
//  AdminHomeHeader.swift
//  CraftExchange
//
//  Created by Kiran Songire on 12/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka
protocol NotifyButtonProtocol {
    func NotifyBtnSelected(tag: Int)
}
class AdminHomeHeader: Cell<String>, CellType {

    
    @IBOutlet weak var Logo: UIImageView!
    
    @IBOutlet weak var NotifyBtn: UIButton!
    var delegate: NotifyButtonProtocol?
       @IBAction func NotifyBtnSelected(_ sender: Any) {
       delegate?.NotifyBtnSelected(tag: tag)
              }
    public override func setup() {
        super.setup()
        NotifyBtn.addTarget(self, action: #selector(NotifyBtnSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class AdminHomeHeaderRow: Row<AdminHomeHeader>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AdminHomeHeader>(nibName: "AdminHomeHeader")
    }
}

