//
//  SingleButtonRow.swift
//  CraftExchange
//
//  Created by Kalyan on 24/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol SingleButtonActionProtocol {
    func singleButtonSelected(tag: Int)
}

class SingleButtonRowView: Cell<String>, CellType {
    
    @IBOutlet weak var singleButton: UIButton!
    
    var delegate: SingleButtonActionProtocol?
    
  public override func setup() {
    super.setup()
    
    singleButton.addTarget(self, action: #selector(singleButtonSelected(_:)), for: .touchUpInside)
     }

  
  public override func update() {
     super.update()
   }
    @IBAction func singleButtonSelected(_ sender: Any) {
      delegate?.singleButtonSelected(tag: tag)
    }
}


final class SingleButtonRow: Row<SingleButtonRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<SingleButtonRowView>(nibName: "SingleButtonRow")
    }
   
    
}
