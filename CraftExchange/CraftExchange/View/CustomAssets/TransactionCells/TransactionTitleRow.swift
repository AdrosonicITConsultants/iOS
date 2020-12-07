//
//  TransactionTitleRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class TransactionTitleRow: Cell<String>, CellType {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentStateText: UILabel!
    @IBOutlet weak var upcomingStateText: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    var delegate: UIViewController!
    
    func configure(_ transaction: TransactionObject) {
        if transaction.accomplishedStatus == 1 || transaction.accomplishedStatus == 4 {
            // PI
            icon.image = UIImage.init(named: "Group 1837")
        }else if transaction.accomplishedStatus == 6 {
            //PI & Advance Payment
            icon.image = UIImage.init(named: "Group 1853")
        }else if transaction.accomplishedStatus == 12 || transaction.accomplishedStatus == 14 {
            //Tax Invoice received & Tax Invoice receipt Upload
            icon.image = UIImage.init(named: "Group 1834")
        }else if transaction.accomplishedStatus == 8 || transaction.accomplishedStatus == 10 {
            //Advance Payment
            if(transaction.upcomingStatus == 11){
                icon.image = UIImage.init(named: "Group 1833")
            }else{
                icon.image = UIImage.init(named: "Group 1832")
            }
        }else if transaction.accomplishedStatus == 16 || transaction.accomplishedStatus == 18 {
            //Final Payment
            if(transaction.upcomingStatus == 17){
                icon.image = UIImage.init(named: "Group 1834")
            }else{
                icon.image = UIImage.init(named: "Group 1840")
            }
        }else if transaction.accomplishedStatus == 20 || transaction.accomplishedStatus == 22 {
            //Delivery Challan Upload
            icon.image = UIImage.init(named: "Group 1835")
        }else if transaction.accomplishedStatus == 23 {
            //Order Delivered
            icon.image = UIImage.init(named: "Group 1860")
        }else {
            icon.image = UIImage.init(named: "Group 1834")
        }
        
        if User.loggedIn()?.refRoleId == "1" {
            //Artisan
            currentStateText.attributedText = TransactionStatus.getTransactionStatusType(searchId: transaction.accomplishedStatus)?.artisanText?.htmlToAttributedString
            upcomingStateText.attributedText = TransactionStatus.getTransactionStatusType(searchId: transaction.upcomingStatus)?.artisanText?.htmlToAttributedString
        }else {
            currentStateText.attributedText = TransactionStatus.getTransactionStatusType(searchId: transaction.accomplishedStatus)?.buyerText?.htmlToAttributedString
            upcomingStateText.attributedText = TransactionStatus.getTransactionStatusType(searchId: transaction.upcomingStatus)?.buyerText?.htmlToAttributedString
        }
        if let date = transaction.modifiedOn {
            dateLabel.text = Date().ttceISOString(isoDate: date)
        }
        enquiryCode.text = transaction.enquiryCode ?? transaction.orderCode ?? ""
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class TransactionTitleRowView: Row<TransactionTitleRow>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<TransactionTitleRow>(nibName: "TransactionTitleRow")
    }
}
