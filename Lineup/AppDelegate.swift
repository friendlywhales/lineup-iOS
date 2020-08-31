//
//  AppDelegate.swift
//  Lineup
//
//  Created by YoonBong Kim on 28/06/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let screenBounds = UIScreen.main.bounds
        
        window = UIWindow(frame: CGRect(x: 0.0, y: 0.0, width: screenBounds.width, height: screenBounds.height))

        let _ = PhotoManager.shared

        initFirebase()

        UINavigationBar.appearance().tintColor = .deepPurple

        window?.rootViewController = MainWebViewController()
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    private func initFirebase() {
        guard let name = Bundle.main.object(forInfoDictionaryKey: "FirebaseInfoName") as? String else {
            fatalError("There is no FirebaseInfoName in info.plist..")
        }

        guard let plistPath = Bundle.main.path(forResource: name, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: plistPath) else {
            fatalError("There is not exist GoogleService-info.plist..")
        }

        FirebaseApp.configure(options: options)
    }
}

// MARK: - Related to Remote Push Notification
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Crashlytics.sharedInstance().recordError(error)
    }
}
