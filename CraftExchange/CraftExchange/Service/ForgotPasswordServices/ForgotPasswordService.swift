//
//  ForgotPasswordService.swift
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

class ForgotPasswordService: BaseService<Data> {

    required init() {
        super.init()
    }

    func fetch(username: String) -> SafeSignal<Data> {
      return User.sendOTP(username: username).response(using: client).debug()
    }
  
    func fetch(emailId: String, otp: String) -> SafeSignal<Data> {
      return User.verifyEmailOtp(emailId: emailId, otp: otp).response(using: client).debug()
    }
}
