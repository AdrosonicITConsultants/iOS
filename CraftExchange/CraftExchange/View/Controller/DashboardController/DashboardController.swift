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

class DashboardController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var dashboardView: WKWebView!
    
    let userEmail = User.loggedIn()?.email ?? ""
    var token = KeychainManager.standard.userAccessToken ?? ""
    let roleId = KeychainManager.standard.userRoleId!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var param = " "
        var components = URLComponents()
        components.scheme = "https"
        components.host = "datastudio.google.com"
        
       
        if roleId == 1 {
            components.path = "/embed/reporting/0c128fc7-917e-4030-b7b4-370628de1996/page/CEweB"
            param = "{\"ds0.Token\":\"\(token)\",\"ds2.Token\":\"\(token)\",\"ds12.Token\":\"\(token)\",\"ds16.Token\":\"\(token)\",\"ds18.Token\":\"\(token)\",\"ds22.Token\":\"\(token)\",\"ds30.Token\":\"\(token)\"}"
        }else {
            components.path = "/embed/reporting/22dd8e4d-ca54-4a5a-8084-571f9b776457/page/iJ7cB"
            param = "{\"ds0.email\":\"\(userEmail)\",\"ds0.Token\":\"\(token)\",\"ds44.Token\":\"\(token)\"}"
        }
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
        dashboardView.load(URLRequest(url: components.url!))
        
    }
}

