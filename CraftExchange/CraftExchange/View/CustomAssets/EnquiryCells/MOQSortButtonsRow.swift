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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setup() {
      super.setup()
      
      quantityButton.addTarget(self, action: #selector(quantityButtonSelected(_:)), for: .touchUpInside)
        priceButton.addTarget(self, action: #selector(priceButtonSelected(_:)), for: .touchUpInside)
        ETAButton.addTarget(self, action: #selector(ETAButtonSelected(_:)), for: .touchUpInside)
       }

    
    public override func update() {
       super.update()
     }
    @IBAction func quantityButtonSelected(_ sender: Any) {
      delegate?.quantityButtonSelected(tag: tag)
    }
    @IBAction func priceButtonSelected(_ sender: Any) {
      delegate?.priceButtonSelected(tag: tag)
    }
    @IBAction func ETAButtonSelected(_ sender: Any) {
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
