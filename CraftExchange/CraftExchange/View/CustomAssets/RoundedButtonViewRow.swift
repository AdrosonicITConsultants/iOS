//
//  RoundedButtonViewRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol ButtonActionProtocol {
  func customButtonSelected(tag: Int)
}

class RoundedButtonView: Cell<String>, CellType {

  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var greyLineView: UIView!
  @IBOutlet var compulsoryIcon: UIImageView!
  @IBOutlet var buttonView: RoundedButton!
  var delegate: ButtonActionProtocol?
    
  public override func setup() {
    super.setup()
    buttonView.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
  }

  public override func update() {
    super.update()
    //backgroundColor = (row.value ?? false) ? .white : .black
  }
  
  @IBAction func customButtonSelected(_ sender: Any) {
    delegate?.customButtonSelected(tag: tag)
  }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class RoundedButtonViewRow: Row<RoundedButtonView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RoundedButtonView>(nibName: "RoundedButtonViewRow")
    }
}
