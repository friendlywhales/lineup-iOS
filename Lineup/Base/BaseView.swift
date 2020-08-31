//
//  BaseView.swift
//  Lineup
//
//  Created by y8k on 26/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configure()
    }

    func configure() { }

    func bind() { }
}
