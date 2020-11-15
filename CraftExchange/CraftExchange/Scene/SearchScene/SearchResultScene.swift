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
                searchResult(page: 1, madeWithAntaran: 0)
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
                                            vc.suggestionArray = array
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
                                            vc.suggestionArray?.append(contentsOf: array)
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
        return vc
    }
}

