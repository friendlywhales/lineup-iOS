//
//  SelectedPhotosView.swift
//  Lineup
//
//  Created by y8k on 21/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

class SelectedPhotosView: BaseView {
    /// Selected photo counts
    var count: Int? {
        didSet { bind() }
    }

    /// Indicator selected total count of photos
    private(set) lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.text = "선택된 사진 수 : 0"

        return label
    }()
    
    private(set) lazy var clearAllButton: UIButton = {
        let button = UIButton(type: .custom)

        return button
    }()

    /// Collection view for layout selected images
    private(set) lazy var selectedPhotoLayoutView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20.0
        layout.minimumLineSpacing = 5.0
        layout.itemSize = CGSize(width: 70.0, height: 70.0)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

        collectionView.register(
            PhotoSelectedCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoSelectedCollectionViewCell.reuseIdentifier
        )

        return collectionView
    }()

    override func configure() {
        super.configure()

        backgroundColor = .deepPurple

        addSubview(countLabel)
        addSubview(selectedPhotoLayoutView)

        countLabel.snp.makeConstraints { maker in
            maker.leading.equalToSuperview().inset(20)
            maker.top.equalToSuperview().inset(10)
            maker.trailing.greaterThanOrEqualToSuperview().inset(20)
        }

        selectedPhotoLayoutView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(countLabel.snp.bottom).offset(5)
            maker.bottom.equalToSuperview()
        }
    }

    override func bind() {
        super.bind()

        let selectedCount = count ?? 0

        countLabel.text = "선택된 사진 수 : \(selectedCount)"
    }
}
