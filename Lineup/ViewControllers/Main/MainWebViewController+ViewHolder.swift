//
//  MainWebViewController+ViewHolder.swift
//  Lineup
//
//  Created by YoonBong Kim on 28/06/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

extension MainWebViewController {
    class ViewHolder {
        private(set) lazy var webView: WKWebView = {
            let configuration = WKWebViewConfiguration()
            configuration.userContentController = WKUserContentController()

            return WKWebView(frame: .zero, configuration: configuration)
        }()
                
        func setUpSubviews(at viewContorller: UIViewController) {
            viewContorller.view.addSubview(webView)
        }
        
        func setUpConstraints(for viewController: UIViewController) {
            let safeAreaLayoutGuide = viewController.view.safeAreaLayoutGuide

            webView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview()
                maker.top.equalTo(safeAreaLayoutGuide.snp.topMargin)
                maker.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin)
            }
        }
    }
}
