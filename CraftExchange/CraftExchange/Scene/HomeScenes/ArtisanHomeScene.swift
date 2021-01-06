//
//  ArtisanHomeScene.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

extension HomeScreenService {
    
    func createScene() -> UIViewController {
        let storyboard = UIStoryboard(name: "ArtisanTabbar", bundle: nil)
        let tab = storyboard.instantiateViewController(withIdentifier: "ArtisanTabbarController") as! ArtisanTabbarController
        tab.modalPresentationStyle = .fullScreen
        let nav = tab.customizableViewControllers?.first as! UINavigationController
        let vc = nav.topViewController as! ArtisanHomeController
        
        self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
            print("responseString")
        }.dispose(in: vc.bag)
        
        vc.viewModel.viewDidLoad = {
            if vc.reachabilityManager?.connection != .unavailable {
                //            vc.showLoading()
                self.fetchCategoryData(vc: vc)
                self.fetchCountryData(vc: vc)
                self.fetchClusterData(vc: vc)
                self.fetchProductUploadData(vc: vc)
                self.fetchEnquiryStateData(vc: vc)
                self.handlePushNotification(vc: vc)
                self.fetchTransactionStatus(vc: vc)
                self.fetchChangeRequestData(vc: vc)
                
                self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                        {
                            if let dataDict = jsonDict["data"] as? Dictionary<String,Any> {
                                print("logged In User: \(jsonDict)")
                                guard let userObj = dataDict["user"] as? Dictionary<String,Any> else {
                                    DispatchQueue.main.async {
                                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Products".localized)")
                                    }
                                    return
                                }
                                let userData = try JSONSerialization.data(withJSONObject: userObj, options: .prettyPrinted)
                                let loggedInUser = try? JSONDecoder().decode(User.self, from: userData)
                                loggedInUser?.saveOrUpdate()
                                loggedInUser?.addressList .forEach({ (addr) in
                                    addr.saveOrUpdate()
                                })
                                loggedInUser?.paymentAccountList .forEach({ (addr) in
                                    addr.saveOrUpdate()
                                })
                                if let categoryData = dataDict["userProductCategories"] as? [[String:Any]] {
                                    let catData = try JSONSerialization.data(withJSONObject: categoryData, options: .prettyPrinted)
                                    if let userCategories = try? JSONDecoder().decode([UserProductCategory].self, from: catData) {
                                        loggedInUser?.saveOrUpdateUserCategory(catArr: userCategories)
                                    }
                                }
                                DispatchQueue.main.async {
                                    vc.loggedInUserName.text = User.loggedIn()?.firstName ?? ""
                                }
                            }else {
                                DispatchQueue.main.async {
                                    vc.hideLoading()
                                    vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Profile".localized)")
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                vc.hideLoading()
                                vc.alert("Unable to update Profile".localized)
                            }
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            vc.hideLoading()
                            vc.alert("\(error.description)")
                        }
                    }
                }.dispose(in: vc.bag)
            }
            
            vc.viewModel.viewWillAppear = {
                 self.fetchNotification(vc: vc)
                guard vc.reachabilityManager?.connection != .unavailable else {
                    DispatchQueue.main.async {
                        vc.dataSource = Product().getAllProductCatForUser()
                        vc.refreshLayout()
                    }
                    return
                }
                Product.setAllArtisanProductIsDeleteTrue()
                //            vc.dataSource = Product().getAllProductCatForUser()
                //            vc.refreshLayout()
                self.fetchAllArtisanProduct().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                    print(responseData)
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            for obj in array {
                                if let prodArray = obj["products"] as? [[String: Any]] {
                                    if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                                        if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                                            DispatchQueue.main.async {
                                                //                                        Product.setAllArtisanProductIsDeleteTrue()
                                                object .forEach { (prodObj) in
                                                    prodObj.saveOrUpdate()
                                                    if prodObj == object.last {
                                                        vc.dataSource = Product().getAllProductCatForUser()
                                                        vc.refreshLayout()
                                                        Product.deleteAllArtisanProductsWithIsDeleteTrue()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }else {
                            Product.setAllArtisanProductIsDeleteFalse()
                            vc.dataSource = Product().getAllProductCatForUser()
                            vc.refreshLayout()
                        }
                    }else {
                        Product.setAllArtisanProductIsDeleteFalse()
                        vc.dataSource = Product().getAllProductCatForUser()
                        vc.refreshLayout()
                    }
                }.dispose(in: vc.bag)
            }
        }
        return tab
    }
    
    func fetchClusterData(vc: UIViewController) {
        self.fetchAllClusters().bind(to: vc, context: .global(qos: .background)) { (_, clusterArray) in
            do {
                if (clusterArray.count > 0) {
                    clusterArray.forEach( {clusterObj in
                        clusterObj.saveOrUpdate()
                        }
                    )
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchCountryData(vc: UIViewController) {
        self.fetchAllCountries().bind(to: vc, context: .global(qos: .background)) { (_, countryArray) in
            do {
                if (countryArray.count > 0) {
                    DispatchQueue.main.async {
                        countryArray.forEach( {countryObj in
                            countryObj.saveOrUpdate()
                        })
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchCategoryData(vc: UIViewController) {
        self.fetchAllProductCategory().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([ProductCategory].self, from: data) .forEach({ (cat) in
                            cat.saveOrUpdate()
                        })
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchTransactionStatus(vc: UIViewController) {
        let service = TransactionService.init(client: client)
        service.getTransactionStatus().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([TransactionStatus].self, from: data) .forEach({ (cat) in
                            cat.saveOrUpdate()
                        })
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchProductUploadData(vc: UIViewController) {
        self.fetchProductUploadData().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let dataDictionary = json["data"] as? [String: Any] {
                        if let prodCatArray = dataDictionary["productCategories"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: prodCatArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ProductCategory].self, from: data) .forEach({ (cat) in
                                cat.saveOrUpdate()
                            })
                        }
                        if let weavesArray = dataDictionary["weaves"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: weavesArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Weave].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let yarnsArray = dataDictionary["yarns"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: yarnsArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Yarn].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let reedsArray = dataDictionary["reedCounts"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: reedsArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ReedCount].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let dyesArray = dataDictionary["dyes"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: dyesArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([Dye].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                        if let prodCareArray = dataDictionary["productCare"] as? [[String: Any]] {
                            let data = try JSONSerialization.data(withJSONObject: prodCareArray, options: .fragmentsAllowed)
                            try JSONDecoder().decode([ProductCare].self, from: data) .forEach({ (obj) in
                                obj.saveOrUpdate()
                            })
                        }
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchNotification(vc: UIViewController) {
        let service = NotificationService.init(client: client)
        service.getAllTheNotifications().bind(to: vc, context: .global(qos: .background)) { _, responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                if let dataDict = json["data"] as? Dictionary<String,Any>
                {
                    guard let notiObj = dataDict["getAllNotifications"] as? [[String: Any]] else {
                        return
                    }
                    if let notidata = try? JSONSerialization.data(withJSONObject: notiObj, options: .fragmentsAllowed) {
                        if  let notiBuyer = try? JSONDecoder().decode([Notifications].self, from: notidata) {
                            DispatchQueue.main.async {
                                if let lbl = vc.navigationController?.view.viewWithTag(666) as? UILabel {
                                    lbl.text = "\(notiBuyer.count)"
                                    UIApplication.shared.applicationIconBadgeNumber = notiBuyer.count
                                }
                            }
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func handlePushNotification(vc: UIViewController) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.requestPushNotificationAccess()
        if let object = delegate?.notificationObject {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowNotification"), object: object)
        }
    }
    
    func fetchEnquiryStateData(vc: UIViewController) {
        let service = EnquiryListService.init(client: client)
        service.getEnquiryStages().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([EnquiryStages].self, from: data) .forEach({ (stage) in
                            stage.saveOrUpdate()
                        })
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
        //getAvailableProductEnquiryStages
        service.getAvailableProductEnquiryStages().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        try array.forEach { (dataDict) in
                            if let stageDict = dataDict["orderStages"] as? [String: Any] {
                                if let data = try? JSONSerialization.data(withJSONObject: stageDict, options: .fragmentsAllowed){
                                    try JSONDecoder().decode(AvailableProductStages.self, from: data).saveOrUpdate()
                                }
                            }
                        }
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
        service.getEnquiryInnerStages().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
            do {
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if let array = json["data"] as? [[String: Any]] {
                        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
                        try JSONDecoder().decode([EnquiryInnerStages].self, from: data) .forEach({ (stage) in
                            stage.saveOrUpdate()
                        })
                    }
                }
            }catch let error as NSError {
                print(error.description)
            }
        }.dispose(in: vc.bag)
    }
    
    func fetchChangeRequestData(vc: UIViewController) {
        self.fetchChangeRequestData().bind(to: vc, context: .global(qos: .background)) { (_, changeReqArray) in
            do {
                if (changeReqArray.count > 0) {
                    changeReqArray.forEach( {CRObj in
                        CRObj.saveOrUpdate()
                        }
                    )
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func createBuyerScene() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let tab = storyboard.instantiateViewController(withIdentifier: "BuyerTabbarController") as! BuyerTabbarController
        tab.modalPresentationStyle = .fullScreen
        let nav = tab.customizableViewControllers?.first as! UINavigationController
        let vc = nav.topViewController as! BuyerHomeController
        
        self.object.bind(to: vc, context: .immediateOnMain) { _, responseString in
            print("responseString")
        }.dispose(in: vc.bag)
        
        vc.viewModel.viewDidLoad = {
            if vc.reachabilityManager?.connection != .unavailable {
                //            vc.showLoading()
                
                self.fetchCategoryData(vc: vc)
                self.fetchCountryData(vc: vc)
                self.fetchClusterData(vc: vc)
                self.fetchProductUploadData(vc: vc)
                self.fetchEnquiryStateData(vc: vc)
              //  self.fetchNotification(vc: vc)
                self.handlePushNotification(vc: vc)
                self.fetchTransactionStatus(vc: vc)
                self.fetchChangeRequestData(vc: vc)
                
                self.fetch().bind(to: vc, context: .global(qos: .background)) { (_, responseData) in
                    DispatchQueue.main.async {
                        vc.hideLoading()
                    }
                    do {
                        if let jsonDict = try JSONSerialization.jsonObject(with: responseData, options : .allowFragments) as? Dictionary<String,Any>
                        {
                            if let dataDict = jsonDict["data"] as? Dictionary<String,Any> {
                                print("logged In User: \(jsonDict)")
                                guard let userObj = dataDict["user"] as? Dictionary<String,Any> else {
                                    DispatchQueue.main.async {
                                        vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Products".localized)")
                                    }
                                    return
                                }
                                let userData = try JSONSerialization.data(withJSONObject: userObj, options: .prettyPrinted)
                                let loggedInUser = try? JSONDecoder().decode(User.self, from: userData)
                                loggedInUser?.saveOrUpdate()
                                loggedInUser?.addressList .forEach({ (addr) in
                                    addr.saveOrUpdate()
                                })
                                loggedInUser?.paymentAccountList .forEach({ (addr) in
                                    addr.saveOrUpdate()
                                })
                                DispatchQueue.main.async {
                                    vc.loggedInUserName.text = User.loggedIn()?.firstName ?? ""
                                }
                            }else {
                                DispatchQueue.main.async {
                                    vc.hideLoading()
                                    vc.alert("\(jsonDict["errorMessage"] as? String ?? "Unable to update Profile".localized)")
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                vc.hideLoading()
                                vc.alert("Unable to update Profile".localized)
                            }
                        }
                    } catch let error as NSError {
                        DispatchQueue.main.async {
                            vc.hideLoading()
                            vc.alert("\(error.description)")
                        }
                    }
                }.dispose(in: vc.bag)
            }
            
            vc.viewModel.viewWillAppear = {
                self.fetchNotification(vc: vc)
                let service = WishlistService.init(client: self.client)
                service.fetchAllWishlistProducts().observeNext { (attachment) in
                    if let json = try? JSONSerialization.jsonObject(with: attachment, options: .allowFragments) as? [String: Any] {
                        if let array = json["data"] as? [[String: Any]] {
                            var finalArray: [Int] = []
                            array.forEach { (dataDict) in
                                if let prodDict = dataDict["product"] as? [String: Any] {
                                    if let proddata = try? JSONSerialization.data(withJSONObject: prodDict, options: .fragmentsAllowed) {
                                        if let prodObj = try? JSONDecoder().decode(Product.self, from: proddata) {
                                            DispatchQueue.main.async {
                                                prodObj.saveOrUpdate()
                                                finalArray.append(prodObj.entityID)
                                                if finalArray.count == array.count {
                                                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                                        appDelegate.wishlistIds = finalArray
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }.dispose(in: vc.bag)
                if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
                    let app = UIApplication.shared.delegate as? AppDelegate
                    if let prodId = app?.shouldGenerateEnquiry, prodId != 0 {
                        let service = ProductCatalogService.init(client: self.client)
                        service.showSelectedProduct(for: vc, prodId: prodId)
                    }
                }
            }
        }
        return tab
    }
    
    func getDemoVideo(vc: UIViewController){
        if let url = URL(string: KeychainManager.standard.cmsBaseURL + "/demo-video") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: Any]] {
                        if let array = json.first {
                            if let acf = array["acf"] as?  [String: Any] {
                                if  let videoURL1 = acf["artisan_demo_video"] as? String {
                                    if    let videoURL2 = acf["buyer_demo_video"] as? String {
                                        DispatchQueue.main.async {
                                            
                                            let app = UIApplication.shared.delegate as? AppDelegate
                                            
                                            // controller.path = "\(videoURL)"
                                            if let controller = vc as? BuyerHomeController {
                                                if app?.showDemoVideo ?? false {
                                                    app?.showDemoVideo = false
                                                    controller.showVideo(path: "\(videoURL2)")}
                                            }
                                            else if let controller = vc as? ArtisanHomeController {
                                                if app?.showDemoVideo ?? false {
                                                    app?.showDemoVideo = false
                                                    controller.showVideo(path: "\(videoURL1)")
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        return
                    }
                }else {
                    return
                }
                
                
            }.resume()
        }
    }
    
    func getCMSCatImages(){
        if let url = URL(string: KeychainManager.standard.cmsBaseURL + "/categoriesselfdesign") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: Any]] {
                        DispatchQueue.main.async {
                            for obj in json  {
                                if let acf = obj["acf"] as?  [String: Any] {
                                    if let categoryData = try? JSONSerialization.data(withJSONObject: acf, options: .fragmentsAllowed) {
                                        if let object = try? JSONDecoder().decode(CMSCategoryACFSelf.self, from: categoryData) {
                                            print("hey obj: \(object)")
                                            object.saveOrUpdate()
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                }else{
                    return
                }
                
            }.resume()
        }
        
        if let url = URL(string: KeychainManager.standard.cmsBaseURL + "/categoriescodesign") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: Any]] {
                        DispatchQueue.main.async {
                            for obj in json  {
                                if let acf = obj["acf"] as?  [String: Any] {
                                    if let categoryData = try? JSONSerialization.data(withJSONObject: acf, options: .fragmentsAllowed) {
                                        if let object = try? JSONDecoder().decode(CMSCategoryACFCo.self, from: categoryData) {
                                            print("hey obj: \(object)")
                                            object.saveOrUpdate()
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                }else{
                    return
                }
                
            }.resume()
        }
        
    }
    
    func getCMSRegionImages(){
        if let url = URL(string: KeychainManager.standard.cmsBaseURL + "/regions") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String: Any]] {
                        DispatchQueue.main.async {
                            for obj in json  {
                                if let acf = obj["acf"] as?  [String: Any] {
                                    if let categoryData = try? JSONSerialization.data(withJSONObject: acf, options: .fragmentsAllowed) {
                                        if let object = try? JSONDecoder().decode(CMSRegionACF.self, from: categoryData) {
                                            print("hey obj: \(object)")
                                            object.saveOrUpdate()
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                }else{
                    return
                }
            }.resume()
        }
        
    }
    
    
}
