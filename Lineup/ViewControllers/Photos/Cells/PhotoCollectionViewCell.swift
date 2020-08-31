//
//  PhotoCollectionViewCell.swift
//  Lineup
//
//  Created by y8k on 04/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: BaseCollectionViewCell {
    static let reuseIdentifier = "\(type(of: PhotoCollectionViewCell.self))Identifier"

    var viewModel: PhotoCollectionCellViewModel? {
        didSet { bind() }
    }

    var sequence: Int? {
        didSet {
            if let sequence = sequence {
                thumbnailImageView.layer.borderWidth = 5.0
                indexBackView.isHidden = false
                indexLabel.text = "\(sequence + 1)"
            } else {
                thumbnailImageView.layer.borderWidth = 0.0
                indexBackView.isHidden = true
                indexLabel.text = nil
            }
        }
    }

    private var requestID: PHImageRequestID?

    private(set) lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray221
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.deepPurple.cgColor

        return imageView
    }()

    private(set) lazy var indexBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .deepPurple
        view.isHidden = true

        return view
    }()

    private(set) lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.0, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1

        return label
    }()

    override func configure() {
        super.configure()

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(indexBackView)

        indexBackView.addSubview(indexLabel)

        thumbnailImageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        indexBackView.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.top.equalToSuperview()
            maker.width.equalTo(30)
            maker.height.equalTo(30)
        }

        indexLabel.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImageView.image = nil
        indexBackView.isHidden = true
        indexLabel.text = nil
    }

    override func bind() {
        super.bind()

        if let requestID = requestID, requestID > 0 {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        guard let asset = viewModel?.asset else { return }

        let scale = UIScreen.main.scale
        let width = (UIScreen.main.bounds.width - 10.0 - 2 * 3) / 4
        let size = CGSize(width: width * scale, height: width * scale)

        let option = PHImageRequestOptions()
        option.isSynchronous = true
        option.isNetworkAccessAllowed = true

        requestID = PHImageManager.default()
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: option) { (image, _) in
                self.thumbnailImageView.image = image
        }

    }
}
