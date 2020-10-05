//
//  TransactionTitleRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class TransactionTitleRow: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentStateText: UILabel!
    @IBOutlet weak var upcomingStateText: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    let invoiceStateArray = [1,2,3,4,5,12,13]
    var delegate: UIViewController!
    
    func configure(_ transaction: TransactionObject) {
        if transaction.accomplishedStatus == 1 || transaction.accomplishedStatus == 4 {
            // PI
            icon.image = UIImage.init(named: "Group 1834")
        }else if transaction.accomplishedStatus == 6 {
            // Advance Payment
            icon.image = UIImage.init(named: "Group 1834")
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
            dateLabel.text = Date().ttceFormatter(isoDate: "\(date)")
        }
        enquiryCode.text = transaction.enquiryCode ?? transaction.orderCode ?? ""
    }
}
