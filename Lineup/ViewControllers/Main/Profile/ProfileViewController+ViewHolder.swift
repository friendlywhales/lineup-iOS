//
//  ProfileViewController+ViewHolder.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit

extension ProfileViewController {
    class ViewHolder {
        private(set) lazy var settingBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "설정", style: .plain, target: nil, action: nil)
        }()
    }
}
