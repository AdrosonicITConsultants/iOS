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
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import WMSegmentControl
import Photos

class MyProfileViewModel {
    var viewDidLoad: (() -> Void)?
    var updateArtisanProfile: (([String:Any], Data?, String?) -> Void)?
    var updateArtisanBrandDetails: (([String:Any], Data?, String?) -> Void)?
    var updateArtisanBankDetails: (([[String:Any]]) -> Void)?
    var updateBuyerDetails: (([String:Any],Data?,String?) -> Void)?
    
    var addr1 = Observable<String?>(nil)
    var addr2 = Observable<String?>(nil)
    var district = Observable<String?>(nil)
    var state = Observable<String?>(nil)
    var street = Observable<String?>(nil)
    var country = Observable<String?>(nil)
    var pincode = Observable<String?>(nil)
    var landmark = Observable<String?>(nil)
    var city = Observable<String?>(nil)
    var alternateMobile = Observable<String?>(nil)
    
    var companyName = Observable<String?>(nil)
    var compDesc = Observable<String?>(nil)
    var cin = Observable<String?>(nil)
    var contact = Observable<String?>(nil)
    var gst = Observable<String?>(nil)
    
    var pocFirstName = Observable<String?>(nil)
    var poclastName = Observable<String?>(nil)
    var pocEmail = Observable<String?>(nil)
    var pocContact = Observable<String?>(nil)
    
    var designation = Observable<String?>(nil)
    var pancard = Observable<String?>(nil)
    var imageData = Observable<(Data,String)?>(nil)
}

class BuyerProfileController: UIViewController {

    let viewModel = MyProfileViewModel()
    var reachabilityManager = try? Reachability()
    var isEditable = false
    @IBOutlet weak var childContainerView: UIView!
    @IBOutlet weak var segmentControl: WMSegment!
    @IBOutlet weak var profileImg: UIButton!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var buyerNameLbl: UILabel!
    @IBOutlet weak var yellowBgView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttonView: UIView!
    var allCountries: Results<Country>?
    var loadArtisan: Bool = false
    
    private lazy var GeneralInfoViewController: BuyerGeneralInfo = {
        var viewController = BuyerGeneralInfo.init()
        viewController.isEditable = self.isEditable
        self.add(asChildViewController: viewController)
        return viewController
    }()

