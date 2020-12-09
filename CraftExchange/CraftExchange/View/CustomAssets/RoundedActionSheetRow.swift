//
//  RoundedActionSheetRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 12/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class RoundedActionSheetView: Cell<String>, CellType {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: RoundedButton!
    @IBOutlet var compulsoryIcon: UIImageView!
    var options: [String]?
    var delegate: UIViewController?
    var selectedVal: String?
    
    public override func setup() {
        super.setup()
        actionButton.addTarget(self, action: #selector(actionButtonSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func actionButtonSelected(_ sender: Any) {
        
        let alert = UIAlertController.init(title: "\(titleLabel.text ?? "")", message: "Please select:".localized, preferredStyle: .actionSheet)
        for option in options ?? [] {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                self.actionButton.setTitle(option, for: .normal)
                self.row.value = option
                if self.selectedVal == option {
                    action.setValue(true, forKey: "checked")
                }
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class RoundedActionSheetRow: Row<RoundedActionSheetView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RoundedActionSheetView>(nibName: "RoundedActionSheetRow")
    }
}
