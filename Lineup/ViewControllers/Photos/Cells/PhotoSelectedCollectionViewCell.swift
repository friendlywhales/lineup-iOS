//
//  PhotoSelectedCollectionViewCell.swift
//  Lineup
//
//  Created by y8k on 04/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import QuartzCore
import Photos

class PhotoSelectedCollectionViewCell: BaseCollectionViewCell {
    static let reuseIdentifier = "\(PhotoSelectedCollectionViewCell.self)Identifier"

    private var requestID: PHImageRequestID?
    
    var viewModel: PhotoCollectionCellViewModel? {
        didSet { bind() }
    }

    private(set) lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray221
        imageView.layer.cornerRadius = 10.0
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.deepPurple.cgColor
        imageView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        imageView.layer.shadowColor = UIColor.black.alphaComponent(alpha: 0.5).cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 3.0
        imageView.layer.masksToBounds = true

        return imageView
    }()

    private(set) lazy var removeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic_close_n"), for: .normal)
        button.setImage(UIImage(named: "ic_close_h"), for: .highlighted)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true

        return button
    }()

    override func configure() {
        super.configure()

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(removeButton)

        thumbnailImageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(5)
        }

        removeButton.snp.makeConstraints { maker in
            maker.width.height.equalTo(24)
            maker.centerX.equalTo(thumbnailImageView.snp.leading).inset(3)
            maker.centerY.equalTo(thumbnailImageView.snp.top).inset(3)
        }
    }

    override func bind() {
        super.bind()

        if let requestID = requestID, requestID > 0 {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        guard let asset = viewModel?.asset else { return }

        let scale = UIScreen.main.scale
        let width = 70.0 * scale
        let size = CGSize(width: width, height: width)

        requestID = PHImageManager.default()
            .requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { (image, _) in
                self.thumbnailImageView.image = image
        }

    }
}
