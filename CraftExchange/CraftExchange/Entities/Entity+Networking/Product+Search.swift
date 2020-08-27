//
//  Product+Search.swift
//  CraftExchange
//
//  Created by Preety Singh on 25/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Product {
    static func searchArtisanString(with searchString: String) -> Request<Data, APIError> {
        var str = "search/getArtisanSuggestions?str=\(searchString)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func searchArtisanProduct(page: Int, searchString: String, suggectionType: Int) -> Request<Data, APIError> {
      let parameters: [String: Any] = ["pageNo":page,
                                       "searchString": searchString,
                                       "searchType":suggectionType]
        return Request(
            path: "search/searchArtisanProducts",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "searchArtisanProduct failed")
              return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
