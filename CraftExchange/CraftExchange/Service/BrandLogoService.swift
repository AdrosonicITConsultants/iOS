//
//  BrandLogoService.swift
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

class BrandLogoService: BaseService<URL> {
    var userObject: User!

    convenience init(client: SafeClient, userObject: User) {
        self.init(client: client)
        self.userObject = userObject
        if let name = userObject.buyerCompanyDetails.first?.logo {
            let prodId = userObject.entityID
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }

    override func update(_ object: URL?) {
        super.update(object)
    }

    func fetch() -> Signal<Data, Never> {
        return User.fetchBrandImage(with: userObject.entityID, name: userObject.buyerCompanyDetails.first?.logo ?? "") .response(using: client).debug()
    }
}

class chatBrandLogoService: BaseService<URL> {
    var chatObj: Chat!

    convenience init(client: SafeClient, chatObj: Chat) {
        self.init(client: client)
        self.chatObj = chatObj
        if let name = chatObj.buyerLogo {
            let prodId = chatObj.buyerId
            _object.value = try? Disk.retrieveURL("\(prodId)/\(name)", from: .caches, as: Data.self)
        }
    }

    override func update(_ object: URL?) {
        super.update(object)
    }

    func fetch() -> Signal<Data, Never> {
        
        return Chat.fetchChatBrandImage(with: chatObj.buyerId, name: chatObj.buyerLogo!).response(using: client).debug()
    }
}
