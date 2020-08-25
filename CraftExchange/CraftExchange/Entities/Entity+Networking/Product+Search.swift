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
}
