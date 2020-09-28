//
//  BuyerDashboardController.swift
//  CraftExchange
//
//  Created by Kalyan on 15/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ImageRow
import ViewRow
import WebKit
class PreviewViewModel {
    var cgst = Observable<String?>(nil)
       var expectedDateOfDelivery = Observable<String?>(nil)
       var hsn = Observable<String?>(nil)
       var ppu = Observable<String?>(nil)
       var quantity = Observable<String?>(nil)
       var sgst = Observable<String?>(nil)
       var currency = Observable<String?>(nil)
       var sendPI: (() -> ())?

}
class InvoicePreviewController: UIViewController, WKUIDelegate {
     var sendInvoice: Int = 0
     var viewModel = PreviewViewModel()
    @IBOutlet weak var DownloadImg: UIImageView!
    var enquiryObject: Enquiry?
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var pdfView: WKWebView!
//    var bgImage: UIImageView?
    @IBAction func sendPIBtn(_ sender: Any) {
        self.viewModel.sendPI?()
    }
    
    let userEmail = User.loggedIn()?.email ?? ""
        var token = KeychainManager.standard.userAccessToken ?? ""
        let roleId = KeychainManager.standard.userRoleId!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.idLabel.text = "ProForma Invoice for: 1766"
//             enquiryObject!.enquiryId
            var image: UIImage = UIImage(named: "ios-download preview")!
            self.DownloadImg.image = image
            
        }
    }



