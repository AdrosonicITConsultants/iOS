//
//  AdminProductCatalogueService.swift
//  CraftExchange
//
//  Created by Kalyan on 20/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class AdminProductCatalogueService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func getAllCatalogueProducts () -> SafeSignal<Data> {
      return CatalogueProduct.getAllCatalogueProducts().response(using: client).debug()
    }
}
