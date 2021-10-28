//
//  ViewController.swift
//  Example-SocialSignIn
//
//  Created by limefriends on 2021/10/28.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapContinueWithApple(_ sender: UIButton) {
        /// Apple로 계속하기(Apple 로그인)은 iOS 13부터 가능하다.
        if #available(iOS 13, *) {
            continueWithApple()
        }
    }
}

@available(iOS 13.0, *)
extension ViewController: ASAuthorizationControllerDelegate {
    private func continueWithApple() {
        /// Apple의 응답을 처리하는 delegate와 nonce의 SHA256 해시를 request에 포함하는 것으로 Apple의 로그인 과정 시작
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        /// 사용자에게 요청할 정보
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // 인증에 성공하면 ASAuthorizationController는 app이 사용자 데이터를 키 체인에 저장하는 데 사용하는 함수를 호출
    // 사용자 정보(이메일, 이름 등)는 초기 등록 시에만 ASAuthorizationAppleIDCredential로 전송되고 이후에는 userIdentifier만 전송된다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            /// userIdentifier
            let userIdentifier = appleIDCredential.user
            print("--->[Continue with Apple] userIdentifier:", userIdentifier)
            /// A JSON Web Token (JWT) that securely communicates information about the user to the app.
            let identityToken = appleIDCredential.identityToken
            print("--->[Continue with Apple] identityToken:", identityToken)
            /// short-lived token as proof that it has authorization to interact with the server
            let authorizationCode = appleIDCredential.authorizationCode
            print("--->[Continue with Apple] authorizationCode:", authorizationCode)
            
            /// do something below to complete sign in
            /// ....
            
        case let passwordCredential as ASPasswordCredential:
            
            /// 기존 iCloud 키체인 자격 증명을 사용하여 로그인
            let user = passwordCredential.user
            let password = passwordCredential.password
            print("--->[Continue with Apple:passwordCredential] user:\(user), password: \(password)")
            
            /// do something below to complete sign in
            /// ....
            
        default:
            break
        }
    }
    
    /// 인증 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("--->[Continue with Apple] Error:", error)
    }
}

@available(iOS 13.0, *)
extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    // ASAuthorizationController는 사용자에게 'Apple로 로그인' 콘텐츠를 제공하는 창을 가져 오는 함수 호출
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
