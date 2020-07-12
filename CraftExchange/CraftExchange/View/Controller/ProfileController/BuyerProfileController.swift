//
//  BuyerProfileController.swift
//  CraftExchange
//
//  Created by Preety Singh on 09/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import WMSegmentControl

class BuyerProfileViewModel {
    var viewDidLoad: (() -> Void)?
    var updateArtisanProfile: (([String:Any]) -> Void)?
    var updateArtisanBrandDetails: (([String:Any]) -> Void)?
    var updateArtisanBankDetails: (([[String:Any]]) -> Void)?
}

class BuyerProfileController: UIViewController {

    let viewModel = BuyerProfileViewModel()
    var reachabilityManager = try? Reachability()
    
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var segmentControl: WMSegment!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var yellowBgView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    private lazy var GeneralInfoViewController: BuyerGeneralInfo = {
        var viewController = BuyerGeneralInfo.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()

    private lazy var CompanyProfileInfoViewController: BuyerCompanyProfileInfo = {
        var viewController = BuyerCompanyProfileInfo.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var ProfileAddrInfoViewController: BuyerProfileAddrInfo = {
        var viewController = BuyerProfileAddrInfo.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var ArtisanInfoViewController: ArtisanGeneralInfo = {
        var viewController = ArtisanGeneralInfo.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()

    private lazy var ArtisanBrandInfoViewController: ArtisanBrandDetails = {
        var viewController = ArtisanBrandDetails.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var ArtisanBankInfoViewController: ArtisanBankDetails = {
        var viewController = ArtisanBankDetails.init()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        viewModel.viewDidLoad?()
        setupSegmentTitle()
        if KeychainManager.standard.userRole == "Artisan" {
            self.navigationItem.title = "Hello \(User.loggedIn()?.firstName ?? User.loggedIn()?.userName ?? "")"
            if let constraint = (profileView.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = 0.0
                profileView.isHidden = true
            }
            if let constraint = (buttonView.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = 0.0
                buttonView.isHidden = true
            }
        }else {
            yellowBgView.layer.cornerRadius = yellowBgView.bounds.width/2
            buyerNameLbl.text = "\(User.loggedIn()?.firstName ?? "") \n \(User.loggedIn()?.lastName ?? "")"
            companyName.text = User.loggedIn()?.buyerCompanyDetails?.companyName
            ratingLbl.text = "\(User.loggedIn()?.rating ?? 1) / 5"
            profileImg.imageView?.layer.cornerRadius = 35
            if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails?.logo {
                do {
                    let downloadedImage = try Disk.retrieve("\(User.loggedIn()?.entityID ?? 84)/\(name)", from: .caches, as: UIImage.self)
                    profileImg.setImage(downloadedImage, for: .normal)
                }catch {
                    print(error)
                }
            }else if  let name = User.loggedIn()?.buyerCompanyDetails?.logo {
                let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(User.loggedIn()?.entityID)/CompanyDetails/Logo/\(name)")
                URLSession.shared.dataTask(with: url!) { data, response, error in
                    // do your stuff here...
                    DispatchQueue.main.async {
                        // do something on the main queue
                        if error == nil {
                            if let finalData = data {
                                User.loggedIn()?.saveOrUpdateBrandLogo(data: finalData)
                                NotificationCenter.default.post(name: Notification.Name("loadLogoImage"), object: nil)
                            }
                        }
                    }
                }.resume()
            }else {
                profileImg.setImage(UIImage.init(named: "user"), for: .normal)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentControl.setSelectedIndex(0)
        segmentControl.sendActions(for: .valueChanged)
    }
    
    func setupSegmentTitle() {
        if KeychainManager.standard.userRole == "Artisan" {
            segmentControl.buttonTitles = "My Details, Brand Details, Bank Details"
        }else {
            segmentControl.buttonTitles = "General, Brand, Delivery"
        }
    }
    
    @IBAction func updateBrandLogoSelected(_ sender: Any) {
        self.showImagePickerAlert()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        if KeychainManager.standard.userRole == "Artisan" {
            if segmentControl.selectedSegmentIndex == 0 {
                add(asChildViewController: ArtisanInfoViewController)
                remove(asChildViewController: ArtisanBrandInfoViewController)
                remove(asChildViewController: ArtisanBankInfoViewController)
            } else if segmentControl.selectedSegmentIndex == 1 {
                remove(asChildViewController: ArtisanInfoViewController)
                add(asChildViewController: ArtisanBrandInfoViewController)
                remove(asChildViewController: ArtisanBankInfoViewController)
            }else {
                remove(asChildViewController: ArtisanInfoViewController)
                remove(asChildViewController: ArtisanBrandInfoViewController)
                add(asChildViewController: ArtisanBankInfoViewController)
            }
        }else {
            if segmentControl.selectedSegmentIndex == 0 {
                add(asChildViewController: GeneralInfoViewController)
                remove(asChildViewController: CompanyProfileInfoViewController)
                remove(asChildViewController: ProfileAddrInfoViewController)
            } else if segmentControl.selectedSegmentIndex == 1 {
                remove(asChildViewController: GeneralInfoViewController)
                add(asChildViewController: CompanyProfileInfoViewController)
                remove(asChildViewController: ProfileAddrInfoViewController)
            }else {
                remove(asChildViewController: GeneralInfoViewController)
                remove(asChildViewController: CompanyProfileInfoViewController)
                add(asChildViewController: ProfileAddrInfoViewController)
            }
        }
    }
    @IBAction func editProfileSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("EnableEditNotification"), object: nil)
        if let constraint = (profileView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 0.0
            profileView.isHidden = true
        }
        if let constraint = (buttonView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 60.0
            buttonView.isHidden = false
            self.view.bringSubviewToFront(buttonView)
        }
        buttonView.backgroundColor = .clear
        segmentControl.backgroundColor = .clear
    }
    
    @IBAction func cancelSelected(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("DisableEditNotification"), object: nil)
        if let constraint = (profileView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 200.0
            profileView.isHidden = false
            self.view.bringSubviewToFront(profileView)
        }
        if let constraint = (buttonView.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 0.0
            buttonView.isHidden = true
        }
        buttonView.backgroundColor = .clear
        segmentControl.backgroundColor = .white
    }
    
    @IBAction func saveSelected(_ sender: Any) {
        self.cancelSelected(sender)
        //TODO: Save Edit Profile Request
    }

    private func add(asChildViewController viewController: FormViewController) {
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        childContainerView.backgroundColor = .white
        childContainerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = childContainerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: FormViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }
}

extension BuyerProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        profileImg.setImage(selectedImage, for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
}

