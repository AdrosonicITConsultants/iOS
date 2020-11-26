//
//  AdminEscalationService.swift
//  CraftExchange
//
//  Created by Preety Singh on 26/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminEscalationService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchAdminEscalation(cat: String, pageNo: Int, searchString: String) -> SafeSignal<Data> {
        return AdminEscalation.getAdminEscalations(cat: cat, pageNo: pageNo, searchString: searchString).response(using: client).debug()
    }
    
    func fetchAdminEscalationCount(cat: String, pageNo: Int, searchString: String) -> SafeSignal<Data> {
        return AdminEscalation.getAdminEscalationsCount(cat: cat, pageNo: pageNo, searchString: searchString).response(using: client).debug()
    }
}
