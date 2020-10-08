//
//  ApprovePaymentView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 01/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka
protocol ApproveButtonProtocol {
    func ApproveBtnSelected(tag: Int)
    func RejectBtnSelected(tag: Int)
}
class ApprovePaymentView: Cell<String>, CellType{

    @IBOutlet weak var ApproveBTn: UIButton!
    @IBOutlet weak var NoteLabel: UILabel!
    @IBOutlet weak var RejectBtn: UIButton!
    var delegate: ApproveButtonProtocol?
    @IBAction func ApproveBtnSelected(_ sender: Any) {
        delegate?.ApproveBtnSelected(tag: tag)

    }
    @IBAction func RejectBtnSelected(_ sender: Any) {
        delegate?.RejectBtnSelected(tag: tag)

    }
    public override func setup() {
        super.setup()
        ApproveBTn.addTarget(self, action: #selector(ApproveBtnSelected(_:)), for: .touchUpInside)
        RejectBtn.addTarget(self, action: #selector(RejectBtnSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }

}
final class ApprovePaymentRow: Row<ApprovePaymentView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ApprovePaymentView>(nibName: "ApprovePaymentView")
    }
}
