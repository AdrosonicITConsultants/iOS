//
//  ArtisanDashboardController.swift
//  CraftExchange
//
//  Created by Kalyan on 15/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ArtisanDashboardController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var artisanDashboardView: WKWebView!
    
    let token = KeychainManager.standard.userAccessToken ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var param = "{\"ds0.Token\":\"\(token)\",\"ds2.Token\":\"\(token)\",\"ds12.Token\":\"\(token)\",\"ds16.Token\":\"\(token)\",\"ds18.Token\":\"\(token)\",\"ds22.Token\":\"\(token)\",\"ds30.Token\":\"\(token)\"}"
        print(param)
        param = param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(param)
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "datastudio.google.com"
        components.path = "/embed/reporting/cef7a3b2-e37f-48a2-9f28-0c3f45a07585/page/RJ8dB"
        components.queryItems = [URLQueryItem(name: "params", value: param), ]
       
        artisanDashboardView.load(URLRequest(url: components.url!))
        
    }
}
