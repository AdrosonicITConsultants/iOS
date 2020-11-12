//
//  GiveRatingCell.swift
//  CraftExchange
//
//  Created by Kiran Songire on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka



class  GiveRatingCell: Cell<String>, CellType {
    
    @IBOutlet weak var RatingLabel: UILabel!
    @IBOutlet weak var weatherStartsImg: UIImageView!
    @IBOutlet weak var AvgTextLabel: UILabel!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  GiveRatingRow: Row<GiveRatingCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<GiveRatingCell>(nibName: "GiveRatingCell")
    }
}




