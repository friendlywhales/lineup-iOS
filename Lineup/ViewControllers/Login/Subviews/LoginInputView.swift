//
//  LoginInputView.swift
//  Lineup
//
//  Created by y8k on 27/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class LoginInputView: BaseView {
    private lazy var layoutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 3.0

        return stackView
    }()

    private(set) lazy var emailTextField: LineupTextField = {
        let textField = LineupTextField()
        textField.type = .email
        
        return textField
    }()

    private(set) lazy var passwordTextField: LineupTextField = {
        let textField = LineupTextField()
        textField.type = .password

        return textField
    }()

    override func configure() {
        super.configure()

        addSubview(layoutStackView)

        [emailTextField, passwordTextField]
            .forEach({ layoutStackView.addArrangedSubview($0) })

        layoutStackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        emailTextField.titleLabel.isHidden = true
        passwordTextField.titleLabel.isHidden = true
    }

    override func bind() {
        super.bind()

        
    }
}
