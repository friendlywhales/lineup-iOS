//
//  MainWebViewController+DataProvider.swift
//  Lineup
//
//  Created by y8k on 16/05/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension MainWebViewController {
    class DataProvider {

        /// Service Base URL
        let baseURL = Constants.ServerURLString.webEndPoint

        /// Javascript code for saving app information to web view
        var appInformationJavaScript: String {
            return """
            localStorage.setItem('appVersion', '\(Constants.appVersion)'); localStorage.setItem('appDevice', 'ios');
            """
        }

        /// Javascript code for saving token for remote push notification to web view
        var registeredFirebaseTokenJavaScript: String? {
            guard let firebaseToken = PushNotificationManager.shared.firebaseToken.value else { return nil }
            return """
            localStorage.setItem('deviceToken', '\(firebaseToken)'); localStorage.setItem('deviceName', 'ios');
            """
        }

        /// Followings tab URL (from Push notification)
        func notificationURL() -> URL? {
            return composeURL(path: "/notifications/followings")
        }

        /**
         Content detail URL
         - parameters:
            - contentID: Content ID what you want to show detail
         */
        func contentDetailURL(contentID: String) -> URL? {
            return composeURL(path: "/p/\(contentID)")
        }

        /**
         Extract value what is in local storage, web view
         - parameters:
            - key: Key for extracting
         */
        func referStorageValueJavascript(key: String) -> String {
            return """
            localStorage.getItem('\(key)')
            """
        }

        /**
         Compose new URL from baseURL
         - parameters:
            - path: Path for composing
        */
        private func composeURL(path: String) -> URL? {
            guard let baseURL = URL(string: baseURL) else { return nil }

            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = path

            return components.url
        }
    }
}
