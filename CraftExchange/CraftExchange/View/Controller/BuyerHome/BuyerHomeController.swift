//
//  BuyerHomeController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm
import Bond
import Reachability

class BuyerHomeController: UIViewController {
    
    @IBOutlet weak var loggedInUserName: UILabel!
    @IBOutlet weak var cardBg1: UIImageView!
    @IBOutlet weak var cardBg2: UIImageView!
    @IBOutlet weak var selfDesignView: UIView!
    @IBOutlet weak var antaranDesignView: UIView!
    @IBOutlet weak var customDesignButton: RoundedButton!
    @IBOutlet weak var artisanBackground: UIImageView!
    @IBOutlet weak var antaranBackground: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var cardText: UILabel!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    lazy var viewModel = HomeViewModel()
    var reachabilityManager = try? Reachability()
    var path: String = ""
    
    override func viewDidLoad() {
        
        selfDesignView.dropShadow()
        antaranDesignView.dropShadow()
        self.selfDesignView.layer.cornerRadius = 5
        self.antaranDesignView.layer.cornerRadius = 5
        if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
            let service = HomeScreenService.init(client: client)
            service.getDemoVideo(vc: self)
            service.getCMSCatImages()
            service.getCMSRegionImages()
        }
        loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
        
        self.setupSideMenu(false)
        //        let app = UIApplication.shared.delegate as? AppDelegate
        //        if app?.showDemoVideo ?? false {
        //          app?.showDemoVideo = false
        //            if self.path != ""{
        //                showVideo(path: self.path)
        //            }
        //
        //        }
        backgroundImages()
        super.viewDidLoad()
        viewModel.viewDidLoad?()
        let rightBarButtomItem1 = UIBarButtonItem(customView: self.notificationBarButton())
        let rightBarButtomItem2 = self.searchBarButton()
        navigationItem.rightBarButtonItems = [rightBarButtomItem1, rightBarButtomItem2]
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationButtonSelected(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
    }
    
    func backgroundImages(){
        
        if let url = URL(string: KeychainManager.standard.cmsBaseURL + "/pages/64") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        if let acf = json["acf"] as?  [String: Any] {
                            if let card1 = acf["card_background_1"] as? String{
                                let url = URL(string: card1)
                                URLSession.shared.dataTask(with: url!) { data, response, error in
                                    // do your stuff here...
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            if let finalData = data {
                                                self.cardBg1.image = UIImage.init(data: finalData)
                                            }
                                        }
                                    }
                                }.resume()
                            }
//                            if let cardTitleText = acf["card_title"] as? String{
//                                DispatchQueue.main.async {
//                                    self.cardTitle.text = cardTitleText
//                                }
//                            }
                            if let cardInfo = acf["card_para2"] as? String{
                                DispatchQueue.main.async {
                                    print(cardInfo)
                                    self.cardText.text = cardInfo
                                }
                            }
                            if let card2 = acf["card_background_2"] as? String{
                                let url = URL(string: card2)
                                URLSession.shared.dataTask(with: url!) { data, response, error in
                                    // do your stuff here...
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            if let finalData = data {
                                                self.cardBg2.image = UIImage.init(data: finalData)
                                            }
                                        }
                                    }
                                }.resume()
                            }
                            if let antaranData = acf["antaran_background_extended"] as? String{
                                let url = URL(string: antaranData)
                                URLSession.shared.dataTask(with: url!) { data, response, error in
                                    // do your stuff here...
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            if let finalData = data {
                                                self.antaranBackground.image = UIImage.init(data: finalData)
                                            }
                                        }
                                    }
                                }.resume()
                            }
                            if let artisanData = acf["artisan_background_extended"] as? String{
                                let url = URL(string: artisanData)
                                URLSession.shared.dataTask(with: url!) { data, response, error in
                                    // do your stuff here...
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            if let finalData = data {
                                                self.artisanBackground.image = UIImage.init(data: finalData)
                                            }
                                        }
                                    }
                                }.resume()
                            }
                            
                        }
                        
                    }
                    
                }else{
                    return
                }
            }.resume()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.viewWillAppear?()
    }
    
    @IBAction func artisanSelfDesignSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createScene(madeByAntaran: false)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func antaranDesignSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createScene(madeByAntaran: true)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func customDesignSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = UploadProductService(client: client).createCustomProductScene(productObject: nil)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func searchSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = SearchService(client: client).createScene()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func notificationButtonSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = NotificationService(client: client).createScene()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
}
