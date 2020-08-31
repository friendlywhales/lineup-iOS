//
//  LoginViewController.swift
//  Lineup
//
//  Created by y8k on 26/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    private let viewHolder = ViewHolder()
    private let dataProvider = DataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewHolder.install(at: self)

        bindSignUpButtonAction()
        bindLoginButtonAction()
        bindInputValuesIsChanged()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    /// Move to sign up scren
    private func moveToSignUp() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }

    /// Before request to server, valid input values
    private func processingLogin() {

    }

    private func bindEventWhenChangedInputValues() {

    }
}

private extension LoginViewController {
    /// Bind sign up button action
    func bindSignUpButtonAction() {
        viewHolder.signUpButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.moveToSignUp()
            }).disposed(by: disposeBag)
    }

    /// Bind login button action
    func bindLoginButtonAction() {
        viewHolder.loginView.loginButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.processingLogin()
            }).disposed(by: disposeBag)
    }

    func bindEmailTextFieldEvent() {
        viewHolder.loginView.loginInputView.emailTextField.textField.rx.text
            .subscribe(onNext: { text in

            }).disposed(by: disposeBag)

        viewHolder.loginView.loginInputView.emailTextField.textField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { _ in

            }).disposed(by: disposeBag)
    }

    func bindPasswordTextFieldEvent() {
        viewHolder.loginView.loginInputView.passwordTextField.textField.rx.text
            .subscribe(onNext: { text in

            }).disposed(by: disposeBag)

        viewHolder.loginView.loginInputView.passwordTextField.textField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { _ in

            }).disposed(by: disposeBag)
    }

    func bindInputValuesIsChanged() {
        dataProvider.emailString
            .subscribe(onNext: { email in

            }).disposed(by: disposeBag)

        dataProvider.passwordString
            .subscribe(onNext: { password in

            }).disposed(by: disposeBag)
    }
}
