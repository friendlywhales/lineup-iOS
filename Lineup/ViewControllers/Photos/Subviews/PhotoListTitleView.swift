//
//  PhotoListTitleView.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class PhotoListTitleView: UIControl {
    /// Represent album name
    var title: String? {
        didSet { bind() }
    }

    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false

        return view
    }()

    private lazy var layoutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2.0

        return stackView
    }()

    private(set) lazy var albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.textColor = .gray51
        label.numberOfLines = 1
        label.textAlignment = .center
        label.snp.makeConstraints({ $0.width.greaterThanOrEqualTo(0) })

        return label
    }()

    private(set) lazy var indicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_arrow_drop_n"))
        imageView.snp.makeConstraints({ $0.width.height.equalTo(16) })

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        addSubview(backgroundView)
        backgroundView.addSubview(layoutStackView)

        [albumTitleLabel, indicator]
            .forEach({ layoutStackView.addArrangedSubview($0) })

        backgroundView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.bottom.equalToSuperview()
        }

        layoutStackView.snp.makeConstraints { maker in
            maker.width.lessThanOrEqualToSuperview()
            maker.centerX.equalToSuperview()
            maker.top.bottom.equalToSuperview()
        }
    }

    private func bind() {
        albumTitleLabel.text = title
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
}
