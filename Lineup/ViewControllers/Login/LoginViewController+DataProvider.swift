//
//  LoginViewController+DataProvider.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension LoginViewController {
    class DataProvider {
        /// Email address string what user entered or cached in device
        let emailString = BehaviorRelay<String?>(value: nil)

        /// Password string what user entered (or cached in device)
        let passwordString = BehaviorRelay<String?>(value: nil)
    }
}
