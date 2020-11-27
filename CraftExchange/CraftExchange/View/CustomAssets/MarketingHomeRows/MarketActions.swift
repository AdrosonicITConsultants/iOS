//
//  MarketActions.swift
//  CraftExchange
//
//  Created by Kiran Songire on 12/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka
protocol MarketActionsProtocol {
    func ArrowBtnSelected(tag: Int)
}
class MarketActions:Cell<String>, CellType {

//    @IBOutlet weak var ActionBtn: UIButton!
    @IBOutlet weak var backgroundGradientView: UIView!
    
    @IBOutlet weak var ArrowBtn: UIButton!
    @IBOutlet weak var ActionImg: UIImageView!
    @IBOutlet weak var ActionLabel: UILabel!
    @IBOutlet weak var ColorLine: UIView!
    @IBOutlet weak var LowerActionLabel: UILabel!
    var delegate: MarketActionsProtocol!
    
    public override func setup() {
        super.setup()
        ArrowBtn.addTarget(self, action: #selector(ArrowButtonSelected), for: .touchUpInside)
        self.selectionStyle = .none
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func ArrowButtonSelected(_ sender: Any) {
        delegate?.ArrowBtnSelected(tag: tag)
    }
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class MarketActionsRow: Row<MarketActions>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<MarketActions>(nibName: "MarketActions")
    }
}

