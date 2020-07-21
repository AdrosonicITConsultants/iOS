//
//  RealmChanges.swift
//  Knowledgemill
//
//  Created by Monty Dudani on 13/10/19.
//  Copyright © 2019 ADROSONIC. All rights reserved.
//

import UIKit
import ReactiveKit
import Realm
import Bond
import RealmSwift

extension IndexPath {

    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }
}

extension UITableView {
    
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
        insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
        reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
        endUpdates()
    }
}

private var TableViewBinderDataSourceAssociationKey = "TableViewRealmDataSource"

class TableViewRealmDataSource<Changeset: RealmCollection>: NSObject, UITableViewDataSource {

    var createCell: ((Changeset, IndexPath, UITableView) -> UITableViewCell)?

    var changesToken: NotificationToken?

    var changeset: Changeset? = nil {
        didSet {
            changesToken?.invalidate()
            if let changeset = changeset, oldValue != nil {
                applyChangeset(changeset)
            } else {
                tableView?.reloadData()
            }
            changesToken = changeset?.observe(on: .main) { [weak tableView] changes in
              guard let tableView = tableView else { return }
              switch changes {
              case .initial: break
                //tableView.reloadData()
              case .update(let newData, let deletions, let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
              case .error: break
              }
            }
        }
    }

    weak var tableView: UITableView? = nil {
        didSet {
            guard let tableView = tableView else { return }
            associateWithTableView(tableView)
        }
    }

    var rowInsertionAnimation: UITableView.RowAnimation = .automatic
    var rowDeletionAnimation: UITableView.RowAnimation = .automatic
    var rowReloadAnimation: UITableView.RowAnimation = .automatic

    public override init() {
        createCell = nil
    }

    /// - parameter createCell: A closure that creates cell for a given table view and configures it with the given data source at the given index path.
    init(_ createCell: @escaping (Changeset, IndexPath, UITableView) -> UITableViewCell) {
        self.createCell = createCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return changeset?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let changeset = changeset else { fatalError() }
        if let createCell = createCell {
            return createCell(changeset, indexPath, tableView)
        } else {
            fatalError("Subclass of TableViewBinderDataSource should override and implement tableView(_:cellForRowAt:) method if they do not initialize `createCell` closure.")
        }
    }

    func applyChangeset(_ changeset: Changeset) {
        guard let tableView = tableView else { return }
        tableView.reloadData()
    }

    private func associateWithTableView(_ tableView: UITableView) {
        objc_setAssociatedObject(tableView, &TableViewBinderDataSourceAssociationKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if tableView.reactive.hasProtocolProxy(for: UITableViewDataSource.self) {
            tableView.reactive.dataSource.forwardTo = self
        } else {
            tableView.dataSource = self
        }
    }

    deinit {
        changesToken?.invalidate()
    }
}

extension SignalProtocol where Element: RealmCollection, Error == Never {

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - createCell: A closure that creates (dequeues) cell for the given table view and configures it with the given data source at the given index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    @discardableResult
    func bind(to tableView: UITableView, animated: Bool = true, rowAnimation: UITableView.RowAnimation = .automatic, createCell: @escaping (Element, IndexPath, UITableView) -> UITableViewCell) -> Disposable {
        if animated {
            let binder = TableViewRealmDataSource<Element>(createCell)
            binder.rowInsertionAnimation = rowAnimation
            binder.rowDeletionAnimation = rowAnimation
            binder.rowReloadAnimation = rowAnimation
            return bind(to: tableView, using: binder)
        } else {
            let binder = TableViewRealmDataSource<Element>(createCell)
            return bind(to: tableView, using: binder)
        }
    }

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - binder: A `TableViewBinder` or its subclass that will manage the binding.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    @discardableResult
    func bind(to tableView: UITableView, using binderDataSource: TableViewRealmDataSource<Element>) -> Disposable {
        binderDataSource.tableView = tableView
        return bind(to: tableView) { (_, changeset) in
            binderDataSource.changeset = changeset
        }
    }

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - cellType: A type of the cells that should display the data.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - configureCell: A closure that configures the cell with the data source item at the respective index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    ///
    /// Note that the cell type name will be used as a reusable identifier and the binding will automatically register and dequeue the cell.
    /// If there exists a nib file in the bundle with the same name as the cell type name, the framework will load the cell from the nib file.
    @discardableResult
    public func bind<Cell: UITableViewCell>(to tableView: UITableView, cellType: Cell.Type, animated: Bool = true, rowAnimation: UITableView.RowAnimation = .automatic, configureCell: @escaping (Cell, Element, IndexPath) -> Void) -> Disposable {
        let identifier = String(describing: Cell.self)
        let bundle = Bundle(for: Cell.self)
        if let _ = bundle.path(forResource: identifier, ofType: "nib") {
            let nib = UINib(nibName: identifier, bundle: bundle)
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else {
            tableView.register(cellType as AnyClass, forCellReuseIdentifier: identifier)
        }
        return bind(to: tableView, animated: animated, rowAnimation: rowAnimation, createCell: { (dataSource, indexPath, tableView) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
                fatalError(
                    "Failed to dequeue a cell with identifier \(identifier) matching type \(cellType.self). "
                        + "Check that the reuseIdentifier is set properly if using XIBs or Storyboards."
                )
            }
            configureCell(cell, dataSource, indexPath)
            return cell
        })
    }

    /// Binds the signal of data source elements to the given table view.
    ///
    /// - parameters:
    ///     - tableView: A table view that should display the data from the data source.
    ///     - cellType: A type of the cells that should display the data.
    ///     - animated: Animate partial or batched updates. Default is `true`.
    ///     - rowAnimation: Row animation for partial or batched updates. Relevant only when `animated` is `true`. Default is `.automatic`.
    ///     - configureCell: A closure that configures the cell with the data source item at the respective index path.
    /// - returns: A disposable object that can terminate the binding. Safe to ignore - the binding will be automatically terminated when the table view is deallocated.
    ///
    /// Note that the cell type name will be used as a reusable identifier and the binding will automatically register and dequeue the cell.
    /// If there exists a nib file in the bundle with the same name as the cell type name, the framework will load the cell from the nib file.
    @discardableResult
    func bind<Cell: UITableViewCell>(to tableView: UITableView, cellType: Cell.Type, using binderDataSource: TableViewRealmDataSource<Element>, configureCell: @escaping (Cell, Element, IndexPath) -> Void) -> Disposable {
        let identifier = String(describing: Cell.self)

        let bundle = Bundle(for: Cell.self)
        if let _ = bundle.path(forResource: identifier, ofType: "nib") {
            let nib = UINib(nibName: identifier, bundle: bundle)
            tableView.register(nib, forCellReuseIdentifier: identifier)
        } else {
            tableView.register(cellType as AnyClass, forCellReuseIdentifier: identifier)
        }

        binderDataSource.createCell = { (dataSource, indexPath, tableView) -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
                fatalError(
                    "Failed to dequeue a cell with identifier \(identifier) matching type \(cellType.self). "
                        + "Check that the reuseIdentifier is set properly if using XIBs or Storyboards."
                )
            }
            configureCell(cell, dataSource, indexPath)
            return cell
        }
        return bind(to: tableView, using: binderDataSource)
    }
}
