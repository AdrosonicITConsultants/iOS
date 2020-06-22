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
  func setupSideMenu() {
    let menu = UIBarButtonItem(image: UIImage(named: "Ios-menu"), style: .done, target: self, action: nil)
    menu.tintColor = .darkGray
    navigationItem.leftBarButtonItem = menu
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
}
