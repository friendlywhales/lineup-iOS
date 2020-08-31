//
//  PhotoListViewController+DataProvider.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Photos
import RxSwift
import RxCocoa

extension PhotoListViewController {
    class DataProvider {
        /// Maximum photo count for selection
        static let maximumCount = 30

        /// Selected photo for preparing download
        var selectedPhotos = [PHAsset]() {
            didSet {
                arrangePhotos()
            }
        }

        /// Enable submit button or not
        let canSubmit = BehaviorRelay<Bool>(value: false)

        /// Selected photos view model for drawing tableview
        let selectedPhotosViewModels: BehaviorRelay<[PhotoCollectionSectionViewModel]>

        /// Album view models
        let albumViewModels: BehaviorRelay<[PhotoAlbumTableViewSectionViewModel]>

        /// photo view models
        let photoViewModels: BehaviorRelay<[PhotoCollectionSectionViewModel]>

        /// Selected album
        let selectedPhotoAlbum: BehaviorRelay<PhotoAlbumTableViewCellViewModel?>

        required init(albums: [PhotoAlbum], selectedPhotos: [PHAsset]?) {
            let cellViewModels = albums.enumerated().compactMap({
                PhotoAlbumTableViewCellViewModel(
                    fetchResult: $0.element.fetchResult,
                    asset: $0.element.fetchResult.firstObject,
                    title: $0.element.title,
                    count: $0.element.count,
                    isSelected: $0.offset == 0 ? true : false
                )
            })

            self.selectedPhotoAlbum = BehaviorRelay(value: cellViewModels.first)
            self.albumViewModels = BehaviorRelay(value: [PhotoAlbumTableViewSectionViewModel(items: cellViewModels)])

            self.photoViewModels = BehaviorRelay(
                value: DataProvider.arrangePhotos(fetchResult: cellViewModels.first?.fetchResult)
            )

            self.selectedPhotos = selectedPhotos ?? []

            let selectedPhotoViewModels = selectedPhotos?.compactMap({ PhotoCollectionCellViewModel(asset: $0) }) ?? []
            self.selectedPhotosViewModels = BehaviorRelay(
                value: [PhotoCollectionSectionViewModel(items: selectedPhotoViewModels)])
        }

        private func arrangePhotos() {
            canSubmit.accept(selectedPhotos.isEmpty ? false : true)

            selectedPhotosViewModels
                .accept([PhotoCollectionSectionViewModel(
                    items: selectedPhotos.map({ PhotoCollectionCellViewModel(asset: $0) })
                    )]
            )
        }

        func assetFromPhotos(indexPath: IndexPath) -> PHAsset? {
            return photoViewModels.value[indexPath.section].items[indexPath.row].asset
        }

        func assetFromSelectedPhotos(indexPath: IndexPath) -> PHAsset? {
            return selectedPhotosViewModels.value[indexPath.section].items[indexPath.row].asset
        }

        /// Select/deselect photos
        func selectPhoto(asset: PHAsset) {
            if let index = selectedPhotos.firstIndex(where: { $0 == asset }) {
                selectedPhotos.remove(at: index)
            } else {
                guard selectedPhotos.count < DataProvider.maximumCount else { return }
                selectedPhotos.append(asset)
            }

            arrangePhotos()
        }

        /// Attached sequence for representing to UIs
        func attachedSequence(indexPath: IndexPath) -> Int? {
            guard let asset = photoViewModels.value[indexPath.section].items[indexPath.row].asset else { return nil }
            return selectedPhotos.index(of: asset)
        }

        /// Query photos in album
        private static func arrangePhotos(fetchResult: PHFetchResult<PHAsset>?) -> [PhotoCollectionSectionViewModel] {
            guard let fetchResult = fetchResult else { return [] }

            var viewModels = [PhotoCollectionCellViewModel]()
            fetchResult.enumerateObjects { (asset, _, _) in
                viewModels.append(PhotoCollectionCellViewModel(asset: asset))
            }

            return [PhotoCollectionSectionViewModel(items: viewModels)]
        }

        /// Change album
        func changeSelectedAlbum(indexPath: IndexPath) {
            let album = albumViewModels.value[indexPath.section].items[indexPath.row]

            photoViewModels.accept(DataProvider.arrangePhotos(fetchResult: album.fetchResult))
            selectedPhotoAlbum.accept(album)
        }
    }
}
