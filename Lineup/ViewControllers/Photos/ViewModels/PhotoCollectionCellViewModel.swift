//
//  PhotoCollectionCellViewModel.swift
//  Lineup
//
//  Created by y8k on 04/03/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxDataSources

struct PhotoCollectionSectionViewModel {
    var items: [PhotoCollectionCellViewModel]
}

extension PhotoCollectionSectionViewModel: SectionModelType {
    typealias Item = PhotoCollectionCellViewModel

    init(original: PhotoCollectionSectionViewModel, items: [PhotoCollectionCellViewModel]) {
        self = original
        self.items = items
    }
}

struct PhotoCollectionCellViewModel: Equatable {
    let asset: PHAsset?

    static func ==(lhs: PhotoCollectionCellViewModel, rhs: PhotoCollectionCellViewModel) -> Bool {
        guard lhs.asset == rhs.asset else { return false }

        return true
    }
}
