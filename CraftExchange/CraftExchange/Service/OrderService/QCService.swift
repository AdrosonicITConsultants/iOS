//
//  QCService.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class QCService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func fetchQCQuestions() -> SafeSignal<Data> {
        return QualityCheck.getAllQCQuestions().response(using: client).debug()
    }
    
    func fetchQCStages() -> SafeSignal<Data> {
        return QualityCheck.getAllQCStages().response(using: client).debug()
    }
    
    func fetchQCForArtisan(enquiryId: Int) -> SafeSignal<Data> {
        return QualityCheck.getArtisanQcResponse(enquiryId: enquiryId).response(using: client).debug()
    }
}
