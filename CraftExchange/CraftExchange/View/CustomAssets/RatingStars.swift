//
//  RatingStars.swift
//  CraftExchange
//
//  Created by Kiran Songire on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka
import Cosmos

protocol RatingStarsProtocol {
    func ratingSelected(tag: Int, rating: Double)
}


class  RatingStars: Cell<String>, CellType {
    
    @IBOutlet weak var StarsView: CosmosView!
    
    var delegate: RatingStarsProtocol?
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
        StarsView.didFinishTouchingCosmos = {
            rating in
            self.delegate?.ratingSelected(tag: self.tag, rating: rating)
        }
    }
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  RatingStarsRow: Row<RatingStars>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RatingStars>(nibName: "RatingStars")
    }
}




