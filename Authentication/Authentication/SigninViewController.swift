//
//  SigninViewController.swift
//  Authentication
//
//  Created by limefriends on 2021/05/04.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FBSDKLoginKit
import KakaoSDKAuth
import KakaoSDKUser

class SigninViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var googleSigninButton: GIDSignInButton!
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // GIDSignIn 객체의 프레젠테이션 뷰 컨트롤러를 설정
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // 구글 로그인 버튼 스타일
        googleSigninButton.style = .standard
        googleSigninButton.colorScheme = .light
        
        // 애플 로그인 버튼 추가
        self.setupProviderLoginView()
        
        // 페이스북 로그인 버튼
        let loginButton = FBLoginButton()
        ///Facebook 로그인을 사용할 때 앱에서 사용자 데이터에 대한 권한을 요청할 수 있습니다.
        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = self
        self.stackView.addArrangedSubview(loginButton)
        ///앱에는 한 번에 한 명의 사용자만 로그인할 수 있습니다. Facebook에서는 [FBSDKAccessToken currentAccessToken]을 통해 사용자가 앱에 로그인했음을 표시합니다.
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
    }
    @IBAction func logoutAction(_ sender: Any) {
        // 구글, 페이스북 로그아웃
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        // 카카오 로그아웃
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
        let ac = UIAlertController(title: "로그아웃 성공", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true, completion: nil)
    }
    
    // kakao 로그인 버튼 action
    @IBAction func onKakaoLoginByAppTouched(_ sender: Any) {
     // 카카오톡 설치 여부 확인
      if (AuthApi.isKakaoTalkLoginAvailable()) {
        // 카카오톡 로그인. api 호출 결과를 클로저로 전달.
        AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
            if let error = error {
                // 예외 처리 (로그인 취소 등)
                print(error)
            }
            else {
                print("loginWithKakaoTalk() success.")
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Kakao 로그인 성공", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
      }
    }
    
    // 애플 로그인 여부 확인
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        self.performExistingAccountSetupFlows()
    //    }
    
    // 애플 로그인 버튼
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.stackView.addArrangedSubview(authorizationButton)
    }
    
    // 이 기능은 Apple ID와 iCloud 키 체인 암호를 모두 요청하여 사용자에게 기존 계정이 있는지 확인합니다
    //    func performExistingAccountSetupFlows() {
    //        // Prepare requests for both Apple ID and password providers.
    //        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
    //                        ASAuthorizationPasswordProvider().createRequest()]
    //
    //        // Create an authorization controller with the given requests.
    //        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    //        authorizationController.delegate = self
    //        authorizationController.presentationContextProvider = self
    //        authorizationController.performRequests()
    //    }
    
    // 애플 로그인 버튼 action
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        /// Apple with Firebase - Apple의 응답을 처리하는 대리자 클래스와 nonce의 SHA256 해시를 요청에 포함하는 것으로 Apple의 로그인 과정을 시작합니다.
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // 애플 로그인 버튼
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - 애플 로그인 delegate
extension SigninViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    /// 인증이 성공하면 권한 컨트롤러는 앱이 사용자 데이터를 키 체인에 저장하는 데 사용 하는 위임 함수를 호출합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            // 시스템에서 계정을 만듭니다.
            let userIdentifier = appleIDCredential.user
            //            let fullName = appleIDCredential.fullName
            //            let email = appleIDCredential.email
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            // 이 데모 앱의 목적을 위해 키 체인에`userIdentifier`를 저장합니다.
            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            // 이 데모 앱의 목적을 위해`ResultViewController`에 Apple ID 자격 증명 정보를 표시합니다.
            //            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)

            /// 로그인에 성공했으면 해시되지 않은 nonce가 포함된 Apple의 응답에서 ID 토큰을 사용하여 Firebase에 인증합니다.
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "")
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
            }
            
            DispatchQueue.main.async {
                let ac = UIAlertController(title: "Apple 로그인 성공", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true, completion: nil)
            }
            
        //        case let passwordCredential as ASPasswordCredential:
        //
        //            // Sign in using an existing iCloud Keychain credential.
        //            // 기존 iCloud 키 체인 자격 증명을 사용하여 로그인합니다.
        //            let username = passwordCredential.user
        //            let password = passwordCredential.password
        //
        //            // For the purpose of this demo app, show the password credential as an alert.
        //            // 이 데모 앱의 목적을 위해 암호 자격 증명을 경고로 표시합니다.
        //            DispatchQueue.main.async {
        //                self.showPasswordCredentialAlert(username: username, password: password)
        //            }
        
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "Sample.Authentication", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("userIdentifier를 키체인에 저장할 수 없습니다.")
        }
    }
    
    //    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
    //        guard let viewController = self.presentingViewController as? ResultViewController
    //            else { return }
    //
    //        DispatchQueue.main.async {
    //            viewController.userIdentifierLabel.text = userIdentifier
    //            if let givenName = fullName?.givenName {
    //                viewController.givenNameLabel.text = givenName
    //            }
    //            if let familyName = fullName?.familyName {
    //                viewController.familyNameLabel.text = familyName
    //            }
    //            if let email = email {
    //                viewController.emailLabel.text = email
    //            }
    //            self.dismiss(animated: true, completion: nil)
    //        }
    //    }
    
    //    private func showPasswordCredentialAlert(username: String, password: String) {
    //        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
    //        let alertController = UIAlertController(title: "Keychain Credential Received",
    //                                                message: message,
    //                                                preferredStyle: .alert)
    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    //        self.present(alertController, animated: true, completion: nil)
    //    }
    
    /// - Tag: did_complete_error
    /// 인증이 실패하면 권한 컨트롤러는 오류를 처리하기 위해 위임 함수를 호출합니다
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

// MARK: - 애플 로그인
extension SigninViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    /// 권한 컨트롤러는 모달 시트에서 사용자에게 Apple로 로그인 콘텐츠를 제공하는 앱에서 창을 가져 오는 함수를 호출합니다
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - 애플 로그인 with Firebase: 로그인 요청마다 임의의 문자열인 'nonce'가 생성되며, 이 nonce는 앱의 인증 요청에 대한 응답으로 ID 토큰이 명시적으로 부여되었는지 확인하는 데 사용됩니다. 릴레이 공격을 방지하려면 이 단계가 필요합니다.
extension SigninViewController {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                // SecRandomCopyBytes(_:_:_)를 사용하여 암호로 보호된 nonce를 생성할 수 있습니다.
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

// MARK: - 페이스북 로그인 delegate
extension SigninViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        /// 사용자가 정상적으로 로그인한 후에 didCompleteWithResult:error: 구현 코드에서 로그인한 사용자의 액세스 토큰을 가져와서 Firebase 사용자 인증 정보로 교환합니다.
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        //
        if let user = Auth.auth().currentUser {
            user.link(with: credential) { (authResult, error) in
                if let error = error {
                    print("--->[facebook:Auth]Error:",error.localizedDescription)
                }
                // User is signed in
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Facebook 로그인 결합 성공", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        else {
            /// Firebase 사용자 인증 정보를 사용해 Firebase에 인증합니다.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("--->[facebook:Auth]Error:",error.localizedDescription)
                }
                // User is signed in
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Facebook 로그인 성공", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
