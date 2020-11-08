//
//  MOQSortButtonsRow.swift
//  CraftExchange
//
//  Created by Kalyan on 28/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol MOQSortButtonsActionProtocol {
    func quantityButtonSelected(tag: Int)
    func priceButtonSelected(tag: Int)
    func ETAButtonSelected(tag: Int)
}

class MOQSortButtonsRowView: Cell<String>, CellType {

    
    @IBOutlet weak var quantityButton: UIButton!
    
    @IBOutlet weak var priceButton: UIButton!
    
    @IBOutlet weak var ETAButton: UIButton!
    
    var delegate: MOQSortButtonsActionProtocol?
    
    var quantityDescending = false
    var priceDescending = false
    var daysDescending = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setup() {
      super.setup()
        
      quantityButton.addTarget(self, action: #selector(quantityButtonSelected(_:)), for: .touchUpInside)
        priceButton.addTarget(self, action: #selector(priceButtonSelected(_:)), for: .touchUpInside)
        ETAButton.addTarget(self, action: #selector(ETAButtonSelected(_:)), for: .touchUpInside)
        quantityButton.tintColor = #colorLiteral(red: 0.2235294118, green: 0.368627451, blue: 0.1254901961, alpha: 1)
        priceButton.tintColor = #colorLiteral(red: 0.2235294118, green: 0.368627451, blue: 0.1254901961, alpha: 1)
        ETAButton.tintColor = #colorLiteral(red: 0.2235294118, green: 0.368627451, blue: 0.1254901961, alpha: 1)
       }

    
    public override func update() {
       super.update()
     }
    @IBAction func quantityButtonSelected(_ sender: Any) {
        if quantityDescending == false{
            self.quantityDescending = true
           // quantityButton.backgroundColor = #colorLiteral(red: 0.7411764706, green: 0.1725490196, blue: 0.1450980392, alpha: 1)
            quantityButton.setImage(UIImage.init(systemName: "arrow.down"), for: .normal)
        }else{
            self.quantityDescending = false
           //   quantityButton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            quantityButton.setImage(UIImage.init(systemName: "arrow.up"), for: .normal)
        }
      delegate?.quantityButtonSelected(tag: tag)
    }
    @IBAction func priceButtonSelected(_ sender: Any) {
        if priceDescending == false {
            priceDescending = true
            priceButton.setImage(UIImage.init(systemName: "arrow.down"), for: .normal)
        }else{
            priceDescending = false
            priceButton.setImage(UIImage.init(systemName: "arrow.up"), for: .normal)
        }
      delegate?.priceButtonSelected(tag: tag)
    }
    @IBAction func ETAButtonSelected(_ sender: Any) {
        if daysDescending == false {
            daysDescending = true
            ETAButton.setImage(UIImage.init(systemName: "arrow.down"), for: .normal)
        }else{
            daysDescending = false
            ETAButton.setImage(UIImage.init(systemName: "arrow.up"), for: .normal)
        }
      delegate?.ETAButtonSelected(tag: tag)
    }
}

final class MOQSortButtonsRow: Row<MOQSortButtonsRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<MOQSortButtonsRowView>(nibName: "MOQSortButtonsRow")
    }
   
    
}
