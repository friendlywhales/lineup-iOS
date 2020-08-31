//
//  PhotoManager.swift
//  Lineup
//
//  Created by y8k on 28/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit
import Photos
import RxCocoa
import RxSwift

struct PhotoAlbum {
    let title: String?
    let count: Int
    let fetchResult: PHFetchResult<PHAsset>
}

class PhotoManager: NSObject {
    private let disposeBag = DisposeBag()

    static let shared = PhotoManager()

    /// For representing view controller as list or need authorization
    /// - warning: if nil, no list, no need authorization screen
    private weak var targetViewController: UIViewController?

    let selectedPhotos = BehaviorRelay<[PHAsset]?>(value: nil)

    var currentStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }

    required override init() {
        super.init()
        self.cachingPhotos()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    private func cachingPhotos() {
        guard currentStatus == .authorized else { return }

        PHPhotoLibrary.shared().register(self)
    }

    func presentPhotoListIfAvailable(from viewController: UIViewController) {
        targetViewController = viewController

        processingAuthorization(currentStatus)
    }
}

// MARK: - Related to fetch assets
private extension PhotoManager {
    /// Fetch album as all photos
    var allPhotoAlbum: Single<PhotoAlbum> {
        return Single.create(subscribe: { observer -> Disposable in
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let result = PHAsset.fetchAssets(with: .image, options: options)

            observer(.success(PhotoAlbum(title: "모든 사진", count: result.count, fetchResult: result)))

            return Disposables.create()
        })

    }

    /// Fetch albums as created by user
    var userAlbums: Single<[PhotoAlbum]> {
        return Single.create(subscribe: { observer -> Disposable in
            var albums = [PhotoAlbum]()

            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let collectionResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            collectionResult.enumerateObjects { (collection, _, _) in
                let result = PHAsset.fetchAssets(in: collection, options: options)
                guard result.count > 0 else { return }

                albums.append(PhotoAlbum(title: collection.localizedTitle, count: result.count, fetchResult: result))
            }

            observer(.success(albums))

            return Disposables.create()
        })
    }

    /// Fetch all photo albums
    func fetchAllAlbums() -> Single<[PhotoAlbum]?> {
        return Observable
            .combineLatest(allPhotoAlbum.asObservable(), userAlbums.asObservable())
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { (allPhotoAlbum, userAlbums) -> [PhotoAlbum] in
                return [allPhotoAlbum] + userAlbums
            }
            .observeOn(MainScheduler.instance).asSingle()
    }
}

// MARK: - Related to AuthorizationStatus
private extension PhotoManager {
    /// Request authoriztion to access photos
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            self.processingAuthorization(status)
        }
    }

    /// Processing in according to status
    func processingAuthorization(_ status: PHAuthorizationStatus) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            presentNeedAuthorizationAlert()
        case .authorized:
            presentPhotoListScreen()
        }
    }

    /// Present need authorization screen to user
    func presentNeedAuthorizationAlert() {
        let alertController = UIAlertController(
            title: "사진에 접근할 수 없습니다.",
            message: "iPhone에 있는 사진을 Lineup에 업로드 하기 위해서는 사진 접근 권한이 필요합니다.\n사진 접근 권한 허용을 해주세요.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let moveAction = UIAlertAction(title: "허용하기", style: .default) { _ in
            self.moveToSetting()
        }

        [cancelAction, moveAction]
            .forEach({ alertController.addAction($0) })

        targetViewController?.present(alertController, animated: true, completion: nil)
    }

    func moveToSetting() {
        guard let URL = URL(string: UIApplicationOpenSettingsURLString),
            UIApplication.shared.canOpenURL(URL) else { return }

        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
    }

    /// Present photo lists
    func presentPhotoListScreen() {
        fetchAllAlbums().subscribe(onSuccess: { [weak self] albums in
            self?.showAlbums(albums: albums)
        }).disposed(by: disposeBag)
    }

    private func showAlbums(albums: [PhotoAlbum]?) {
        guard let albums = albums else { return }

        let photoListViewController = PhotoListViewController(
            albums: albums,
            selectedPhotos: selectedPhotos.value,
            completion: { [weak self] assets in
                self?.selectedPhotos.accept(assets)
        })

        let navigationController = UINavigationController(rootViewController: photoListViewController)

        targetViewController?.present(navigationController, animated: true, completion: nil)
    }
}

extension PhotoManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {

    }
}
