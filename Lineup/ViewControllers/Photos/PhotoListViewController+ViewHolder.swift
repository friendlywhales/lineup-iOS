//
//  PhotoListViewController+ViewHolder.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import SnapKit

extension PhotoListViewController {
    class ViewHolder {

        static let photoWidth = (UIScreen.main.bounds.width - 10 - 2 * 3) / 4

        private var topConstraint: Constraint?
        private var isAlbumShowed: Bool = false

        private(set) lazy var closeBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "닫기", style: .plain, target: nil, action: nil)
        }()
        
        private(set) lazy var submitBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "완료", style: .plain, target: nil, action: nil)
        }()

        private(set) lazy var titleView: PhotoListTitleView = {
            return PhotoListTitleView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 40.0))
        }()

        /// Table view for layout albums
        private(set) lazy var albumsLayoutView: UITableView = {
            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.backgroundColor = .white
            tableView.rowHeight = 100.0

            tableView.register(
                PhotoAlbumTableViewCell.self,
                forCellReuseIdentifier: PhotoAlbumTableViewCell.reuseIdentifer
            )

            return tableView
        }()

        private(set) lazy var selectedPhotoView: SelectedPhotosView = {
            return SelectedPhotosView()
        }()

        /// Collection view for layout photos in album
        private(set) lazy var photoLayoutView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 2.0
            layout.minimumInteritemSpacing = 2.0
            layout.itemSize = CGSize(width: ViewHolder.photoWidth, height: ViewHolder.photoWidth)

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
            collectionView.backgroundColor = .white
            collectionView.alwaysBounceVertical = true
            collectionView.showsVerticalScrollIndicator = true

            collectionView.register(
                PhotoCollectionViewCell.self,
                forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier
            )

            return collectionView
        }()

        func install(at viewController: UIViewController) {
            viewController.view.addSubview(selectedPhotoView)
            viewController.view.addSubview(photoLayoutView)
            viewController.view.addSubview(albumsLayoutView)

            selectedPhotoView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview()
                maker.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
                maker.height.equalTo(130)
            }

            photoLayoutView.snp.makeConstraints { maker in
                maker.leading.trailing.bottom.equalToSuperview()
                maker.top.equalTo(selectedPhotoView.snp.bottom).offset(2)
            }

            albumsLayoutView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview()
                maker.top.equalToSuperview().offset(UIScreen.main.bounds.height)
                maker.height.equalToSuperview()
            }
        }
    }
}
