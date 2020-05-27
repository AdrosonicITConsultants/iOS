//
//  ReactiveExtentions.swift
//  Knowledgemill
//
//  Created by Monty Dudani on 18/10/19.
//  Copyright © 2019 ADROSONIC. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import UIKit

extension ReactiveExtensions where Base: UIViewController {
    public var userErrors: Bond<UserFriendlyError> {
        return bond { vc, error in
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            if let retry = error.retry {
                let action = UIAlertAction(title: "Retry", style: .default) { _ in
                    retry.send()
                }
                alert.addAction(action)
            }
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
            alert.addAction(dismissAction)
            vc.present(alert, animated: true)
        }
    }
    
    public var logoutError: Bond<UserFriendlyError> {
        return bond { vc, error in
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            if let retry = error.retry {
                let action = UIAlertAction(title: "Retry", style: .default) { _ in
                    retry.send()
                }
                alert.addAction(action)
            }
            let dismissAction = UIAlertAction(title: "Logout", style: .cancel) { _ in
                KeychainManager.standard.deleteAll()
            }
            alert.addAction(dismissAction)
            vc.present(alert, animated: true)
        }
    }
}

public enum ViewController {}

public protocol SetupProtocol: AnyObject {}

extension SetupProtocol {
    @discardableResult
    public func setup(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}

extension SetupProtocol where Self: UIView {
    public var autoLayouting: Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    public func setup(_ configure: (Self) -> Void = { _ in }) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        configure(self)
        return self
    }
}

extension NSObject: SetupProtocol {}

extension UITableViewCell {
    public static var classReuseIdentifier: String {
        return String(describing: type(of: self))
    }
}

extension ReactiveExtensions where Base: UITableView {
    public var prefetchDataSource: ProtocolProxy {
        return protocolProxy(for: UITableViewDataSourcePrefetching.self, keyPath: \.prefetchDataSource)
    }

    public var didEndDisplaying: SafeSignal<IndexPath> {
        return prefetchDataSource.signal(for: #selector(UITableViewDelegate.tableView(_:didEndDisplaying:forRowAt:))) { (subject: PassthroughSubject<IndexPath, Never>, _: UITableView, _: UITableViewCell, indexPath: IndexPath) in
            subject.send(indexPath)
        }
    }

    public var prefetchRowsAt: SafeSignal<[IndexPath]> {
        return prefetchDataSource.signal(for: #selector(UITableViewDataSourcePrefetching.tableView(_:prefetchRowsAt:))) { (subject: PassthroughSubject<[IndexPath], Never>, _: UITableView, indexPaths: [IndexPath]) in
            subject.send(indexPaths)
        }
    }

    var willDisplayCell: SafeSignal<IndexPath> {
        return delegate
            .signal(for: #selector(UITableViewDelegate.tableView(_:willDisplay:forRowAt:))) {
                (subject: ReactiveKit.PassthroughSubject<IndexPath, Never>, _: UITableView, _: UITableViewCell,
                 indexPath: IndexPath) in
                subject.send(indexPath)
            }
    }
    
    var deselectedRowIndexPath: SafeSignal<IndexPath> {
        return delegate
            .signal(for: #selector(UITableViewDelegate.tableView(_:didDeselectRowAt:))) {
                (subject: ReactiveKit.PassthroughSubject<IndexPath, Never>, _: UITableView, indexPath: IndexPath) in
                subject.send(indexPath)
            }
    }

    public var cancelPrefetchingForRowsAt: SafeSignal<[IndexPath]> {
        return prefetchDataSource.signal(for: #selector(UITableViewDataSourcePrefetching.tableView(_:cancelPrefetchingForRowsAt:))) { (subject: PassthroughSubject<[IndexPath], Never>, _: UITableView, indexPaths: [IndexPath]) in
            subject.send(indexPaths)
        }
    }

    var didEndDragging: SafeSignal<Bool> {
        return delegate
            .signal(for: #selector(UITableViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))) {
                (subject: ReactiveKit.PassthroughSubject<Bool, Never>, _: UIScrollView, decelerate: Bool) in
                subject.send(decelerate)
            }
    }

    var didEndDecelerating: SafeSignal<Void> {
        return delegate
            .signal(for: #selector(UITableViewDelegate.scrollViewDidEndDecelerating(_:))) {
                (subject: ReactiveKit.PassthroughSubject<Void, Never>, _: UIScrollView) in
                subject.send()
            }
    }
}
