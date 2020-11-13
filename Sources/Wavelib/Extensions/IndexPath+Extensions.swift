//
//  File.swift
//  
//
//  Created by Julian Gentges on 12.11.20.
//

import Foundation

extension IndexPath {
    init(x: Int, y: Int) {
        self.init(arrayLiteral: x, y)
    }
    
    var x: Int {
        get {
            if isEmpty {
                return 0
            } else {
                return first!
            }
        }
        set {
            if isEmpty {
                append(newValue)
            } else {
                self[0] = newValue
            }
        }
    }
    
    var y: Int {
        get {
            if count < 2 {
                return 0
            } else {
                return self[1]
            }
        }
        set {
            if count < 2 {
                append(newValue)
            } else {
                self[1] = newValue
            }
        }
    }
}
