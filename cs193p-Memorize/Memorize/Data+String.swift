//
//  Data+String.swift
//  Memorize
//
//  Created by David Crow on 6/9/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import Foundation

extension Data {
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}
