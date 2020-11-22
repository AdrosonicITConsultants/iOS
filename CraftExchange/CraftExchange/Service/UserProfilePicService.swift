//
//  UserProfilePicService.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import Realm
import RealmSwift

class UserProfilePicService: BaseService<URL> {
    var userObject: User?

    convenience init(client: SafeClient, userObject: User) {
        self.init(client: client)
        self.userObject = userObject
        if let name = userObject.profilePic {
            let prodId = userObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }

    override func update(_ object: URL?) {
        super.update(object)
    }

    func fetch() -> Signal<Data, Never> {
        return User.fetchProfileImage(with: userObject?.entityID ?? 0, name: userObject?.profilePic ?? "") .response(using: client).debug()
    }
    
    func fetch(forUser: Int, img: String) -> Signal<Data, Never> {
        return User.fetchProfileImage(with: forUser, name: img) .response(using: client).debug()
    }
}

