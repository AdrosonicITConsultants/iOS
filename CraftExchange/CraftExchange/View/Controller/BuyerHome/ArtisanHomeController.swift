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
    private let reuseIdentifier = "ProductCategoryCell"
    var dataSource: [ProductCategory]?
    let realm = try? Realm()
    lazy var viewModel = HomeViewModel()
    var reachabilityManager = try? Reachability()
    @IBAction func notificationButtonSelected(_ sender: Any) {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = NotificationService(client: client).createArtisanScene()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
  override func viewDidLoad() {

    loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
    self.setupSideMenu(false)
    let app = UIApplication.shared.delegate as? AppDelegate
    if app?.showDemoVideo ?? false {
      app?.showDemoVideo = false
      self.showVideo()
    }
    super.viewDidLoad()
    
    viewModel.viewDidLoad?()
    
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
  }
    
    func refreshLayout() {
        self.collectionView.reloadData()
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

  func showVideo() {
    let path = Bundle.main.path(forResource: "video", ofType: "mp4")
    let url = NSURL(fileURLWithPath: path!)
    let player = AVPlayer(url: url as URL)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player

    present(playerViewController, animated: true, completion: {
        playerViewController.player!.play()
    })
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
}

extension ArtisanHomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! ProductCategoryCell
        cell.categoryName.text = dataSource?[indexPath.row].prodCatDescription
        cell.categoryCover.image = UIImage.init(named: cell.categoryName.text ?? "Dupatta")
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

