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
        var param = ""
        var components = URLComponents()
        components.scheme = "https"
        components.host = "datastudio.google.com"
        
        let app = UIApplication.shared.delegate as? AppDelegate
        let type = app?.dashboardType
        
        switch type {
        case 101:
            components.path = "/embed/reporting/324a5edd-e197-40bc-99f7-77a37a525710/page/jj0gB?params"
            param = "{\"ds0.Token\":\"\(token)\",\"ds4.Token\":\"\(token)\",\"ds7.Token\":\"\(token)\",\"ds8.Token\":\"\(token)\",\"ds9.Token\":\"\(token)\"}"
        case 102:
            components.path = "/embed/reporting/00758bf8-9835-4bc1-aa7d-c2fb328332ab/page/wVxhB?params"
            param = "{\"ds0.Token\":\"\(token)\"}"
        case 103:
            components.path = "/embed/reporting/c66a317a-4b2d-4442-a326-3f0a6b4cd947/page/u7NhB?params"
            param = "{\"ds0.Token\":\"\(token)\"}"
        default:
            print("Error")
        }
        
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
        dashboardView.load(URLRequest(url: components.url!))
        
    }
}

