//
//  BuyerFaultyOrderOptionRow.swift
//  CraftExchange
//
//  Created by Kalyan on 03/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol BuyerFaultyOrderOptionProtocol {
    func reviewOptionBtnSelected(tag: Int)
    
}

class BuyerFaultyOrderOptionRowView: Cell<String>, CellType {
    
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewOptionButton: RoundedButton!
    
    var delegate: BuyerFaultyOrderOptionProtocol?
    var buttonIsSelected = false
    
    public override func setup() {
        super.setup()
        reviewOptionButton.addTarget(self, action: #selector(reviewOptionBtnSelected(_:)), for: .touchUpInside)
        reviewOptionButton.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func reviewOptionBtnSelected(_ sender: Any) {
        
        if buttonIsSelected == false {
            buttonIsSelected = true
            
            reviewOptionButton.backgroundColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
            reviewOptionButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            
        }else{
            buttonIsSelected = false
            reviewOptionButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            reviewOptionButton.setTitleColor(#colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1), for: .normal)
        }
        
        delegate?.reviewOptionBtnSelected(tag: tag)
        
    }
}

final class BuyerFaultyOrderOptionRow: Row<BuyerFaultyOrderOptionRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<BuyerFaultyOrderOptionRowView>(nibName: "BuyerFaultyOrderOptionRow")
    }
}

