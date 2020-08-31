//
//  PostViewController+DataProvider.swift
//  Lineup
//
//  Created by y8k on 09/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos
import RxDataSources
import RxAlamofire
import Alamofire

struct PhotoRepresenter {
    struct PhotoSectionViewModel {
        var items: [PhotoCellViewModel]
    }

    struct PhotoCellViewModel {
        let asset: PHAsset?
        let attachIndicator: Bool

        init(attachIndicator: Bool = false, asset: PHAsset?) {
            self.attachIndicator = attachIndicator
            self.asset = asset
        }
    }
}

extension PhotoRepresenter.PhotoSectionViewModel: SectionModelType {
    typealias Item = PhotoRepresenter.PhotoCellViewModel

    init(original: PhotoRepresenter.PhotoSectionViewModel, items: [PhotoRepresenter.PhotoCellViewModel]) {
        self = original
        self.items = items
    }
}

extension PostViewController {
    class DataProvider {

        enum PostSequence {
            case idle
            case requestContentID
            case querySelectedPhotos
            case uploadSelectedPhotos
            case updateComment
            case publish
        }

        let postSequence = BehaviorRelay<PostSequence>(value: .idle)
        
        // TODO:
        // 3. place attach icon cell at first
        // 4. upload to server
        var selectedPhotos: [PHAsset]? {
            didSet {
                viewModels.accept(sectionViewModels)
            }
        }

        var comment: String?

        private(set) var contentID: String?
        
        let viewModels = BehaviorRelay<[PhotoRepresenter.PhotoSectionViewModel]>(value: [])
        let uploadProgress = BehaviorRelay<Double>(value: 0.0)

        let requests: PostRequests

        /// Cell view models (place attach indicator at first)
        private var cellViewModels: [PhotoRepresenter.PhotoCellViewModel] {
            var models = [PhotoRepresenter.PhotoCellViewModel]()

            if let photos = selectedPhotos {
                models.append(contentsOf: photos.compactMap({ PhotoRepresenter.PhotoCellViewModel(asset: $0) }))
            }

            models.insert(PhotoRepresenter.PhotoCellViewModel(attachIndicator: true, asset: nil), at: 0)

            return models
        }

        private var sectionViewModels: [PhotoRepresenter.PhotoSectionViewModel] {
            return [PhotoRepresenter.PhotoSectionViewModel(items: cellViewModels)]
        }

        required init(accessToken: String) {
            self.requests = PostRequests(accessToken: accessToken)
            viewModels.accept(sectionViewModels)
        }

        func viewModel(indexPath: IndexPath) -> PhotoRepresenter.PhotoCellViewModel {
            return viewModels.value[0].items[indexPath.row]
        }

        func prepare() -> Single<PostRequests.PreparedContentResponse> {
            postSequence.accept(.requestContentID)

            return requests.prepare().do(onSuccess: { [weak self] response in
                self?.contentID = response.contentID
            })
        }

        func cachingSelectedImages() -> Observable<[URL]>? {
            guard let observers = selectedPhotos?.compactMap({ $0.writedFileURL }) else { return nil }

            postSequence.accept(.querySelectedPhotos)

            return Observable.combineLatest(observers)
        }

        func upload(fileURL: [URL]) -> Single<Bool> {
            postSequence.accept(.uploadSelectedPhotos)

            return requests.upload(photoURLs: fileURL, progressHandler: { [weak self] progress in
                self?.uploadProgress.accept(progress)
            })
        }

        func update() -> Single<Bool> {
            postSequence.accept(.updateComment)

            return requests.comment(comment)
        }

        func publish() -> Single<Bool> {
            postSequence.accept(.publish)

            return requests.publish()
        }
    }
}
