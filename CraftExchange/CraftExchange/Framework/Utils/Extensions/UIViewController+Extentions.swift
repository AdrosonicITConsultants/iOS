//
//  Extentions.swift
//  AdroCafe
//
//  Created by Monty Dudani on 02/04/19.
//  Copyright © 2019 ADROSONIC. All rights reserved.
//

import UIKit
import JGProgressHUD
import ReactiveKit
import SideMenu
import AVKit

// Makes UIViewController a LoadingStateListener. That means that we can pass an instance of UIViewController
// to `consumeLoadingState` operator of a LoadingSignal to convert it into regular SafeSignal.
// Loading state is "consumed" by the view controller by displaying the loading indicator when needed.

extension UIViewController {
    
    func alert(_ title: String? = nil, _ message: String? = nil, callback: ((UIAlertAction) -> ())? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: callback))
        self.present(vc, animated: true, completion: nil)
    }

    func confirmAction(_ title: String? = nil, _ message: String,
                       confirmedCallback: ((UIAlertAction) -> ())?,
                       cancelCallBack: ((UIAlertAction) -> ())? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: cancelCallBack))
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: confirmedCallback))
        self.present(vc, animated: true, completion: nil)
    }
    
    func confirmActionWithCustomButtons(_ title: String? = nil, _ message: String, cancelBtnTitle: String? = nil, confirmBtnTitle: String? = nil,
                       confirmedCallback: ((UIAlertAction) -> ())?,
                       cancelCallBack: ((UIAlertAction) -> ())? = nil) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: cancelBtnTitle, style: .default, handler: cancelCallBack))
        vc.addAction(UIAlertAction(title: confirmBtnTitle, style: .cancel, handler: confirmedCallback))
        self.present(vc, animated: true, completion: nil)
    }
    
    func showRatingSlider(sliderVal: Float) {
        let alert = UIAlertController.init(title: "Update Rating", message: "", preferredStyle: .alert)
        
        let slider = UISlider.init(frame: CGRect.init(x: 70, y: 35, width: 120, height: 30))
        slider.minimumValue = 0.0
        slider.maximumValue = 10.0
        slider.value = sliderVal
        slider.tintColor = UIColor.red
        slider.addTarget(self, action: #selector(ratingChanged(_:)), for: .valueChanged)
        alert.view.addSubview(slider)
        
        if let handleView = slider.subviews.last as? UIImageView {
            let val = (slider.value * 10).rounded(.toNearestOrEven) / 10

            if let label = handleView.viewWithTag(1000) as? UILabel {
                label.text = "\(val)"
            }else {
                let label = UILabel.init(frame: handleView.bounds)
                label.tag = 1000;

                label.font = .systemFont(ofSize: 12)
                label.textColor = .red
                label.backgroundColor = .clear
                label.text = "\(val)"
                
                label.textAlignment = .center
                handleView.addSubview(label)
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
        }))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let vc = self as? AdminUserDetailController {
                if vc.userObject?.rating != slider.value {
                    let val = (slider.value * 10).rounded(.toNearestOrEven) / 10
                    vc.ratingBtn.setTitle(" Rating \(val)", for: .normal)
                    vc.viewModel.updateRating?(val)
                }
            }else if let vc = self as? AdminBuyerUserDetailController {
                if vc.userObject?.rating != slider.value {
                    let val = (slider.value * 10).rounded(.toNearestOrEven) / 10
                    vc.ratingBtn.setTitle(" Rating \(val)", for: .normal)
                    vc.viewModel.updateRating?(val)
                }
            }
        }))
        alert.view.center = self.view.center
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc @IBAction func ratingChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            if let handleView = slider.subviews.last as? UIImageView {
                let val = (slider.value * 10).rounded(.toNearestOrEven) / 10

                if let label = handleView.viewWithTag(1000) as? UILabel {
                    label.text = "\(val)"
                }else {
                    let label = UILabel.init(frame: handleView.bounds)
                    label.tag = 1000;

                    label.font = .systemFont(ofSize: 12)
                    label.textColor = .red
                    label.backgroundColor = .clear
                    label.text = "\(val)"
                    
                    label.textAlignment = .center
                    handleView.addSubview(label)
                }
            }
        }
    }
    
    func showImagePickerAlert() {
        let alert = UIAlertController.init(title: "Please Select:".localized, message: "Options:".localized, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Camera".localized, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker =  UIImagePickerController()
                imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alert.addAction(action1)
        let action2 = UIAlertAction.init(title: "Gallery".localized, style: .default) { (action) in
          let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
          imagePicker.sourceType = .photoLibrary
          self.present(imagePicker, animated: true, completion: nil)
        }
        alert.addAction(action2)
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
    
    func sharePdf(path:URL) {

        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: path.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            print("document was not found")
            self.alert("Error", "Document was not found") { (action) in
                
            }
        }
    }
}

