//
//  PercentPayment.swift
//  CraftExchange
//
//  Created by Kiran Songire on 29/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka

protocol BTransactionButtonProtocol {
    func TransactionBtnSelected(tag: Int)
     func ThirtyBtnSelected(tag: Int)
     func FiftyBtnSelected(tag: Int)
}

class PercentPaymentView: Cell<String>, CellType {


    @IBOutlet weak var thirtyBtn: UIButton!
    
    @IBOutlet weak var fiftyPercent: UIButton!
    @IBOutlet weak var SelectLabel: UILabel!
    
    var delegate: BTransactionButtonProtocol?
    var buttonIsSelected = false
    
    @IBOutlet weak var TransactionBtn: UIButton!
    @IBOutlet weak var AmountPlaceholder: UILabel!
    @IBOutlet weak var ActualAmount: UILabel!
        @IBAction func TransactionBtnSelected(_ sender: Any) {
        delegate?.TransactionBtnSelected(tag: tag)
    }
   
    @IBAction func ThirtyBtnSelected(_ sender: Any) {
          delegate?.ThirtyBtnSelected(tag: tag)
        thirtyBtn.layer.borderWidth = 2.0
        thirtyBtn.layer.borderColor = UIColor.green.cgColor
        fiftyPercent.layer.borderWidth = 0
        thirtyBtn.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        fiftyPercent.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.6156862745, blue: 0.1411764706, alpha: 1)
    }
    @IBAction func FiftyBtnSelected(_ sender: Any) {
          delegate?.FiftyBtnSelected(tag: tag)
        thirtyBtn.layer.borderWidth = 0
        fiftyPercent.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        thirtyBtn.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.6156862745, blue: 0.1411764706, alpha: 1)
        fiftyPercent.layer.borderWidth = 2.0
       fiftyPercent.layer.borderColor = UIColor.green.cgColor
        
      }
   
    public override func setup() {
        super.setup()
        TransactionBtn.addTarget(self, action: #selector(TransactionBtnSelected(_:)), for: .touchUpInside)
        thirtyBtn.addTarget(self, action: #selector(ThirtyBtnSelected(_:)), for: .touchUpInside)
        fiftyPercent.addTarget(self, action: #selector(FiftyBtnSelected(_:)), for: .touchUpInside)
        
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class PercentPaymentRow: Row<PercentPaymentView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<PercentPaymentView>(nibName: "PercentPayment")
    }
}
