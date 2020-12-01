//
//  RoundedTextFieldRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class RoundedTextFieldView: Cell<String>, CellType {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextField: RoundedTextField!
    @IBOutlet var compulsoryIcon: UIImageView!
    
    public override func setup() {
        super.setup()
        valueTextField.delegate = self
        valueTextField.layer.borderColor = UIColor.white.cgColor
    }

    public override func update() {
        super.update()
        //backgroundColor = (row.value ?? false) ? .white : .black
    }
    
}

extension RoundedTextFieldView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typeCasteToStringFirst = textField.text as NSString?
        if let newRange = textField.selectedRange {
            let newString = typeCasteToStringFirst?.replacingCharacters(in: newRange, with: string)
            return newString?.count ?? 0 <= valueTextField.maxLength
        }
        return true
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class RoundedTextFieldRow: Row<RoundedTextFieldView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RoundedTextFieldView>(nibName: "RoundedTextFieldRow")
    }
}
