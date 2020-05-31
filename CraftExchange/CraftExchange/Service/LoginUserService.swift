//
//  LoginUserService.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class LoginUserService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetch(username: String, password: String) -> SafeSignal<Data> {
      return User.authenticate(username: username, password: password).response(using: client).debug()
    }
}
