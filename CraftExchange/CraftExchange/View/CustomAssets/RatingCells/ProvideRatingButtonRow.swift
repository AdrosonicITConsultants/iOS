//
//  ProvideRatingButtonRow.swift
//  CraftExchange
//
//  Created by Kalyan on 11/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol ProvideRatingButtonProtocol {
    func provideRatingButtonSelected(tag: Int)
}


class ProvideRatingButtonRowView: Cell<String>, CellType {
    
    @IBOutlet weak var provideRatingButton: UIButton!
    var delegate: ProvideRatingButtonProtocol?
    
    public override func setup() {
        super.setup()
        provideRatingButton.addTarget(self, action: #selector(provideRatingButtonSelected), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func provideRatingButtonSelected(_sender: Any) {
        delegate?.provideRatingButtonSelected(tag: tag)
    }
}

final class ProvideRatingButtonRow: Row<ProvideRatingButtonRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProvideRatingButtonRowView>(nibName: "ProvideRatingButtonRow")
    }
}
