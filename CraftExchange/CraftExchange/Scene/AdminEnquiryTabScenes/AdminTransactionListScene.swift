//
//  AdminTransactionListScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit
import Eureka

extension OrderDetailsService {
    func createTransactionListScene(enquiryId: Int) -> UIViewController {
        let vc = AdminTransactionController.init(style: .plain)
        vc.enquiry = enquiryId
        vc.checkTransactions = {
            self.fetchTransactions(vc: vc, enquiryId: enquiryId)
        }
        vc.viewTransactionReceipt = { (transaction, isOld, isPI) in
            self.viewTransactionReceipt(vc: vc, transaction: transaction, isOld: isOld, isPI: isPI)
        }
        vc.downloadAdvReceipt = { (enquiryId) in
            let service = EnquiryDetailsService.init(client: self.client)
            vc.showLoading()
            service.downloadAndViewReceipt(vc: vc, enquiryId: enquiryId, typeId: 1)
        }
        vc.downloadFinalReceipt = { (enquiryId) in
           let service = EnquiryDetailsService.init(client: self.client)
           vc.showLoading()
           service.downloadAndViewReceipt(vc: vc, enquiryId: enquiryId, typeId: 2)
        }
        vc.downloadDeliveryReceipt = { (enquiryId, imageName) in
            self.viewDeliveryReceipt(vc: vc, enquiryId: enquiryId, imageName: imageName)
        }
        vc.downloadPI = { (isPI, isOld) in
            let service = EnquiryDetailsService.init(client: self.client)
            service.downloadAndSharePI(vc: vc, enquiryId: enquiryId, isPI: isPI, isOld: isOld == true ? 1 : 0)
        }
        return vc
    }
}
