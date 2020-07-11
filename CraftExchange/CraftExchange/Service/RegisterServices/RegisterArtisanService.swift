//
//  RegisterArtisanService.swift
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

class RegisterArtisanService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetch(newUser: [String:Any]) -> SafeSignal<Data> {
      return User.registerUser(json: newUser).response(using: client).debug()
    }
}
