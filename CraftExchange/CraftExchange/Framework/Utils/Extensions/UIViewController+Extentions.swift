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
