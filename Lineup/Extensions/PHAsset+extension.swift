//
//  PHAsset+extension.swift
//  Lineup
//
//  Created by y8k on 09/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import MobileCoreServices

extension PHAsset {
    var filename: String? {
        return PHAssetResource.assetResources(for: self).compactMap({ $0.originalFilename }).first
    }

    var fullSizeImageURL: Observable<URL> {
        return Observable.create({ observer -> Disposable in
            let options = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true

            self.requestContentEditingInput(with: options, completionHandler: { input, _ in
                guard let fullSizeImageURL = input?.fullSizeImageURL else {
                    return
                }

                observer.onNext(fullSizeImageURL)
                observer.onCompleted()
            })

            return Disposables.create()
        })
    }

    func convertToJPEG(data: Data?, quality: CGFloat = 0.9) -> Data? {
        guard let data = data, let image = UIImage(data: data) else { return nil }
        return UIImageJPEGRepresentation(image, quality)
    }

    var writedFileURL: Observable<URL> {
        return Observable.create({ observer -> Disposable in
            let filename = self.filename ?? "Unknown"
            let components = filename.components(separatedBy: ".")

            let option = PHImageRequestOptions()
            option.isNetworkAccessAllowed = true
            option.isSynchronous = false
            option.deliveryMode = .highQualityFormat

            PHImageManager.default()
                .requestImageData(for: self, options: option, resultHandler: { data, uti, orientation, info in
                    guard let data = data, data.isEmpty == false else {
                        observer.onError(LineUpErrors.errorWritePhotoToTempDirectory)
                        return
                    }

                    var directoryURL = FileManager.default.temporaryDirectory

                    var imageData = data
                    if uti != kUTTypeJPEG as String, let jpegData = self.convertToJPEG(data: data) {
                        imageData = jpegData
                    }

                    directoryURL.appendPathComponent((components.first ?? "Unknown") + ".jpeg")

                    guard !FileManager.default.fileExists(atPath: directoryURL.path) else {
                        observer.onNext(directoryURL)
                        return
                    }

                    if FileManager.default.createFile(atPath: directoryURL.path, contents: imageData, attributes: nil) {
                        observer.onNext(directoryURL)
                    } else {
                        observer.onError(LineUpErrors.errorWritePhotoToTempDirectory)
                    }
                    observer.onCompleted()
            })

            return Disposables.create()
        })
    }
}
