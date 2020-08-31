//
//  PushNotificationManager.swift
//  Lineup
//
//  Created by y8k on 13/05/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import RxSwift
import RxCocoa
import Crashlytics

class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()

    let firebaseToken = BehaviorRelay<String?>(value: nil)
    let deviceToken = BehaviorRelay<Data?>(value: nil)

    override init() {
        super.init()

        notificationCenter.delegate = self
        Messaging.messaging().delegate = self

    }

    func registerPushNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else {
                let error = error ?? LineUpErrors.errorRegisterRemotePushNotification
                Crashlytics.sharedInstance().recordError(error)
                return
            }

            self.retrieveFirebaseToken()

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func retrieveFirebaseToken() {
        InstanceID.instanceID().instanceID { result, error in
            guard let token = result?.token else {
                Crashlytics.sharedInstance().recordError(error ?? LineUpErrors.errorNeedAccessToken)
                return
            }

            self.firebaseToken.accept(token)
        }
    }

    func unregisterPushNotifications() {
        deviceToken.accept(nil)
        firebaseToken.accept(nil)

        StoredInformations.deviceTokenForPush = nil

        DispatchQueue.main.async {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }

    func registerDeviceToken(_ token: Data) {
        deviceToken.accept(token)
        StoredInformations.deviceTokenForPush = token
        Messaging.messaging().apnsToken = token
    }

    func refreshDeviceToken() {
        guard let token = StoredInformations.deviceTokenForPush else { return }
        deviceToken.accept(token)

        PushNotificationManager.shared.registerPushNotifications()
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    // Receive push notifictaion in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.sound, .alert])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            fireDefaultAction()
        default:
            break
        }

        completionHandler()
    }

    private func fireDefaultAction() {
        let keyWindow = UIApplication.shared.keyWindow
        guard let rootViewController = keyWindow?.rootViewController as? MainWebViewController else { return }

        rootViewController.moveToFollowingNews()
    }
}

extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        firebaseToken.accept(fcmToken)
    }
}
