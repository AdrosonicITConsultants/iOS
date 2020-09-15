//
//  BuyerHomeController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class BuyerHomeController: UIViewController {
  
    @IBOutlet weak var loggedInUserName: UILabel!
    @IBOutlet weak var buyerCover: UIImageView!
    @IBOutlet weak var selfDesignView: UIView!
    @IBOutlet weak var antaranDesignView: UIView!
    @IBOutlet weak var customDesignButton: RoundedButton!
  
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    
    lazy var viewModel = HomeViewModel()
    var reachabilityManager = try? Reachability()
    
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
    override func viewDidLoad() {

    selfDesignView.dropShadow()
    antaranDesignView.dropShadow()
    self.selfDesignView.layer.cornerRadius = 5
    self.antaranDesignView.layer.cornerRadius = 5
    
    loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
    
    self.setupSideMenu(false)
    let app = UIApplication.shared.delegate as? AppDelegate
    if app?.showDemoVideo ?? false {
      app?.showDemoVideo = false
      self.showVideo()
    }
    
    super.viewDidLoad()
    viewModel.viewDidLoad?()
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
}
