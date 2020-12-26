//
//  LoginEmailScreen.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import JWTDecode

class ValidationViewModel {
    var username = Observable<String?>("")
    var performValidation: (() -> Void)?
    var goToRegister: (() -> Void)?
    var performAuthenticationSocial: ((_ username: String, _ socialToken: String, _ socialTokenType: String) -> ())?
}

class LoginEmailController: UIViewController, GIDSignInDelegate {
    lazy var viewModel = ValidationViewModel()
    var googleSignIn = GIDSignIn.sharedInstance()
    @IBOutlet weak var nextButton: RoundedButton!
    @IBOutlet weak var usernameField: RoundedTextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var changeLangButton: UIButton!
    @IBOutlet weak var appleLoginButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        googleLoginButton.layer.cornerRadius = 15
        facebookLoginButton.layer.cornerRadius = 15
        
        self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
        self.navigationItem.rightBarButtonItem = roleBarButton()
        registerBtn.setTitle("New user? Click here to register.".localized, for: .normal)
        facebookLoginButton.setTitle("Login with Facebook.".localized, for: .normal)
        googleLoginButton.setTitle("Login with Google.".localized, for: .normal)
        changeLangButton.isHidden = KeychainManager.standard.userRole == "Buyer" ? true : false
        appleLoginButton.addTarget(self, action: #selector(appleLoginSelected), for: .touchUpInside)

    }
    
    @IBAction func nextButtonSelected(_ sender: Any) {
        self.viewModel.performValidation?()
    }
    
    @IBAction func registerSelected(_ sender: Any) {
        self.viewModel.goToRegister?()
    }
    
    @IBAction func faqButtonSelected(_ sender: UIButton) {
        didTapFAQButton(tag: sender.tag)
    }
    
    @IBAction func languageButtonSelected(_ sender: UIButton){
        showLanguagePickerAlert()
    }
    
    @IBAction func googleLoginSelected(_ sender: Any) {
        googleAuthLogin()
    }
    
    @IBAction func facebookLoginSelected(_ sender: Any) {
        fbLogin()
    }
    
    func fbLogin() {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions:[ .publicProfile, .email ], viewController: self) { loginResult in
            
            switch loginResult {
                
            case .failed(let error):
                print(error)
                
            case .cancelled:
                print("User cancelled login process.")
                
            case .success( _, _, _):
                print("Logged in!")
                self.getFBUserData()
            }
        }
    }
    
    func getFBUserData() {
        let token = AccessToken.current
        let tokenString = token?.tokenString
        if((AccessToken.current) != nil){
            var username = ""
            GraphRequest(graphPath: "me", parameters: ["fields": "email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! [String : AnyObject]
                    let picutreDic = dict as NSDictionary
                    if let emailAddress = picutreDic.object(forKey: "email") {
                        username = emailAddress as! String
                    }
                    self.viewModel.performAuthenticationSocial?(username, tokenString!, "FACEBOOK")
                }
            })
        }
    }
    
    func googleAuthLogin() {
        self.googleSignIn?.presentingViewController = self
        self.googleSignIn?.clientID = GIDSignIn.sharedInstance().clientID//"241853758861-torqnu9vet36tshanfmovq0mr1h161gd.apps.googleusercontent.com"
        self.googleSignIn?.delegate = self
        self.googleSignIn?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let user = user else {
            print("Uh oh. The user cancelled the Google login.")
            return
        }
        let username = user.profile.email
        let accessToken = user.authentication.accessToken
        self.viewModel.performAuthenticationSocial?(username!, accessToken!, "GOOGLE")
    }
}

extension LoginEmailController: ASAuthorizationControllerDelegate {
    
    @objc func appleLoginSelected(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            if let identityTokenData = appleIDCredential.identityToken,
            let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            print("Identity Token \(identityTokenString)")
            do {
               let jwt = try decode(jwt: identityTokenString)
               let decodedBody = jwt.body as Dictionary
               print(decodedBody)
               print("Decoded email: "+(decodedBody["email"] as? String ?? "n/a")   )
                if let email = decodedBody["email"] as? String {
                    self.viewModel.performAuthenticationSocial?(email, identityTokenString, "GOOGLE")
                }
            } catch {
               print("decoding failed")
            }
            }
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName))") }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    }
}
