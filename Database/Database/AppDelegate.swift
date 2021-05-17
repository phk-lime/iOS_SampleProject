//
//  AppDelegate.swift
//  Database
//
//  Created by limefriends on 2021/05/06.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        /* MARK: - Firebase 애플리케이션은 일시적으로 네트워크 연결이 끊겨도 정상적으로 작동합니다
        디스크 지속성 설정 - 앱의 데이터를 로컬로 저장, 오프라인 상태일 때도 앱의 현 상태를 유지할 수 있다
        Firebase 실시간 데이터베이스 클라이언트는 앱이 오프라인일. 때 수행된 모든 쓰기 작업을 자동으로 큐에 유지합니다.
        지속성을 사용하면 이 큐가 디스크에도 유지되므로 사용자 또는. 운영체제가 앱을 다시 시작해도 쓰기 작업이 사라지지 않습니다.
        앱이 다시 연결되면 모든 작업이 Firebase 실시간 데이터베이스 서버로 전송됩니다. */
        Database.database().isPersistenceEnabled = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

