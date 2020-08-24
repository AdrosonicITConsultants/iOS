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
    func setupSideMenu(_ withBack: Bool) {
        let menu = UIBarButtonItem(image: UIImage(named: "Ios-menu"), style: .done, target: self, action: nil)
        menu.tintColor = .darkGray
        navigationItem.leftBarButtonItem = menu
        
        if withBack {
            let back = UIBarButtonItem(image: UIImage.init(systemName: "arrow.left"), style: .done, target: self, action: nil)
            back.tintColor = .darkGray
            navigationItem.leftBarButtonItems = [menu, back]
            
            back.reactive.tap.observeNext {
                self.navigationController?.popViewController(animated: true)
            }.dispose(in: bag)
        }else {
            navigationItem.leftBarButtonItem = menu
        }
        
        menu.reactive.tap.observeNext {
            let menuController = SideMenuController(style: .plain)
            let menu = SideMenuNavigationController(rootViewController: menuController)
            menu.setToolbarHidden(false, animated: false)
            menu.leftSide = true
            menu.statusBarEndAlpha = 0
            let style = SideMenuPresentationStyle.menuSlideIn
            style.onTopShadowOpacity = 0.8
            style.presentingScaleFactor = 0.90
            menu.settings.presentationStyle = style
            menu.settings.menuWidth = min(self.view.frame.width, self.view.frame.height) * CGFloat(0.80)
            self.present(menu, animated: true, completion: nil)
        }.dispose(in: bag)
    
    }
    
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
}
