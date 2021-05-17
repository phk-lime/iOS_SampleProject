//
//  AppDelegate.swift
//  Authentication
//
//  Created by limefriends on 2021/05/04.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import FBSDKCoreKit
import KakaoSDKCommon
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // firebase
        FirebaseApp.configure()
        // google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        // apple
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                break // The Apple ID credential is valid. Apple ID 자격 증명이 유효합니다.
//            case .revoked, .notFound:
//                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//                // Apple ID 자격 증명이 취소되었거나 찾을 수 없으므로 로그인 UI 표시
//                DispatchQueue.main.async {
//                    self.showSigninScene()
//                }
            default:
                break
            }
        }
        // facebook
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // kakao
        KakaoSDKCommon.initSDK(appKey: "e118d924623a92ffdd21c7fed535fc3a")
        
        return true
    }
    
    // 이 메서드는 인스턴스의 handleURL 메서드를 호출하여 인증 프로세스가 끝날 때 애플리케이션이 수신하는 URL을 적절히 처리
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        
        // kakao
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        // google
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    // 앱을 iOS 8 이상에서 실행하려면 지원이 중단된 application:openURL:sourceApplication:annotation: 메서드도 구현
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

// MARK: - 구글 GIDSignInDelegate delegate
extension AppDelegate: GIDSignInDelegate {
    // signIn:didSignInForUser:withError: 메서드에서 GIDAuthentication 객체로부터 Google ID 토큰과 Google 액세스 토큰을 가져와서 Firebase 사용자 인증 정보로 교환
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("--->[GIDSignInDelegate:didSignInFor] Error:", error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        // Firebase 사용자 인증 정보를 사용해 Firebase에 인증
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("--->[GIDSignInDelegate:didSignInFor] Error:", error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "구글 로그인 성공", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.window?.rootViewController?.present(ac, animated: true, completion: nil)
                }
                print("--->[GIDSignInDelegate:didSignInFor]: Login Successful")
            }
        }
    }
    
    // 구글 Disconnect
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("--->[GIDSignInDelegate:didDisconnectWith]: Disconnect")
    }
}
