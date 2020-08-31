//
//  SettingViewController+ViewHolder.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit

extension SettingViewController {
    class ViewHolder {
        private(set) lazy var closeBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "닫기", style: .plain, target: nil, action: nil)
        }()
    }
}
