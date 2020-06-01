//
//  ValidateWeaverService.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ValidateWeaverService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetch(weaverId: String) -> SafeSignal<Data> {
      return User.validateWeaverId(weaverId: weaverId).response(using: client).debug()
    }
}
