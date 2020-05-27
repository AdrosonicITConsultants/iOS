//
//  ValidateUserService.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ValidateUserService: BaseService<String> {

    required init() {
        super.init()
    }

    func fetch(username: String) -> SafeSignal<String> {
      return User.validateUsername(username: username).response(using: client).debug()
    }
}
