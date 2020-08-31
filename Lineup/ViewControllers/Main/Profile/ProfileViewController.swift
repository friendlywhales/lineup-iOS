//
//  ProfileViewController.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import RxSwift
import UIKit

class ProfileViewController: BaseViewController {

    private let viewHolder = ViewHolder()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "프로필"
        navigationItem.rightBarButtonItem = viewHolder.settingBarButtonItem

        bindSettingBarButtonItemAction()
    }

    private func bindSettingBarButtonItemAction() {
        viewHolder.settingBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.moveToSetting()
            }).disposed(by: disposeBag)
    }

    private func moveToSetting() {
        present(UINavigationController(rootViewController: SettingViewController()),
                animated: true,
                completion: nil)
    }
}
