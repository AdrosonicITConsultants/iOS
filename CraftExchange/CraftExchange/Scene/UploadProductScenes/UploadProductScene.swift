//
//  UploadProductScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension UploadProductService {
    func createScene() -> UIViewController {
    
        let controller = UploadProductController.init(style: .plain)
        
        return controller
    }
}
