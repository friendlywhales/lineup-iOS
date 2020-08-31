//
//  LoginView.swift
//  Lineup
//
//  Created by y8k on 26/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class LoginView: BaseView {
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .purple

        return imageView
    }()

    private lazy var supplementLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .regular)
        label.textAlignment = .center
        label.textColor = UIColor(red: 117.0 / 255.0, green: 56.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
        label.text = "지금 시작하세요!"

        return label
    }()

    private(set) lazy var loginInputView: LoginInputView = {
        return LoginInputView()
    }()

    private(set) lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .medium)
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.setTitleColor(UIColor.purple.alphaComponent(alpha: 0.7), for: .highlighted)

        button.layer.borderColor = UIColor.purple.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 22.0
        button.layer.masksToBounds = true

        return button
    }()

    override func configure() {
        super.configure()

        addSubview(logoImageView)
        addSubview(supplementLabel)
        addSubview(loginInputView)
        addSubview(loginButton)

        logoImageView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(20)
            maker.centerX.equalToSuperview()
            maker.width.equalTo(177)
            maker.height.equalTo(46)
        }

        supplementLabel.snp.makeConstraints { maker in
            maker.top.equalTo(logoImageView.snp.bottom).offset(5)
            maker.leading.trailing.equalToSuperview()
        }

        loginInputView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.equalTo(supplementLabel.snp.bottom).offset(10)
        }

        loginButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(44)
            maker.top.equalTo(loginInputView.snp.bottom).offset(10)
            maker.bottom.equalToSuperview().inset(20)
        }
    }

    override func bind() {
        super.bind()

    }
}
