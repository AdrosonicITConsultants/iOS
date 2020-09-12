//
//  BuyerEnquirySectionView.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class BuyerEnquirySectionView: Cell<String>, CellType {


    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class BuyerEnquirySectionViewRow: Row<BuyerEnquirySectionView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<BuyerEnquirySectionView>(nibName: "BuyerEnquirySectionView")
    }
}

