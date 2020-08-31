//
//  MainWebViewController.swift
//  Lineup
//
//  Created by YoonBong Kim on 28/06/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift
import Crashlytics

class MainWebViewController: UIViewController {
    private let viewHolder = ViewHolder()
    private let dataProvider = DataProvider()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        viewHolder.setUpSubviews(at: self)
        viewHolder.setUpConstraints(for: self)
        viewHolder.webView.navigationDelegate = self

        registerMessageForInject()
        bindFirebaseMessageToken()

        PushNotificationManager.shared.refreshDeviceToken()
        PushNotificationManager.shared.retrieveFirebaseToken()

        requestMain()
    }

    /// Register Observer for Javascript -> Native call
    private func registerMessageForInject() {
        /// `LoginStatus` message is called when login (fetchMyInfo) and logout
        viewHolder.webView.configuration.userContentController.add(self, name: "loginStatus")
    }

    /// Set Observer for device token is changed
    private func bindFirebaseMessageToken() {
        PushNotificationManager.shared.firebaseToken
            .distinctUntilChanged()
            .filter({ $0 != nil })
            .subscribe(onNext: { [weak self] tokenString in
                self?.processFirebaseToken(fcmToken: tokenString)
            }).disposed(by: disposeBag)
    }

    /**
     Request web page
     - parameters:
        - URL: URL for loading in Web View
     */
    private func loadRequest(URL: URL) {
        if viewHolder.webView.isLoading {
            viewHolder.webView.stopLoading()
        }

        var request = URLRequest(url: URL)
        
        Constants.appInformation
            .forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })

        viewHolder.webView.load(request)
    }
    
    /// Request Service Main (Home) Screen
    private func requestMain() {
        guard let mainURL = URL(string: dataProvider.baseURL) else { return }

        loadRequest(URL: mainURL)
    }

    /// Request Content detail
    private func moveToContent(_ contentID: String) {
        guard let redirectURL = dataProvider.contentDetailURL(contentID: contentID) else { return }

        loadRequest(URL: redirectURL)
    }

    /// Request Following & News Screen
    func moveToFollowingNews() {
        guard let redirectURL = dataProvider.notificationURL() else { return }

        loadRequest(URL: redirectURL)
    }
    
    /**
     Show Error Alert
     - parameters:
        - error: Reason for alerting
     */
    private func showErrorAlert(_ error: Error?) {
        let alertController = UIAlertController(title: "호출에 실패했습니다.",
                                                message: error?.localizedDescription,
                                                preferredStyle: .alert)
        
        let moveToHome = UIAlertAction(title: "홈으로", style: .cancel) { _ in
            self.requestMain()
        }
        
        alertController.addAction(moveToHome)
        
        let retryAction = UIAlertAction(title: "다시 시도", style: .default) { _ in
            self.viewHolder.webView.reload()
        }
        
        alertController.addAction(retryAction)
        
        present(alertController, animated: true, completion: nil)
    }

    /**
     Present posting screen as native
     - parameters:
        - accessToken: lineup service access token for auth
     */
    private func presentPostScreen(accessToken: String) {
        let postViewController = PostViewController(accessToken: accessToken, completion: { contentID in
            guard let contentID = contentID else { return }

            self.moveToContent(contentID)
        })

        let navigationController = UINavigationController(rootViewController: postViewController)

        present(navigationController, animated: true, completion: nil)
    }

    /**
     Process device token for remote push notification
     - parameters:
        - token: Token data for push notification
     */
    private func processFirebaseToken(fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        storeFirebaseTokenToLocalStorage(fcmToken: fcmToken)
    }
}

extension MainWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        storeAppInformationToLocalStorage()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        Crashlytics.sharedInstance().recordError(error)

        // Show alert popup when TIMEOUT, SERVER NOT FOUND, URL NOT FOUND
        switch (error as NSError).code {
        case -1001, -1003, -1100:
            showErrorAlert(error)
        default:
            break
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        Crashlytics.sharedInstance().recordError(error)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let postScheme = Constants.PostSchemePrefix
        guard navigationAction.navigationType == .other else { return decisionHandler(.allow) }
        guard let URL = navigationAction.request.url, URL.absoluteString.hasPrefix(postScheme) else {
            return decisionHandler(.allow)
        }

        // StoredInformation 써도 되긴 한데.. 혹시나 토큰 바뀌었을지도 모르니 방어차 다시 가져옴
        // login / logout 로직이 native로 바뀌면 수정 예정
        extractAccessToken { accessToken in
            guard let accessToken = accessToken else {
                self.showErrorAlert(LineUpErrors.errorNeedAccessToken)
                return
            }
            self.presentPostScreen(accessToken: accessToken)
        }

        decisionHandler(.cancel)
    }
}

extension MainWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        switch message.name {
        case "loginStatus":
            processLoginStatus(body: message.body as? String)
        default:
            break
        }
    }

    /**
     Process login status
     - parameters:
        - body: Message body from web view (javascript)
     */
    private func processLoginStatus(body: String?) {
        guard let bodyData = body?.data(using: .utf8), !bodyData.isEmpty else { return }
        guard let loginStatus = try? JSONDecoder().decode(LoginStatus.self, from: bodyData) else { return }

        switch loginStatus.status {
        case true:
            extractAccessToken(completion: nil)
            PushNotificationManager.shared.registerPushNotifications()
        case false:
            StoredInformations.serviceAccessToken = nil
            PushNotificationManager.shared.unregisterPushNotifications()
        }
    }

    /**
     Extract access token
     - parameters:
        - completion: Closure with access token
     */
    private func extractAccessToken(completion: ((String?) -> Void)?) {
        getLocalStorage(key: "token") { result, _ in
            guard let accessToken = result as? String else {
                completion?(nil)
                return
            }

            StoredInformations.serviceAccessToken = accessToken
            completion?(accessToken)
        }
    }

    /// Send app information to webView via java script
    private func storeAppInformationToLocalStorage() {
        evaluateJavaScript(code: dataProvider.appInformationJavaScript)
    }

    /// Send device token for remote push notification to webView via java script
    private func storeFirebaseTokenToLocalStorage(fcmToken: String) {
        evaluateJavaScript(code: dataProvider.registeredFirebaseTokenJavaScript)
    }

    /// Evaluate java script code
    private func evaluateJavaScript(code: String?, completion: ((Any?, Error?) -> Void)? = nil) {
        guard let code = code else { return }

        viewHolder.webView.evaluateJavaScript(code) { result, error in
            completion?(result, error)

            guard let error = error else { return }
            Crashlytics.sharedInstance().recordError(error)
        }
    }

    /**
     Extract local storage value with key
     - parameters:
        - key: Key what you extract value in local storage at web view
        - completion: Closure called after extracting local storage
     */
    private func getLocalStorage(key: String, completion: ((Any?, Error?) -> Void)?) {
        evaluateJavaScript(code: dataProvider.referStorageValueJavascript(key: "token")) { result, error in
            completion?(result, error)
        }
    }
}
