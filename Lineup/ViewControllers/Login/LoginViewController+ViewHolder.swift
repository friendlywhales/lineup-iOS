//
//  LoginViewController+ViewHolder.swift
//  Lineup
//
//  Created by y8k on 27/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

extension LoginViewController {
    class ViewHolder {
        /// ImageView for representing service logo at top
        private lazy var backImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor(white: 0.0 / 255.0, alpha: 0.5)

            return imageView
        }()

        /// Contains email textfield, password textfield, and login button
        private(set) lazy var loginView: LoginView = {
            let loginView = LoginView()
            loginView.backgroundColor = .white
            loginView.layer.cornerRadius = 8.0

            return loginView
        }()

        /// Sign up button for moving to sign up screen
        private(set) lazy var signUpButton: UIButton = {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("시작하기", for: .normal)

            button.setBackgroundImage(UIImage.image(from: .purple), for: .normal)
            button.setBackgroundImage(UIImage.image(from: UIColor.purple.alphaComponent(alpha: 0.7)), for: .highlighted)

            button.layer.cornerRadius = 22.0
            button.layer.masksToBounds = true

            return button
        }()

        func install(at viewController: UIViewController) {
            viewController.view.addSubview(backImageView)
            viewController.view.addSubview(loginView)
            viewController.view.addSubview(signUpButton)

            backImageView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }

            loginView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview().inset(40)
                maker.centerY.equalToSuperview().inset(-20)
            }

            signUpButton.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview().inset(40)
                maker.height.equalTo(44)
                maker.top.equalTo(loginView.snp.bottom).offset(20)
            }
        }
    }
}
