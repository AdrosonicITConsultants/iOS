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

class BuyerHomeController: UIViewController {
  
  @IBOutlet weak var loggedInUserName: UILabel!
  @IBOutlet weak var buyerCover: UIImageView!
  @IBOutlet weak var selfDesignView: UIView!
  @IBOutlet weak var antaranDesignView: UIView!
  @IBOutlet weak var customDesignButton: RoundedButton!
  
  override func viewDidLoad() {

    selfDesignView.dropShadow()
    antaranDesignView.dropShadow()
    self.selfDesignView.layer.cornerRadius = 5
    self.antaranDesignView.layer.cornerRadius = 5
    
    loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
    
    self.setupSideMenu()
    let app = UIApplication.shared.delegate as? AppDelegate
    if app?.showDemoVideo ?? false {
      app?.showDemoVideo = false
      self.showVideo()
    }
    
    super.viewDidLoad()
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
