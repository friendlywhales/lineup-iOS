//
//  SettingViewController.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import RxSwift
import UIKit

class SettingViewController: BaseViewController {

    private let disposeBag = DisposeBag()
    private let viewHolder = ViewHolder()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "설정"
        navigationItem.leftBarButtonItem = viewHolder.closeBarButtonItem

        bindCloseBarButtonItemAction()
    }

    private func bindCloseBarButtonItemAction() {
        viewHolder.closeBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
