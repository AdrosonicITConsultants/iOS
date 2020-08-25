//
//  SearchScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension SearchService {
    func createScene() -> UIViewController {
        let vc = SearchTableViewController.init(style: .plain)
        
        vc.searchWithSearchString = {(searchString) in
            self.artisanSearch(withString: searchString).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        if let array = json["data"] as? [[String: Any]] {
                            vc.suggestionArray = array
                            var textArray: [String] = []
                            array.forEach { (suggectionObj) in
                                textArray.append("\(suggectionObj["suggestion"] as? String ?? "") in \(suggectionObj["suggestionType"] as? String ?? "")")
                            }
                            vc.dataArray = textArray
                            DispatchQueue.main.async {
                                vc.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        vc.cancelSearchAction = {
            vc.searchController?.resignFirstResponder()
//            vc.suggestionArray?.removeAll()
//            vc.dataArray.removeAll()
//            vc.tableView.reloadData()
        }
        
        return vc
    }
}
