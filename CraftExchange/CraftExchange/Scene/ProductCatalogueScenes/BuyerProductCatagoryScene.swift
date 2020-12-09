//
//  BuyerProductCatagoryScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension ProductCatalogService {
    func createScene(madeByAntaran: Bool) -> UIViewController {
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DesignCollectionController") as! DesignCollectionController
        vc.madeByAntaran = madeByAntaran
        
        vc.viewModel.viewWillAppear = {
            self.fetchAllFilteredArtisan().bind(to: vc, context: .global(qos: .background)) { _, responseData in
                do {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                            let objArr = try JSONDecoder().decode([User].self, from: data)
                            objArr .forEach({ (cat) in
                                cat.saveOrUpdate()
                                if cat == objArr.last {
                                    DispatchQueue.main.async {
                                        vc.refreshArtisanList()
                                    }
                                }
                            })
                        }
                    }
                }catch let error as NSError {
                    print(error.description)
                }
            }.dispose(in: vc.bag)
        }
        
        return vc
    }
}
