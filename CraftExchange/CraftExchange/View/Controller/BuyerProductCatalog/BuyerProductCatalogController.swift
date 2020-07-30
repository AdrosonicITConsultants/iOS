//
//  BuyerProductCatalogController.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import RealmSwift
import Realm
import Bond
import Reachability

class BuyerProductCatalogController: UIViewController {

    let reuseIdentifier = "BuyerProductCell"
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
    var refreshFilter: ((_ catId: Int) -> ())?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var brandLogoImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var brandLogoHtConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHtConstraint: NSLayoutConstraint!
    
    var allPorducts: Results<Product>?
    var selectedCluster: ClusterDetails?
    var selectedCategory: ProductCategory?
    var selectedArtisan: User?
    var madeByAntaran: Int = 0
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        if let cluster = selectedCluster {
            self.titleLabel.text = cluster.clusterDescription
            self.titleLabel.isHidden = false
            filterButton.setTitle("Filter by category".localized, for: .normal)
            brandLogoHtConstraint.constant = 80
            brandLogoImage.isHidden = true
            descriptionLabel.text = getClusterDescription()//cluster.adjective
            self.titleLabel.addImageWith(name: "ring _of_string-ios", behindText: ((self.titleLabel?.text) != nil))
        }else if let category = selectedCategory {
            self.titleLabel.text = category.prodCatDescription
            self.titleLabel.isHidden = false
            filterButton.setTitle("Filter by region".localized, for: .normal)
            brandLogoHtConstraint.constant = 80
            brandLogoImage.isHidden = true
            descriptionLabel.text = category.prodCatDescription
        }else if let artisan = selectedArtisan {
            self.brandLogoImage.image = UIImage.init(named: "user")
            self.titleLabel.text = ""
            self.titleLabel.isHidden = true
            brandLogoHtConstraint.constant = 120
            brandLogoImage.isHidden = false
            if let title = artisan.buyerCompanyDetails.first?.companyName, artisan.buyerCompanyDetails.first?.companyName != "" {
                self.title = title
            }else {
                self.title = artisan.firstName
            }
            descriptionLabel.text = "By \(artisan.firstName ?? "") \(artisan.lastName ?? "") from \(artisan.cluster?.clusterDescription ?? "")"
            filterButton.setTitle("Filter by category".localized, for: .normal)
            setBrandLogo()
        }
        
        filterButton.layer.borderColor = UIColor.lightGray.cgColor
        filterButton.layer.borderWidth = 1.0
        filterButton.dropShadow()
        descriptionHtConstraint.constant = heightForView(text: descriptionLabel.text ?? "", width: self.view.bounds.width)
        try? reachabilityManager?.startNotifier()
        
