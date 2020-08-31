//
//  URL+extension.swift
//  Lineup
//
//  Created by y8k on 09/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation

extension URL {
    var parameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        guard let queryItem = components.queryItems else { return nil }

        return queryItem.reduce(
            into: [String: String](), { result, item in
                result[item.name] = item.value
        })
    }
}
