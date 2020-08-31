//
//  PostPhotoCollectionViewCollectionViewCell.swift
//  Lineup
//
//  Created by y8k on 09/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import Photos

class PostPhotoCollectionViewCollectionViewCell: BaseCollectionViewCell {
    static let reuseIdentifier = "\(type(of: PostPhotoCollectionViewCollectionViewCell.self)).identifier"

    var viewModel: PhotoRepresenter.PhotoCellViewModel? {
        didSet { bind() }
    }

    private var requestID: PHImageRequestID?

    private(set) lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill

        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true

        return imageView
    }()

    override func configure() {
        super.configure()

        contentView.addSubview(photoImageView)

        photoImageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(5)
        }
    }

    override func bind() {
        super.bind()

        guard viewModel?.attachIndicator == false else {
            photoImageView.image = UIImage(named: "ic_img_add_n") // attach indicator
            photoImageView.contentMode = .center
            return
        }

        if let requestID = requestID, requestID > 0 {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        guard let asset = viewModel?.asset else { return }

        let scale = UIScreen.main.scale
        let superviewSize = contentView.bounds.size
        let size = CGSize(width: superviewSize.width * scale, height: superviewSize.height * scale)

        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                self?.photoImageView.image = image
                self?.photoImageView.contentMode = .scaleAspectFill
        }
    }
}
