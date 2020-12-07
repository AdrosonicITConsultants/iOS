//
//  lengthWidthRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol LengthWidthCellProtocol {
    func lengthWidthSelected(tag: Int, withValue: String)
}

class lengthWidthRowView: Cell<String>, CellType {
    
    var lengthWidthDelegate: LengthWidthCellProtocol?
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var length: UIButton!
    @IBOutlet weak var width: UIButton!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var widthTextField: UITextField!
    var option1: [String]?
    var option2: [String]?
    
    public override func setup() {
        super.setup()
        length.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
        width.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func customButtonSelected(_ sender: Any) {
        let btn = sender as! UIButton
        var options: [String] = []
        if btn.tag == 1001 || btn.tag == 2001 {
            options = option1 ?? []
        }else if btn.tag == 1002 || btn.tag == 2002 {
            options = option2 ?? []
        }
        let alert = UIAlertController.init(title: "Please select".localized, message: "", preferredStyle: .actionSheet)
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                btn.setTitle(option, for: .normal)
                self.lengthWidthDelegate?.lengthWidthSelected(tag: btn.tag, withValue: option)
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        (lengthWidthDelegate as? UIViewController)?.present(alert, animated: true, completion: nil)
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class lengthWidthRow: Row<lengthWidthRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<lengthWidthRowView>(nibName: "lengthWidthRow")
    }
}


