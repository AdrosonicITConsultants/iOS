//
//  MyProfileService.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class MyProfileService: BaseService<Data> {

    required init() {
        super.init()
    }

    override func fetch() -> SafeSignal<Data> {
      return User.getProfile().response(using: client).debug()
    }
}
