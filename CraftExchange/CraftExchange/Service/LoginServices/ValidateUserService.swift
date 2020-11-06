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

class ValidateUserService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetch(username: String) -> SafeSignal<Data> {
      return User.validateUsername(username: username).response(using: client).debug()
    }
    
    func fetchSocialLogin(socialToken: String, socialTokenType: String) -> SafeSignal<Data> {
      return User.authenticateSocial(socialToken: socialToken, socialTokenType: socialTokenType).response(using: client).debug()
    }
}
