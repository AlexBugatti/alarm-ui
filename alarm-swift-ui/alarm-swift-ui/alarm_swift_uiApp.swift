//
//  alarm_swift_uiApp.swift
//  alarm-swift-ui
//
//  Created by Александр on 09.07.2022.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //
        return true
    }
    
    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.updateAlarms,
                                                        object: nil, userInfo: nil)
    }
 
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    func application(
      _ application: UIApplication,
      configurationForConnecting connectingSceneSession: UISceneSession,
      options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
      let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      sceneConfig.delegateClass = SceneDelegate.self // 👈🏻
      return sceneConfig
    }
    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        if connectingSceneSession.role == UISceneSession.Role.windowApplication {
//            let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
//            config.delegateClass = SceneDelegate.self
//            config.storyboard = UIStoryboard(name: "Main", bundle: nil)
//            return config
//        }
//        fatalError("Unhandled scene role \(connectingSceneSession.role)")
//    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        NotificationCenter.default.post(name: NSNotification.fireDate,
                                                        object: nil, userInfo: ["info": "Test"])
        withCompletionHandler([.list, .sound])
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print("notiff")
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //
        print(response)
    }

//    internal func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive: UNNotificationResponse,
//                                withCompletionHandler: @escaping ()->()) {
//        withCompletionHandler()
//    }

//    private func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        //
//    }
    
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _: UIWindowScene = scene as? UIWindowScene else { return }
        maybeOpenedFromWidget(urlContexts: connectionOptions.urlContexts)
    }

    // App opened from background
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        maybeOpenedFromWidget(urlContexts: URLContexts)
    }

    private func maybeOpenedFromWidget(urlContexts: Set<UIOpenURLContext>) {
        guard let _: UIOpenURLContext = urlContexts.first(where: { $0.url.scheme == "widget-deeplink" }) else {
            return
        }
        
        if let first = urlContexts.first(where: { $0.url.scheme == "widget-deeplink" }) {
            let scheme = first.url.absoluteString
            let components = scheme.components(separatedBy: "//")
            if components.count == 2, let id = components.last {
                NotificationService.shared.change(alarmId: id, state: false)
                NotificationCenter.default.post(name: NSNotification.updateAlarms,
                                                                object: nil, userInfo: nil)
            }
        }
        print("🚀 Launched from widget")
    }
    
}

@main
struct alarm_swift_uiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @EnvironmentObject var sceneDelegate: SceneDelegate
    
    var body: some Scene {
        
        WindowGroup {
            MainView()
        }
    }
}
