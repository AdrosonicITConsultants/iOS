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
    
    @IBOutlet weak var buyerDashboardView: WKWebView!
    
    let userEmail = User.loggedIn()?.email ?? ""
    var token = KeychainManager.standard.userAccessToken ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var param = "{\"ds0.email\":\"\(userEmail)\",\"ds0.Token\":\"\(token)\",\"ds44.Token\":\"\(token)\"}"
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "datastudio.google.com"
        components.path = "/embed/reporting/0ede1d26-5dbf-4564-a7c4-4f850493a89f/page/i56cB"
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
       
        buyerDashboardView.load(URLRequest(url: components.url!))
        
    }
}

