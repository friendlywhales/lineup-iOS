//
//  PhotoListViewController.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxDataSources
import Alamofire

class PhotoListViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let viewHolder = ViewHolder()

    private var isAlbumShowed: Bool = false
    private let dataProvider: DataProvider

    /// Completion handler when ending selection
    var completion: (([PHAsset]?) -> Void)?

    /// Data source for layout album list
    private var albumDataSource: RxTableViewSectionedReloadDataSource<PhotoAlbumTableViewSectionViewModel>?
    /// Data source for photos list
    private var photoDataSource: RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel>?
    /// Data source for selected photo list
    private var selectedPhotoDataSource: RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel>?

    required init(albums: [PhotoAlbum], selectedPhotos: [PHAsset]?, completion: (([PHAsset]?) -> Void)?) {
        self.dataProvider = DataProvider(albums: albums, selectedPhotos: selectedPhotos)
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewHolder.install(at: self)

        navigationItem.titleView = viewHolder.titleView

        navigationItem.leftBarButtonItem = viewHolder.closeBarButtonItem
        navigationItem.rightBarButtonItem = viewHolder.submitBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = false

        viewHolder.titleView.title = dataProvider.selectedPhotoAlbum.value?.title

        albumDataSource = dataSourceForAlbums()
        photoDataSource = dataSourceForPhotos()
        selectedPhotoDataSource = dataSourceForSelectedPhotos()

        bindCloseBarButtonItemAction()
        bindSubmitBarButtonItemAction()
        bindCanSubmitEvent()

        bindTitleViewChangedEvent()
        bindAlbumDataSource()
        bindPhotoDataSource()
        bindSelectedPhotoDataSource()
        bindChangedCurrentAlbum()
    }

    private func dismissScreen() {
        dismiss(animated: true, completion: {
            self.dataProvider.selectedPhotos.removeAll()
        })
    }

    private func bindTitleViewChangedEvent() {
        viewHolder.titleView.rx.controlEvent(.touchUpInside)
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.showAlbumList()
            }).disposed(by: disposeBag)
    }

    private func bindCanSubmitEvent() {
        dataProvider.canSubmit.asDriver().drive(onNext: { [weak self] canSubmit in
            self?.viewHolder.submitBarButtonItem.isEnabled = canSubmit
        }).disposed(by: disposeBag)
    }

    private func bindCloseBarButtonItemAction() {
        viewHolder.closeBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.dismissScreen()
            }).disposed(by: disposeBag)
    }

    private func bindSubmitBarButtonItemAction() {
        viewHolder.submitBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.completion?(self?.dataProvider.selectedPhotos)
                self?.dismissScreen()
            }).disposed(by: disposeBag)
    }

    private func bindChangedCurrentAlbum() {
        dataProvider.selectedPhotoAlbum
            .asDriver()
            .drive(onNext: { [weak self] album in
                self?.viewHolder.titleView.title = album?.title
            }).disposed(by: disposeBag)
    }

    /// Bind album list models to albums layout view
    private func bindAlbumDataSource() {
        guard let dataSource = albumDataSource else { return }

        dataProvider.albumViewModels
            .bind(to: viewHolder.albumsLayoutView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewHolder.albumsLayoutView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.dataProvider.changeSelectedAlbum(indexPath: indexPath)
                self?.viewHolder.photoLayoutView
                    .scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self?.viewHolder.albumsLayoutView.reloadData()
                self?.showAlbumList()
            }).disposed(by: disposeBag)
    }

    private func alert(message: String) {
        let alertController = UIAlertController(title: "앗!", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)

        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }

    private func bindPhotoDataSource() {
        guard let dataSource = photoDataSource else { return }

        dataProvider.photoViewModels
            .bind(to: viewHolder.photoLayoutView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        viewHolder.photoLayoutView.rx.willDisplayCell
            .asDriver().drive(onNext: { [weak self] (cell, indexPath) in
                guard let cell = cell as? PhotoCollectionViewCell else { return }
                cell.sequence = self?.dataProvider.attachedSequence(indexPath: indexPath)
            }).disposed(by: disposeBag)

        viewHolder.photoLayoutView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let asset = self?.dataProvider.assetFromPhotos(indexPath: indexPath) else { return }
                guard asset.pixelWidth > 500 && asset.pixelHeight > 500 else {
                    self?.alert(message: "이미지 사이즈는 최소 500px 이상이어야 합니다.")
                    return
                }

                self?.dataProvider.selectPhoto(asset: asset)

                guard let indexPaths = self?.viewHolder.photoLayoutView.indexPathsForVisibleItems else { return }

                self?.viewHolder.photoLayoutView.reloadItems(at: indexPaths)

                guard let rowCount = self?.dataProvider.selectedPhotos.count, rowCount > 0 else { return }

                self?.viewHolder.selectedPhotoView.selectedPhotoLayoutView
                    .scrollToItem(at: IndexPath(row: rowCount - 1, section: 0), at: .right, animated: true)
            }).disposed(by: disposeBag)
    }

    private func bindSelectedPhotoDataSource() {
        guard let dataSource = selectedPhotoDataSource else { return }

        dataProvider.selectedPhotosViewModels
            .bind(to: viewHolder.selectedPhotoView.selectedPhotoLayoutView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        dataProvider.selectedPhotosViewModels
            .map { sectionViewModels -> Int in
                return sectionViewModels.compactMap({ $0.items }).reduce([], +).count
            }.subscribe(onNext: { [weak self] count in
                self?.viewHolder.selectedPhotoView.count = count
            }).disposed(by: disposeBag)

        viewHolder.selectedPhotoView.selectedPhotoLayoutView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let asset = self?.dataProvider.assetFromSelectedPhotos(indexPath: indexPath) else { return }
                self?.dataProvider.selectPhoto(asset: asset)

                if let indexPaths = self?.viewHolder.photoLayoutView.indexPathsForVisibleItems {
                    self?.viewHolder.photoLayoutView.reloadItems(at: indexPaths)
                }
            }).disposed(by: disposeBag)
    }

    /// Show or hide albums list
    private func showAlbumList(animated: Bool = true) {
        isAlbumShowed = !isAlbumShowed
        let options: UIViewAnimationOptions = isAlbumShowed ? .curveEaseOut : .curveEaseIn

        viewHolder.albumsLayoutView.snp.updateConstraints { maker in
            if isAlbumShowed {
                maker.top.equalToSuperview()
            } else {
                maker.top.equalToSuperview().offset(UIScreen.main.bounds.height)
            }
        }
        viewHolder.albumsLayoutView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        viewHolder.albumsLayoutView.updateConstraints()

        let animation = {
            self.view.layoutIfNeeded()
            self.viewHolder.titleView.indicator.transform =
                self.isAlbumShowed ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: options, animations: animation, completion: nil)
        } else {
            animation()
        }
    }
}

