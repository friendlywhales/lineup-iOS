//
//  BaseTableViewCell.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configure()
    }

    func configure() { }
    func bind() { }
}
