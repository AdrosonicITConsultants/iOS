//
//  CraftExchangeImageClient.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

public class CraftExchangeImageClient: Client {
    public init() throws {
        super.init(baseURL: KeychainManager.standard.imageBaseURL)
//        if let accessToken = KeychainManager.standard.userAccessToken {
//            defaultHeaders = ["Content-Type": "application/json",
//            "Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
//        }else {
//            defaultHeaders = ["Content-Type": "application/json",
//            "Accept": "application/json"]
//        }
    }
}
