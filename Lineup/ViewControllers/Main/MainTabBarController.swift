//
//  MainTabBarController.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import SnapKit

class MainTabBarController: UITabBarController {

    private(set) lazy var postButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .deepPurple
        button.setImage(UIImage(named: "icPlus"), for: .normal)
        button.setImage(UIImage(named: "icPlus")?.withRenderingMode(.alwaysTemplate), for: .highlighted)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = .deepPurple
        UINavigationBar.appearance().tintColor = .deepPurple
        
        delegate = self

        initViewControllers()

        tabBar.addSubview(postButton)
        tabBar.barTintColor = UIColor(white: 250.0 / 255.0, alpha: 1.0)

        postButton.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).inset(8)
            maker.width.equalTo(UIScreen.main.bounds.width / 5)
        }
    }

    private func initViewControllers() {
        let timeline = UINavigationController(rootViewController: TimelineViewController())
        timeline.tabBarItem = UITabBarItem(title: nil,
                                           image: UIImage(named: "icHome"),
                                           selectedImage: nil)
        
        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(title: nil,
                                         image: UIImage(named: "icSearch"),
                                         selectedImage: nil)

        let fake = UIViewController()
        fake.tabBarItem = UITabBarItem(title: nil,
                                       image: nil,
                                       selectedImage: nil)

        let news = UINavigationController(rootViewController: NewsViewController())
        news.tabBarItem = UITabBarItem(title: nil,
                                       image: UIImage(named: "icHeart"),
                                       selectedImage: nil)
        
        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: nil,
                                          image: UIImage(named: "icProfile"),
                                          selectedImage: nil)
        
        viewControllers = [timeline, search, fake, news, profile]
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard let _ = viewController as? UINavigationController else { return false }
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {

        guard viewControllers?.filter({ !($0 is UINavigationController) }).first == viewController else { return }

//        present(UINavigationController(rootViewController: PostViewController(accessToken: <#T##String#>)),
//                animated: true,
//                completion: {
//                    tabBarController.selectedIndex = (self.viewControllers?.count ?? 0) - 1
//        })
    }
}
