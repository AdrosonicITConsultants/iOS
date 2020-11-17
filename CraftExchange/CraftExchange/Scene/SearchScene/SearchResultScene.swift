//
//  SearchResultScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 14/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension SearchService {
    func createResultScene(for searchString: String, suggestionType: Int) -> UIViewController {
        let vc = SearchResultController.init(style: .plain)
        
        vc.viewWillAppear = {
            if vc.reachabilityManager?.connection != .unavailable {
                searchResult(page: 1, madeWithAntaran: -1)
            }
        }
        
        func searchResult(page: Int, madeWithAntaran: Int) {
            if vc.reachabilityManager?.connection != .unavailable {
                let service = ProductCatalogService.init(client: self.client)
                if KeychainManager.standard.userRoleId == 1 {
                    service.searchArtisan(page: page, suggestion: searchString, suggestionType: suggestionType, madeWithAntaran: madeWithAntaran).bind(to: vc, context: .global(qos: .background)) {(_,responseData) in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if let dataDict = json["data"] as? [String: Any] {
                                if let array = dataDict["searchResponse"] as? [[String: Any]] {
                                    if array.count == 0 {
                                        vc.reachedSearchLimit = true
                                    }else {
                                        DispatchQueue.main.async {
                                            for objects in array {
                                                if !(vc.suggestionArray?.contains(where: { (value) -> Bool in
                                                    return value["id"] as? Int == objects["id"] as? Int
                                                }) ?? false){
                                                    vc.suggestionArray?.append(objects)
                                                }
                                            }
                                            vc.tableView.reloadData()
                                        }
                                    }
                                }else {
                                    vc.reachedSearchLimit = true
                                }
                            }
                        }
                    }.dispose(in: vc.bag)
                }else {
                    service.searchBuyerProducts(page: page, suggestion: searchString, suggestionType: suggestionType, madeWithAntaran: madeWithAntaran).bind(to: vc, context: .global(qos: .background)) {(_,responseData) in
                        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                            if let dataDict = json["data"] as? [String: Any] {
                                if let array = dataDict["searchResponse"] as? [[String: Any]] {
                                    if array.count == 0 {
                                        vc.reachedSearchLimit = true
                                    }else {
                                        DispatchQueue.main.async {
                                            for objects in array {
                                                if !(vc.suggestionArray?.contains(where: { (value) -> Bool in
                                                    return value["id"] as? Int == objects["id"] as? Int
                                                }) ?? false){
                                                    vc.suggestionArray?.append(objects)
                                                }
                                            }
                                            vc.tableView.reloadData()
                                        }
                                    }
                                }else {
                                    vc.reachedSearchLimit = true
                                }
                            }
                        }
                    }.dispose(in: vc.bag)
                }
            }else {
//                let results = Product.getSearchProducts(idList: searchIds, madeWithAntaran: catId)
            }
        }
                
        vc.refreshSearchResult = { (loadPage, madeWithAntaran) in
            searchResult(page: loadPage, madeWithAntaran: madeWithAntaran)
        }
        vc.title = "Search Results"
        
        vc.addToWishlist = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.addProductToWishlist(prodId: prodId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            appDelegate?.wishlistIds?.append(prodId)
                        }
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.removeFromWishlist = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.removeProductFromWishlist(prodId: prodId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            if let index = appDelegate?.wishlistIds?.firstIndex(where: { (obj) -> Bool in
                                obj == prodId
                            }) {
                                appDelegate?.wishlistIds?.remove(at: index)
                            }
                        }
                    }
                }
            }.dispose(in: vc.bag)
        }
        
        vc.generateEnquiry = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.checkEnquiryExists(for: vc, prodId: prodId, isCustom: false)
        }
        
        vc.generateNewEnquiry = { (prodId) in
            let service = ProductCatalogService.init(client: self.client)
            service.generateNewEnquiry(controller: vc, prodId: prodId, isCustom: false)
        }
        
        vc.showNewEnquiry = { (enquiryId) in
            let service = WishlistService.init(client: self.client)
            service.showEnquiry(enquiryId: enquiryId, controller: vc)
        }
        
        return vc
    }
}