        definesPresentationContext = false
        
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        setDatasource(withId: 0)
    }
    
    func getClusterDescription() -> String {
        switch selectedCluster?.entityID {
        case 1:
            return "Maniabandha in Cuttack is known for single weft ikat weaving - particularly the “khandua patta” woven for Lord Jagnath."
        case 2:
            return "A coastal village of Odisha, on banks of Brahmani river, Gopalpur is a Tussar weave cluster."
        case 3:
            return "Part of Nellore district of Andhra, Venktagiri  is famous for fine handloom cotton and silk saris, dupattas."
        case 4:
            return "A district in Assam, on the banks of Brahmaputra river, Kamrup is the leading eri silk cluster of India."
        case 5:
            return "Situated on north bank of Brahmaputra in Assam, Nalbari specialises in weave of mulberry silk; while cotton, eri and zari yarns are also used."
        case 6:
            return "Dimapur, Phek region weavers now weave contemporary textiles in thick cotton for home textiles, jackets, bags."
        default:
            return selectedCluster?.adjective ?? ""
        }
    }
    
    func setBrandLogo() {
        if let artisan = selectedArtisan {
            if let tag = artisan.buyerCompanyDetails.first?.logo, artisan.buyerCompanyDetails.first?.logo != "" {
                let prodId = artisan.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    self.brandLogoImage.image = downloadedImage
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = BrandLogoService.init(client: client, userObject: selectedArtisan!)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = artisan.buyerCompanyDetails.first?.logo ?? "name.jpg"
                                let prodId = artisan.entityID ?? 0
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                self.brandLogoImage.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
            else if let tag = artisan.profilePic, artisan.profilePic != "" {
                let prodId = artisan.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    self.brandLogoImage.image = downloadedImage
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = UserProfilePicService.init(client: client, userObject: selectedArtisan!)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = artisan.profilePic ?? "name.jpg"
                                let prodId = artisan.entityID
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                self.brandLogoImage.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func setDatasource(withId: Int) {
        if let cluster = selectedCluster {
            if withId == 0 {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "clusterId", cluster.entityID).sorted(byKeyPath: "modifiedOn", ascending: false)
            }else {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "clusterId", cluster.entityID).filter("%K == %@", "productCategoryId", withId).sorted(byKeyPath: "modifiedOn", ascending: false)
            }
        }else if let category = selectedCategory {
            if withId == 0 {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "productCategoryId", category.entityID).sorted(byKeyPath: "modifiedOn", ascending: false)
            }else {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "clusterId", withId).filter("%K == %@", "productCategoryId", category.entityID).sorted(byKeyPath: "modifiedOn", ascending: false)
            }
        }else if let artisan = selectedArtisan {
            if withId == 0 {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "artitionId", artisan.entityID).sorted(byKeyPath: "modifiedOn", ascending: false)
            }else {
                allPorducts = realm.objects(Product.self).filter("%K == %@", "artitionId", artisan.entityID).filter("%K == %@", "productCategoryId", withId).sorted(byKeyPath: "modifiedOn", ascending: false)
            }
        }
    }
    
    func heightForView(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 10
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15)
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      viewDidAppear?()
    }
    
    func endRefresh() {
        setDatasource(withId: 0)
        self.tableView.reloadData()
    }
    
    @IBAction func showFilter(_ sender: Any) {
        let alert = UIAlertController.init(title: "Select", message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All".localized, style: .default) { (action) in
            if self.selectedCategory != nil {
                self.filterButton.setTitle("Filter by region".localized, for: .normal)
            }else {
                self.filterButton.setTitle("Filter by category".localized, for: .normal)
            }
            self.setDatasource(withId: 0)
            self.tableView.reloadData()
        }
        alert.addAction(all)
        
        if selectedCategory != nil {
            //Show Region Filter Options
            alert.title = "Select Region".localized
            let catgories = realm.objects(ClusterDetails.self)
            for option in catgories {
                let action = UIAlertAction.init(title: option.clusterDescription ?? "", style: .default) { (action) in
                    self.filterButton.setTitle(option.clusterDescription, for: .normal)
                    self.setDatasource(withId: option.entityID)
                    self.tableView.reloadData()
                    
              }
              alert.addAction(action)
            }
        }else {
            //Show Category Filter Options
            alert.title = "Select Category".localized
            let catgories = realm.objects(ProductCategory.self)
            for option in catgories {
                let action = UIAlertAction.init(title: option.prodCatDescription ?? "", style: .default) { (action) in
                    self.filterButton.setTitle(option.prodCatDescription, for: .normal)
                    self.setDatasource(withId: option.entityID)
                    self.tableView.reloadData()
                    
              }
              alert.addAction(action)
            }
        }
        
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        reachabilityManager?.whenReachable = nil
        reachabilityManager?.whenUnreachable = nil
        reachabilityManager?.stopNotifier()
        viewWillAppear = nil
        applicationEnteredForeground = nil
    }
}

extension BuyerProductCatalogController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPorducts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = allPorducts?[indexPath.row]
        print("\n**** product ID: \(product?.entityID) \n product madeWithAntaran: \(product?.madeWithAnthran) \n product productCategoryId \(product?.productCategoryId) \n product cluster \(product?.clusterId) \n product artisan \(product?.artitionId) \n****")
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuyerProductCell
        if let prod = product {
            cell.configure(prod)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}
