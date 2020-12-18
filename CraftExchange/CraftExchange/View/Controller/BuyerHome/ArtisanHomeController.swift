//
//  ArtisanHomeController.swift
//  CraftExchange
//
//  Created by Preety Singh on 16/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class HomeViewModel {
    var artisanBrandUrl = Observable<String?>("")
    var artisanName = Observable<String?>("")
    var viewDidLoad: (() -> Void)?
    var viewWillAppear: (() -> Void)?
}

class ArtisanHomeController: UIViewController {
    
    @IBOutlet weak var loggedInUserName: UILabel!
    @IBOutlet weak var artisanBrand: UIImageView!
    @IBOutlet weak var customDesignButton: RoundedButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var yourProdLbl: UILabel!
    @IBOutlet weak var yourProdListLbl: UILabel!
    private let reuseIdentifier = "ProductCategoryCell"
    var dataSource: [ProductCategory]?
    let realm = try? Realm()
    lazy var viewModel = HomeViewModel()
    var reachabilityManager = try? Reachability()
    
    override func viewDidLoad() {
        
        if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
            let service = HomeScreenService.init(client: client)
            service.getDemoVideo(vc: self)
            service.getCMSCatImages()
            service.getCMSRegionImages()
        }
        loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
        self.setupSideMenu(false)
        super.viewDidLoad()
        viewModel.viewDidLoad?()
        let rightBarButtomItem1 = UIBarButtonItem(customView: self.notificationBarButton())
        let rightBarButtomItem2 = self.searchBarButton()
        navigationItem.rightBarButtonItems = [rightBarButtomItem1, rightBarButtomItem2]
        
        loggedInUserName.text = User.loggedIn()?.firstName ?? User.loggedIn()?.userName ?? ""
        if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails.first?.logo {
            do {
                let downloadedImage = try Disk.retrieve("\(User.loggedIn()?.entityID ?? 84)/\(name)", from: .caches, as: UIImage.self)
                artisanBrand.image = downloadedImage
            }catch {
                print(error)
            }
            if self.reachabilityManager?.connection != .unavailable {
                refreshBrandLogo()
            }
        } else if self.reachabilityManager?.connection != .unavailable {
            refreshBrandLogo()
        } else {
            artisanBrand.image = UIImage.init(named: "user")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationButtonSelected(_:)), name: NSNotification.Name(rawValue: "ShowNotification"), object: nil)
    }
    
    func refreshLayout() {
        self.collectionView.reloadData()
        if dataSource?.count ?? 0 > 0 {
            yourProdLbl.text = "Your Products".localized
            yourProdListLbl.isHidden = false
        }else {
            yourProdLbl.text = "No Products Available.".localized
            yourProdListLbl.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSource = Product().getAllProductCatForUser()
        //        if dataSource?.count == 0 {
        viewModel.viewWillAppear?()
        //        }else {
        self.refreshLayout()
        //        }
    }
    
    func refreshBrandLogo() {
        if let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
            let url = URL(string: "\(KeychainManager.standard.imageBaseURL)/User/\(userID)/CompanyDetails/Logo/\(name)")
            URLSession.shared.dataTask(with: url!) { data, response, error in
                // do your stuff here...
                DispatchQueue.main.async {
                    // do something on the main queue
                    if error == nil {
                        if let finalData = data {
                            User.loggedIn()?.saveOrUpdateBrandLogo(data: finalData)
                            self.artisanBrand.image = UIImage.init(data: finalData)
                        }
                    }
                }
            }.resume()
        }
    }
    
    @IBAction func addProductSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = UploadProductService(client: client).createScene(productObject: nil)
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

extension ArtisanHomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ProductCategoryCell
        cell.categoryName.text = dataSource?[indexPath.row].prodCatDescription
        cell.categoryCover.image = UIImage.init(named: cell.categoryName.text ?? "Dupatta")
        cell.categoryName.text = dataSource?[indexPath.row].prodCatDescription?.localized
        cell.categoryCover.image = UIImage.init(named: cell.categoryName.text ?? "Dupatta")
        if let image = CMSCategoryACFSelf.getCategoryType(CategoryId: (dataSource?[indexPath.row].entityID) ?? 0)?.image, CMSCategoryACFSelf.getCategoryType(CategoryId: ((dataSource?[indexPath.row].entityID) ?? 0))?.image != "" {
            // print(image)
            if let url = URL(string: image){
                // print(url.lastPathComponent)
                if let downloadedImage = try? Disk.retrieve("\(url.lastPathComponent)", from: .caches, as: UIImage.self) {
                    cell.categoryCover.image = downloadedImage
                }
                else{
                    let url = URL(string: image)
                    URLSession.shared.dataTask(with: url!) { data, response, error in
                        // do your stuff here...
                        DispatchQueue.main.async {
                            if error == nil {
                                if let finalData = data {
                                    // do something on the main queue
                                    cell.categoryCover.image = UIImage.init(data: finalData)
                                    cell.categoryCover.contentMode = .scaleAspectFill
                                }
                            }
                        }
                    }.resume()
                }
            }
            
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ProductCatalogService(client: client).createScene(for: dataSource?[indexPath.row].entityID ?? 0)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
}

