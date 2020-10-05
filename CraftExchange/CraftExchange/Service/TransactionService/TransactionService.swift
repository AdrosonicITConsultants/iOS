//
//  TransactionService.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class TransactionService: BaseService<Data> {

    required init() {
        super.init()
    }
    func getAllOngoingTransactions() -> SafeSignal<Data> {
        return TransactionObject.getAllOngoingTransaction().response(using: client).debug()
    }
    func getTransactionStatus() -> SafeSignal<Data> {
        return TransactionStatus.getTransactionStatus().response(using: client).debug()
    }
}

