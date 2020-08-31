//
//  Constants.swift
//  Lineup
//
//  Created by y8k on 09/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let ServiceErrorDomain = "LineUpErrorDomain"
    static let ServerStatusCodeDomain = "LineupServerStatusCodeDomain"

    struct ServerURLString {
        static var apiEndPoint: String {
            guard let value = Bundle.main.object(forInfoDictionaryKey: "LineUpAPIServerURLString") as? String else {
                fatalError("Web server URL is not defined check plist..")
            }
            return value
        }

        static var webEndPoint: String {
            guard let value = Bundle.main.object(forInfoDictionaryKey: "LineUpWebServerURLString") as? String else {
                fatalError("Web server URL is not defined check plist..")
            }
            return value
        }
    }
    
    static let PostSchemePrefix = "lineup://post"

    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    static var appInformation: [String: String] {
        return ["X-App-Version": Constants.appVersion,
                "X-OS-Type": "iOS",
                "X-OS-Version": UIDevice.current.systemVersion]
    }
}

struct StoredInformations {
    static var deviceTokenForPush: Data? {
        get {
            return UserDefaults.standard.data(forKey: "deviceTokenForPush")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceTokenForPush")
        }
    }

    static var serviceAccessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "lineUpServiceAccessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lineUpServiceAccessToken")
        }
    }
}

struct LineUpErrors {
    static let errorDecodingResponseModel = NSError(
        domain: Constants.ServiceErrorDomain,
        code: 100,
        userInfo: [NSLocalizedDescriptionKey: "Can not decoding response data."])

    static let errorMissingEssentialParameter = NSError(
        domain: Constants.ServiceErrorDomain,
        code: 101,
        userInfo: [NSLocalizedDescriptionKey: "Essential parameter(s) are misssing."])

    static let errorWritePhotoToTempDirectory = NSError(
        domain: Constants.ServiceErrorDomain,
        code: 102,
        userInfo: [NSLocalizedDescriptionKey: "Can't write photo data in local"])

    static let errorRegisterRemotePushNotification = NSError(
        domain: Constants.ServiceErrorDomain,
        code: 103,
        userInfo: [NSLocalizedDescriptionKey: "Failed register push notification with unknown"])

    static let errorNeedAccessToken = NSError(
        domain: Constants.ServiceErrorDomain,
        code: 104,
        userInfo: [NSLocalizedDescriptionKey: "Need access token"])

    static func errorStatusCode(_ statusCode: Int, message: String? = nil) -> NSError {
        return NSError(
            domain: Constants.ServerStatusCodeDomain,
            code: statusCode,
            userInfo: [NSLocalizedDescriptionKey: message ?? "Request failed"])
    }
}