    private lazy var CompanyProfileInfoViewController: BuyerCompanyProfileInfo = {
        var viewController = BuyerCompanyProfileInfo.init()
        viewController.isEditable = self.isEditable
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    private lazy var ProfileAddrInfoViewController: BuyerProfileAddrInfo = {
        var viewController = BuyerProfileAddrInfo.init()
        viewController.isEditable = self.isEditable
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
        let realm = try! Realm()
        allCountries = realm.objects(Country.self).sorted(byKeyPath: "entityID")
        setupSegmentTitle()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLogoPic), name: NSNotification.Name("loadLogoImage"), object: nil)
        if KeychainManager.standard.userRole == "Artisan" || loadArtisan {
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
            companyName.text = User.loggedIn()?.buyerCompanyDetails.first?.companyName
            ratingLbl.text = "\(User.loggedIn()?.rating ?? 1) / 5"
            profileImg.imageView?.layer.cornerRadius = 35
            if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
                do {
                    let downloadedImage = try Disk.retrieve("\(userID)/\(name)", from: .caches, as: UIImage.self)
                    profileImg.setImage(downloadedImage, for: .normal)
                }catch {
                    print(error)
                }
                if self.reachabilityManager?.connection != .unavailable {
                    refreshProfileImage()
                }
            } else if self.reachabilityManager?.connection != .unavailable {
                refreshProfileImage()
            } else {
                profileImg.setImage(UIImage.init(named: "user"), for: .normal)
            }
        }
    }
    
    func refreshProfileImage() {
        if let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID  {
            let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(userID)/CompanyDetails/Logo/\(name)")
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segmentControl.bottomBarHeight = 5
        segmentControl.type = .normal
        segmentControl.selectorType = .bottomBar
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
        isEditable = true
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
        isEditable = false
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

        var newUser = CXUser()

        newUser.alternateMobile = self.viewModel.alternateMobile.value ?? ""
        newUser.designation = self.viewModel.designation.value ?? ""
        newUser.pancard = self.viewModel.pancard.value ?? ""
        
        let selectedCountryObj = self.allCountries?.filter("%K == %@", "name", self.viewModel.country.value).first
        let addr1 = self.viewModel.addr1.value ?? nil
        let addr2 = self.viewModel.addr2.value ?? nil
        let city = self.viewModel.city.value ?? nil
        let landmark = self.viewModel.landmark.value ?? nil
        let state = self.viewModel.state.value ?? nil
        let street = self.viewModel.street.value ?? nil
        let pin = self.viewModel.pincode.value ?? nil
        let district = self.viewModel.district.value ?? nil

        let newAddr = LocalAddress.init(id: 0, addrType: nil, country: (countryId: selectedCountryObj?.entityID, countryName: selectedCountryObj?.name) as? (countryId: Int, countryName: String), city: city, district: district, landmark: landmark, line1: addr1, line2: addr2, pincode: pin, state: state, street: street, userId: User.loggedIn()?.entityID ?? 0)
        newUser.address = newAddr
        

        let cin = self.viewModel.cin.value ?? nil
        let gstNo = self.viewModel.gst.value ?? nil
        
        let newCompDetails = buyerCompDetails.init(id: User.loggedIn()?.buyerCompanyDetails.first?.entityID ?? 0, companyName: User.loggedIn()?.buyerCompanyDetails.first?.companyName ?? "", cin: cin, contact: User.loggedIn()?.buyerCompanyDetails.first?.contact ?? "", gstNo: gstNo, logo: nil, compDesc: User.loggedIn()?.buyerCompanyDetails.first?.compDesc ?? "")
        newUser.buyerCompanyDetails = newCompDetails
        
        if (self.viewModel.pocFirstName.value != nil && self.viewModel.pocFirstName.value?.isNotBlank ?? false) ||
          (self.viewModel.pocContact.value != nil && self.viewModel.pocContact.value?.isNotBlank ?? false) ||
          self.viewModel.pocEmail.value != nil && self.viewModel.pocEmail.value?.isNotBlank ?? false {
          let pocName = self.viewModel.pocFirstName.value ?? nil
          let pocEmail = self.viewModel.pocEmail.value ?? nil
          let pocMob = self.viewModel.pocContact.value ?? nil
          let newPointOfContact = pointOfContact.init(id: User.loggedIn()?.pointOfContact.first?.entityID ?? 0, contactNo: pocMob, email: pocEmail, firstName: pocName)
          newUser.buyerPointOfContact = newPointOfContact
        }
        if self.viewModel.imageData.value != nil {
            self.viewModel.updateBuyerDetails?(newUser.toJSON(updateAddress: true, buyerComp: true), self.viewModel.imageData.value?.0, self.viewModel.imageData.value?.1)
        }else {
            self.viewModel.updateBuyerDetails?(newUser.toJSON(updateAddress: true, buyerComp: true), nil, nil)
        }
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
    
    @objc func updateLogoPic() {
        if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
            do {
                let downloadedImage = try Disk.retrieve("\(userID)/\(name)", from: .caches, as: UIImage.self)
                profileImg.setImage(downloadedImage, for: .normal)
            }catch {
                print(error)
            }
        }
    }
}

extension BuyerProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        profileImg.setImage(selectedImage, for: .normal)
        var imgdata: Data?
        if let compressedImg = selectedImage.resizedTo1MB() {
            if let data = compressedImg.pngData() {
                imgdata = data
            } else if let data = compressedImg.jpegData(compressionQuality: 1) {
                imgdata = data
            }
        }else {
            if let data = selectedImage.pngData() {
                imgdata = data
            } else if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                imgdata = data
            }
        }
        self.viewModel.imageData.value = (imgdata, "logo.jpg") as? (Data, String)
        
        picker.dismiss(animated: true, completion: nil)
    }
}

