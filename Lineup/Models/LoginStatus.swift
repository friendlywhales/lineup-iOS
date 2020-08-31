//
//  LoginStatus.swift
//  Lineup
//
//  Created by y8k on 16/05/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation

struct LoginStatus: Codable {
    let status: Bool

    enum Keys: String, CodingKey {
        case status
    }
}
