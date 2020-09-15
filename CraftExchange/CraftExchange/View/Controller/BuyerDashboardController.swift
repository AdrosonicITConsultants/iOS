//
//  BuyerDashboardController.swift
//  CraftExchange
//
//  Created by Kalyan on 15/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class BuyerDashboardController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var dashboardView: WKWebView!
    
    let userEmail = User.loggedIn()?.email ?? ""
    var token = KeychainManager.standard.userAccessToken ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let params = Params(ds0Email: userEmail, ds0Token: token, ds44Token: token)
        let encoder = JSONEncoder()
        let paramData: Data? = try? encoder.encode(params)
        
        let str = String(decoding: paramData!, as: UTF8.self)
        var param = "{\"ds0.email\":\(userEmail),\"ds0.Token\":\(token),\"ds44.Token\":\(token)"
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "datastudio.google.com"
        components.path = "/embed/reporting/0ede1d26-5dbf-4564-a7c4-4f850493a89f/page/i56cB"
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
        print(str)
        print(components.url!)
        dashboardView.load(URLRequest(url: components.url!))
        
    }
}


struct Params: Encodable {
    let ds0Email: String
    let ds0Token: String
    let ds44Token: String

    enum CodingKeys: String, CodingKey {
        case ds0Email = "ds0.email"
        case ds0Token = "ds0.Token"
        case ds44Token = "ds44.Token"
    }
}
