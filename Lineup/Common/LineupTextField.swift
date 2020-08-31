//
//  LineupTextField.swift
//  Lineup
//
//  Created by y8k on 27/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit


struct LineUpTextFieldViewModel {
    let title: String
    let placeholder: String?
    let keyboardType: UIKeyboardType
    let isSecure: Bool

    init(title: String, placeholder: String?, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
    }
}

class LineupTextField: BaseView {
    enum InputType {
        case email
        case verifyEmail
        case password
        case verifyPassword
        case coupon
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 5.0

        return stackView
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .gray68
        label.textAlignment = .left
        label.numberOfLines = 1

        return label
    }()

    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.textColor = .gray51
        textField.font = .systemFont(ofSize: 14.0)
        textField.textAlignment = .left

        return textField
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray221

        return view
    }()

    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .lightRed
        label.numberOfLines = 0

        return label
    }()

    var type: InputType? {
        didSet {
            guard let type = type else { return }
            switch type {
            case .email:
                viewModel = LineUpTextFieldViewModel(
                    title: "이메일", placeholder: "abc@example.com", keyboardType: .emailAddress
                )
            case .verifyEmail:
                viewModel = LineUpTextFieldViewModel(
                    title: "이메일 확인", placeholder: "abc@example.com", keyboardType: .emailAddress
                )
            case .password:
                viewModel = LineUpTextFieldViewModel(
                    title: "비밀번호", placeholder: "8자리 이상", keyboardType: .asciiCapable, isSecure: true
                )
            case .verifyPassword:
                viewModel = LineUpTextFieldViewModel(
                    title: "비밀번호 확인", placeholder: "비밀번호와 동일하게 입력", keyboardType: .asciiCapable, isSecure: true
                )
            case .coupon:
                viewModel = LineUpTextFieldViewModel(
                    title: "쿠폰", placeholder: "쿠폰번호", keyboardType: .asciiCapable
                )
            }
        }
    }

    var warning: String? {
        didSet { bind() }
    }

    private var viewModel: LineUpTextFieldViewModel? {
        didSet { bind() }
    }

    override func configure() {
        super.configure()

        addSubview(stackView)

        [titleLabel, textField, lineView, warningLabel]
            .forEach({ stackView.addArrangedSubview($0) })

        stackView.snp.makeConstraints({ $0.edges.equalToSuperview() })

        textField.snp.makeConstraints({ $0.height.equalTo(20) })
        lineView.snp.makeConstraints({ $0.height.equalTo(1) })
    }

    override func bind() {
        super.bind()

        warningLabel.text = ""

        guard let viewModel = viewModel else { return }

        titleLabel.text = viewModel.title
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        textField.isSecureTextEntry = viewModel.isSecure
        warningLabel.text = warning
    }
}
