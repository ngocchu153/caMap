//
//  Category.swift
//  caMap
//
//  Created by ngoChu on 12/22/17.
//  Copyright © 2017 Ngoc. All rights reserved.
//

import Foundation

struct Category {
    var name:String
    init(name:String) {
        self.name = name
    }
}

extension Category: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.name = value
    }
    init(unicodeScalarLiteral value: String) {
        self.init(name: value)
    }
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(name: value)
    }
}
