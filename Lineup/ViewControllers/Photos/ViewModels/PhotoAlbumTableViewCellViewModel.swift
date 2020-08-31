//
//  PhotoAlbumTableViewCellViewModel.swift
//  Lineup
//
//  Created by y8k on 04/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import RxDataSources
import Photos

struct PhotoAlbumTableViewSectionViewModel {
    var items: [PhotoAlbumTableViewCellViewModel]
}

extension PhotoAlbumTableViewSectionViewModel: SectionModelType {
    typealias Item = PhotoAlbumTableViewCellViewModel

    init(original: PhotoAlbumTableViewSectionViewModel, items: [PhotoAlbumTableViewCellViewModel]) {
        self = original
        self.items = items
    }
}

struct PhotoAlbumTableViewCellViewModel: Equatable {
    let fetchResult: PHFetchResult<PHAsset>?
    let asset: PHAsset?
    let title: String?
    let count: Int
    var isSelected: Bool

    static func ==(lhs: PhotoAlbumTableViewCellViewModel, rhs: PhotoAlbumTableViewCellViewModel) -> Bool {
        guard lhs.asset == rhs.asset else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.count == rhs.count else { return false }

        return true
    }
}
