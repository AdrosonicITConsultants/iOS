//
//  CraftExchangeClient.swift
//  Knowledgemill
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 ADROSONIC. All rights reserved.
//

import Foundation

public class CraftExchangeClient: Client {
    public init() throws {
        super.init(baseURL: KeychainManager.standard.baseURL)
        if let accessToken = KeychainManager.standard.userAccessToken {
            defaultHeaders = ["Content-Type": "application/json",
            "Accept": "application/json", "Authorization": "Bearer \(accessToken)"]
        }else {
            defaultHeaders = ["Content-Type": "application/json",
            "Accept": "application/json"]
        }
    }
}

