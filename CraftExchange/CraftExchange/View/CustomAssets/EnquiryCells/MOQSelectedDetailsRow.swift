//
//  MOQSelectedDetailsRow.swift
//  CraftExchange
//
//  Created by Kalyan on 24/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol MOQButtonActionProtocol {
    func detailsButtonSelected(tag: Int)
}

class MOQSelectedDetailsRowView: Cell<String>, CellType {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var delegate: MOQButtonActionProtocol?
    
    public override func setup() {
        super.setup()
        imageButton.imageView?.layer.cornerRadius = 22.5
        
        detailsButton.addTarget(self, action: #selector(detailsButtonSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    
    
    @IBAction func detailsButtonSelected(_ sender: Any) {
        delegate?.detailsButtonSelected(tag: tag)
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class MOQSelectedDetailsRow: Row<MOQSelectedDetailsRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<MOQSelectedDetailsRowView>(nibName: "MOQSelectedDetailsRow")
    }
}



