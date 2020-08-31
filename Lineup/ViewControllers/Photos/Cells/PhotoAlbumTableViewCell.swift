//
//  PhotoAlbumTableViewCell.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumTableViewCell: BaseTableViewCell {
    static let reuseIdentifer = "\(type(of: PhotoAlbumTableViewCell.self))Identifier"

    private let imageDownloader = PHCachingImageManager.default()
    private var imageRequestID: PHImageRequestID?

    var viewModel: PhotoAlbumTableViewCellViewModel? {
        didSet { bind() }
    }

    private(set) lazy var representImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray221
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    private lazy var layoutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.alignment = .leading

        return stackView
    }()

    private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0)
        label.textAlignment = .left
        label.textColor = .black
        label.numberOfLines = 1

        return label
    }()

    private(set) lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11.0)
        label.textAlignment = .left
        label.textColor = .gray102
        label.numberOfLines = 1

        return label
    }()

    override func configure() {
        super.configure()

        tintColor = .deepPurple

        contentView.addSubview(representImageView)
        contentView.addSubview(layoutStackView)

        [titleLabel, countLabel]
            .forEach({ layoutStackView.addArrangedSubview($0) })

        representImageView.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.leading.equalToSuperview().inset(10)
            maker.width.height.equalTo(80)
        }

        layoutStackView.snp.makeConstraints { maker in
            maker.leading.equalTo(representImageView.snp.trailing).offset(10)
            maker.centerY.equalToSuperview()
        }
    }

    override var isSelected: Bool {
        didSet {
            accessoryType = isSelected ? .checkmark : .none
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        countLabel.text = nil
        representImageView.image = nil

        accessoryType = .none
    }

    override func bind() {
        super.bind()

        if let imageRequestID = imageRequestID, imageRequestID > 0 {
            imageDownloader.cancelImageRequest(imageRequestID)
        }

        imageRequestID = downloadImage(asset: viewModel?.asset)

        titleLabel.text = viewModel?.title
        countLabel.text = formattedText(count: viewModel?.count)
    }

    private func downloadImage(asset: PHAsset?) -> PHImageRequestID? {
        guard let asset = asset else { return nil }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.resizeMode = .exact
        options.deliveryMode = .fastFormat

        let scale = UIScreen.main.scale
        let size = CGSize(width: 80.0 * scale, height: 80.0 * scale)

        return imageDownloader
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, _) in
                self.representImageView.image = image
        }
    }

    private func formattedText(count: Int?) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current

        return formatter.string(from: NSNumber(value: count ?? 0))
    }
}
