//
//  DesignCollectionController.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import WMSegmentControl
import Photos

class BuyerCategoryViewModel {
    var viewWillAppear: (() -> Void)?
}

class DesignCollectionController: UIViewController {
    @IBOutlet weak var createdByLbl: UILabel!
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var collectionSegment: WMSegment!
    @IBOutlet weak var madeByImage: UIImageView!
    @IBOutlet weak var createdByView: UIView!
    @IBOutlet weak var viewByCluster: UIButton!
    @IBOutlet weak var clusterBtnHtConstraint: NSLayoutConstraint!
    
    let viewModel = BuyerCategoryViewModel()
    var madeByAntaran: Bool = false
    var allRegions: Results<ClusterDetails>?
    var allCategories: Results<ProductCategory>?
    var allArtisanBrands: [User]?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        
        allRegions = realm.objects(ClusterDetails.self).sorted(byKeyPath: "entityID")
        allCategories = realm.objects(ProductCategory.self).sorted(byKeyPath: "entityID")
        allArtisanBrands = realm.objects(User.self).filter("%K == %@", "refRoleId", "1").compactMap{$0}

        categoryCollection.register(UINib(nibName: "RegionCell", bundle: nil), forCellWithReuseIdentifier: "RegionCell")
        categoryCollection.register(UINib(nibName: "CategoryBrandCell", bundle: nil), forCellWithReuseIdentifier: "CategoryBrandCell")
        
