//
//  BaseCollectionViewCell.swift
//  Lineup
//
//  Created by y8k on 04/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
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
