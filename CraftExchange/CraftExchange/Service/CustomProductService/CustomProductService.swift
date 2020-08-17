//
//  CustomProductService.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class CustomProductService: BaseService<Data> {

    required init() {
        super.init()
    }
    
    func fetchAllBuyersCustomProduct() -> SafeSignal<Data> {
      return CustomProduct.getAllBuyersCustomProduct().response(using: client).debug()
    }
    
    func deleteAllBuyersCustomProduct() -> SafeSignal<Data> {
      return CustomProduct.deleteAllCustomProducts().response(using: client).debug()
    }
}