        if madeByAntaran == true {
            createdByLbl.text = "Antaran Co Design Collection".localized
            madeByImage.image = UIImage.init(named: "iosAntaranSelfDesign")
            collectionSegment.buttonTitles = "Regions, Categories"
        }else {
            createdByView.backgroundColor = .lightGray
            createdByLbl.text = "Artisan Self Design Collection".localized
            madeByImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
            collectionSegment.buttonTitles = "Regions, Categories, Artisan Brands"
        }
        viewByCluster.setTitle("View by cluster: All", for: .normal)
        viewByCluster.layer.borderColor = UIColor.lightGray.cgColor
        viewByCluster.layer.borderWidth = 1.0
        viewByCluster.dropShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLayout()
        viewModel.viewWillAppear?()
        collectionSegment.bottomBarHeight = 5
        collectionSegment.type = .normal
        collectionSegment.selectorType = .bottomBar
    }
    
    func refreshArtisanList() {
        allArtisanBrands = realm.objects(User.self).filter("%K == %@", "refRoleId", "1").compactMap{$0}
        if collectionSegment.selectedSegmentIndex == 2 {
            categoryCollection.reloadData()
        }
    }
    
    func setLayout() {
        var cellSize: CGSize
        if collectionSegment.selectedSegmentIndex == 0 {
            cellSize = CGSize(width: UIScreen.main.bounds.width-10, height: 180)
        }else {
            cellSize = CGSize(width: UIScreen.main.bounds.width/2-10, height: UIScreen.main.bounds.width/2-10)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 1.0
        categoryCollection.setCollectionViewLayout(layout, animated: true)
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        categoryCollection?.collectionViewLayout.invalidateLayout()
        categoryCollection.deleteItems(at: categoryCollection.indexPathsForVisibleItems)
        setLayout()
        if collectionSegment.selectedSegmentIndex == 2 {
            clusterBtnHtConstraint.constant = 30
            viewByCluster.isHidden = false
        }else {
            clusterBtnHtConstraint.constant = 0
            viewByCluster.isHidden = true
        }
        categoryCollection.reloadData()
    }
    
    @IBAction func filterByClusterSelected(_ sender: Any) {
        let alert = UIAlertController.init(title: "Select Cluster".localized, message: "", preferredStyle: .actionSheet)
        let all = UIAlertAction.init(title: "All", style: .default) { (action) in
            self.viewByCluster.setTitle("View by cluster: All", for: .normal)
            self.refreshArtisanList(clusterId: 0)
        }
        alert.addAction(all)
        allRegions?.forEach ({ (option) in
            let action = UIAlertAction.init(title: option.clusterDescription ?? "", style: .default) { (action) in
                self.viewByCluster.setTitle(option.clusterDescription ?? "", for: .normal)
                self.refreshArtisanList(clusterId: option.entityID)
            }
            alert.addAction(action)
        })
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func refreshArtisanList(clusterId: Int) {
        if clusterId == 0 {
            allArtisanBrands = realm.objects(User.self).filter("%K == %@", "refRoleId", "1").compactMap{$0}
        }else {
            allArtisanBrands = User().getAllArtisansForCluster(clusterId: clusterId)
        }
        categoryCollection.reloadData()
    }
}

extension DesignCollectionController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionSegment.selectedSegmentIndex {
            case 0:
                return allRegions?.count ?? 0
            case 1:
                return allCategories?.count ?? 0
            case 2:
                return allArtisanBrands?.count ?? 0
            default:
                return 0
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionSegment.selectedSegmentIndex {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RegionCell", for: indexPath) as! RegionCell
            cell.titleLabel.text = allRegions?.compactMap{$0}[indexPath.row].clusterDescription
            cell.adjectiveLabel.text = allRegions?[indexPath.row].adjective
            cell.logoImage.image = UIImage.init(named: "coverImage")
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize.zero
            cell.layer.shadowRadius = 5
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryBrandCell", for: indexPath) as! CategoryBrandCell
            cell.titleLabel.text = allCategories?[indexPath.row].prodCatDescription
            cell.logoImage.image = UIImage.init(named: cell.titleLabel.text ?? "Saree")
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize.zero
            cell.layer.shadowRadius = 5
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryBrandCell", for: indexPath) as! CategoryBrandCell
            if let companyName = allArtisanBrands?[indexPath.row].buyerCompanyDetails.first?.companyName, allArtisanBrands?[indexPath.row].buyerCompanyDetails.first?.companyName != "" {
                cell.titleLabel.text = companyName
            }else {
                cell.titleLabel.text = allArtisanBrands?[indexPath.row].firstName
            }
            cell.logoImage.image = UIImage.init(named: "Saree")
            if let tag = allArtisanBrands?[indexPath.row].buyerCompanyDetails.first?.logo, allArtisanBrands?[indexPath.row].buyerCompanyDetails.first?.logo != "" {
                let prodId = allArtisanBrands?[indexPath.row].entityID ?? 0
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    cell.logoImage.image = downloadedImage
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = BrandLogoService.init(client: client, userObject: (allArtisanBrands?[indexPath.row])!)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = self.allArtisanBrands?[indexPath.row].buyerCompanyDetails.first?.logo ?? "name.jpg"
                                let prodId = self.allArtisanBrands?[indexPath.row].entityID ?? 0
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                cell.logoImage.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
            else if let tag = allArtisanBrands?[indexPath.row].profilePic, allArtisanBrands?[indexPath.row].profilePic != "" {
                let prodId = allArtisanBrands?[indexPath.row].entityID ?? 0
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    cell.logoImage.image = downloadedImage
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = UserProfilePicService.init(client: client, userObject: (allArtisanBrands?[indexPath.row])!)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = self.allArtisanBrands?[indexPath.row].profilePic ?? "name.jpg"
                                let prodId = self.allArtisanBrands?[indexPath.row].entityID ?? 0
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                cell.logoImage.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOpacity = 1
            cell.layer.shadowOffset = CGSize.zero
            cell.layer.shadowRadius = 5
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionSegment.selectedSegmentIndex {
        case 0:
            print("Region Cell")
            let region = allRegions?[indexPath.row]
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createScene(selectedRegion: region, selectedProductCat: nil, selectedArtisan: nil, madeByAntaran: madeByAntaran)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        case 1:
            print("Category Cell")
            let category = allCategories?[indexPath.row]
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createScene(selectedRegion: nil, selectedProductCat: category, selectedArtisan: nil, madeByAntaran: madeByAntaran)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        case 2:
            print("Artisan Cell")
            let artisan = allArtisanBrands?[indexPath.row]
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createScene(selectedRegion: nil, selectedProductCat: nil, selectedArtisan: artisan, madeByAntaran: madeByAntaran)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        default:
            print("Region Cell")
        }
    }
    
}
