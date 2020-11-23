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
            components.path = "/embed/reporting/133984b5-f5c7-4b86-a1a5-89da5e85182c/page/beNoB?params"
            param = "{\"ds0.Token\":\"\(token)\",\"ds4.Token\":\"\(token)\",\"ds7.Token\":\"\(token)\",\"ds8.Token\":\"\(token)\",\"ds9.Token\":\"\(token)\"}"
        case 102:
            components.path = "/embed/reporting/a6280307-c9d1-4a70-a7b2-593b3ea9e30c/page/3qVoB?params"
            param = "{\"ds0.Token\":\"\(token)\"}"
        case 103:
            components.path = "/embed/reporting/eb79b078-f612-48d2-877b-11f1ae8dff59/page/y2VoB?params"
            param = "{\"ds0.Token\":\"\(token)\"}"
        default:
            print("Error")
        }
        
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
        dashboardView.load(URLRequest(url: components.url!))
        
    }
}