extension PhotoListViewController {
    /// Data source for album listing
    private func dataSourceForAlbums() -> RxTableViewSectionedReloadDataSource<PhotoAlbumTableViewSectionViewModel> {
        return RxTableViewSectionedReloadDataSource<PhotoAlbumTableViewSectionViewModel>(
            configureCell: { dataSource, tableView, indexPath, viewModel in
                let identifier = PhotoAlbumTableViewCell.reuseIdentifer
                guard let cell = tableView
                    .dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? PhotoAlbumTableViewCell else {
                        fatalError("")
                }

                cell.viewModel = viewModel

                if let album = self.dataProvider.selectedPhotoAlbum.value, album == viewModel {
                    cell.isSelected = true
                } else {
                    cell.isSelected = false
                }

                return cell
        })
    }

    private func dataSourceForPhotos() -> RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel> {
        return RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel>(
            configureCell: { dataSource, collectionView, indexPath, viewModel in
                let identifier = PhotoCollectionViewCell.reuseIdentifier
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: identifier, for: indexPath) as? PhotoCollectionViewCell else { fatalError() }

                cell.viewModel = viewModel

                return cell
        })
    }

    private func dataSourceForSelectedPhotos() ->
        RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel> {
        return RxCollectionViewSectionedReloadDataSource<PhotoCollectionSectionViewModel>(
            configureCell: { dataSource, collectionView, indexPath, viewModel in
                let identifier = PhotoSelectedCollectionViewCell.reuseIdentifier
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: identifier, for: indexPath
                ) as? PhotoSelectedCollectionViewCell else { fatalError() }

                cell.viewModel = viewModel

                return cell
        })
    }
}
