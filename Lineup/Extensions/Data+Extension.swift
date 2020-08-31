//
//  Data+Extension.swift
//  Lineup
//
//  Created by y8k on 14/05/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