extension UIViewController {
  func roleBarButton() -> UIBarButtonItem {
    let rightButtonItem = UIBarButtonItem.init(
        title: "\(KeychainManager.standard.userRole ?? "")",
        style: .plain,
        target: self,
        action: nil
    )
    rightButtonItem.tintColor = .darkGray
    return rightButtonItem
  }
    
    func notificationBarButton() -> UIButton {
        let badgeCount = UILabel(frame: CGRect(x: 10, y: -05, width: 15, height: 15))
        badgeCount.layer.borderColor = UIColor.clear.cgColor
        badgeCount.layer.borderWidth = 2
        badgeCount.layer.cornerRadius = badgeCount.bounds.size.height / 2
        badgeCount.textAlignment = .center
        badgeCount.layer.masksToBounds = true
        badgeCount.textColor = .white
        badgeCount.font = badgeCount.font.withSize(10)
        badgeCount.backgroundColor = .red
        badgeCount.text = "\(UIApplication.shared.applicationIconBadgeNumber)"
        badgeCount.tag = 666


        let rightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        rightBarButton.tintColor = .lightGray
        rightBarButton.setBackgroundImage(UIImage(named: "ios_bell"), for: .normal)
        rightBarButton.addTarget(self, action: #selector(self.notificationButtonSelected), for: .touchUpInside)
        rightBarButton.addSubview(badgeCount)
        
        return rightBarButton
    }
    
    @objc func notificationButtonSelected() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = AdminNotificationService(client: client).createScene()
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func searchBarButton() -> UIBarButtonItem {
        let rightButtonItem = UIBarButtonItem.init(
          image: UIImage(named: "ios_search"),
          style: .plain,
          target: self,
          action: #selector(self.searchSelected)
        )
        rightButtonItem.tintColor = .darkGray
        rightButtonItem.image = UIImage(named: "ios_search")
      return rightButtonItem
    }
    
    @objc func searchSelected() {
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

extension UIViewController: LoadingStateListener {

    public func setLoadingState<LoadingValue, LoadingError>(_ state: ObservedLoadingState<LoadingValue, LoadingError>) {
        switch state {
        case .loading:
            showLoading()
        case .reloading:
            showLoading()
        case .loaded:
            hideLoading()
        case .failed:
            loadingFailed()
        }
    }
}

extension UIViewController {

    var inNavigation: UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
    }
}

extension UIViewController {

    @objc func showLoading() {
        let view = self.view
        if let hud = JGProgressHUD.allProgressHUDs(in: view!).first {
            hud.accessibilityLabel = "progressHUD"
            guard !hud.isVisible else { return }
            hud.show(in: view!, animated: true)
        } else {
            let hud = JGProgressHUD(style: .extraLight)
            hud.position = .center
            hud.show(in: view!, animated: true)
        }
    }

    @objc func hideLoading() {
        let view = self.view
        guard let hud = JGProgressHUD.allProgressHUDs(in: view!).first else { return }
        guard hud.isVisible else { return }
        hud.dismiss(animated: true)
    }

    @objc func loadingFailed() {
        let view = self.view
        guard let hud = JGProgressHUD.allProgressHUDs(in: view!).first else { return }
        guard hud.isVisible else { return }
        hud.dismiss(animated: true)
    }
}

extension UIViewController {
    
    func setupSearch() {
      let resultsTableController = UITableViewController(style: .plain)
      
      resultsTableController.tableView.delegate = self as? UITableViewDelegate
      
      let searchController = UISearchController(searchResultsController: resultsTableController)
      // searchController.searchResultsUpdater = self
      
      searchController.searchBar.autocapitalizationType = .none
      if #available(iOS 11.0, *) {
          // For iOS 11 and later, place the search bar in the navigation bar.
          navigationItem.searchController = searchController
          
          // Make the search bar always visible.
          navigationItem.hidesSearchBarWhenScrolling = false
      }
      
      // searchController.delegate = self
      searchController.obscuresBackgroundDuringPresentation = false // The default is true.
      // searchController.searchBar.delegate = self // Monitor when the search button is tapped.
      
      /** Search presents a view controller by applying normal view controller presentation semantics.
       This means that the presentation moves up the view controller hierarchy until it finds the root
       view controller or one that defines a presentation context.
       */
      
      /** Specify that this view controller determines how the search controller is presented.
       The search controller should be presented modally and match the physical size of this view controller.
       */
      definesPresentationContext = true
  }
    
    /// pop back to specific viewcontroller
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
}

extension UIViewController {
    func refreshAllCounts() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let service = AdminHomeScreenService(client: client)
            service.getEnquiryAndOrderCount(vc: self)
        } catch let error {
          print("Unable to load view:\n\(error.localizedDescription)")
        }
    }
}
