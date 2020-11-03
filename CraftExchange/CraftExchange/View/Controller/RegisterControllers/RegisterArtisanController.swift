//
//  RegisterArtisanController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class REGArtisanViewModel {
    var completeRegistration: (() -> Void)?
    var selectedProdCat = Observable<[Int]?>(nil)
}

class RegisterArtisanController: UIViewController {
  
  lazy var viewModel = REGArtisanViewModel()
  var isTCAccepted = false
  @IBOutlet weak var completeButton: RoundedButton!
  @IBOutlet weak var checkboxButton: UIButton!
  @IBOutlet weak var uploadImageButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = roleBarButton()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    self.viewModel.selectedProdCat.value = appDelegate?.registerUser?.productCategoryIds
  }
    
    override func viewDidAppear(_ animated: Bool) {
        for subview in self.view.subviews {
            if self.viewModel.selectedProdCat.value?.contains(subview.tag) ?? false {
                let button = subview as? RoundedButton
                button?.backgroundColor = .black
                button?.setTitleColor(.white, for: .normal)
            }
        }
    }
  
  @IBAction func toggleCheckbox(_ sender: Any) {
    isTCAccepted = !isTCAccepted
    let img = isTCAccepted == true ? UIImage.init(systemName: "checkmark.square") : UIImage.init(systemName: "square")
    checkboxButton.setImage(img, for: .normal)
    
  }
  
  @IBAction func completeButtonSelected(_ sender: Any) {
    self.viewModel.completeRegistration?()
  }
    
    @IBAction func toggleProductCat(_ sender: Any) {
        let button = sender as? RoundedButton
        if button?.backgroundColor == .white {
            //Set selected
            button?.backgroundColor = .black
            button?.setTitleColor(.white, for: .normal)
            if (self.viewModel.selectedProdCat.value?.count ?? 0 > 0) {
                self.viewModel.selectedProdCat.value?.append(button?.tag ?? 1)
            }else {
                self.viewModel.selectedProdCat.value = [button?.tag ?? 1]
            }
        }else {
            //Unselect
            button?.backgroundColor = .white
            button?.setTitleColor(.black, for: .normal)
            self.viewModel.selectedProdCat.value?.removeAll(where: { (i) -> Bool in
                i == button?.tag
            })
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.registerUser?.productCategoryIds = self.viewModel.selectedProdCat.value
    }
    
    @IBAction func updateBrandLogoSelected(_ sender: Any) {
        self.showImagePickerAlert()
    }
    
    @IBAction func faqButtonSelected(_ sender: UIButton) {
        didTapFAQButton(tag: sender.tag)
    }
    
}

extension RegisterArtisanController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        uploadImageButton.setImage(selectedImage, for: .normal)
        uploadImageButton.setTitle("", for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
}
