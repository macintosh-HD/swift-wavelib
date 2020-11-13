//
//  File.swift
//  
//
//  Created by Julian Gentges on 12.11.20.
//

import Foundation

extension String {
    var bytes: [Int8] {
        [UInt8](utf8).map { Int8($0) }
    }
}
