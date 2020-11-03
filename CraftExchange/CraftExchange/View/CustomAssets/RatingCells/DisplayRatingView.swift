//
//  DisplayRatingView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol ratingClickedProtocol {
    func ratingBtnSelected(tag: Int)
}

class  DisplayRatingView: Cell<String>, CellType {

    @IBOutlet weak var Label: UILabel!
    
    @IBOutlet weak var RatingBtn: UIButton!
    
    var delegate: ratingClickedProtocol?
    
    @IBAction func ratingBtnSelected(_ sender: Any) {
delegate?.ratingBtnSelected(tag: tag)
       }
    public override func setup() {
        super.setup()
        RatingBtn.addTarget(self, action: #selector(ratingBtnSelected(_:)), for: .touchUpInside)

    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  DisplayRatingRow: Row< DisplayRatingView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider< DisplayRatingView>(nibName: "DisplayRatingView")
    }
}




