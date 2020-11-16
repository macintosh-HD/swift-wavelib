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
            first ?? 0
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
            second ?? 0
        }
        set {
            if count > 1 {
                self[1] = newValue
            } else {
                append(newValue)
            }
        }
    }
}

extension IndexPath {
    init(rows: Int, cols: Int) {
        self.init(arrayLiteral: rows, cols)
    }
    
    var rows: Int {
        get {
            first ?? 0
        }
        set {
            if isEmpty {
                append(newValue)
            } else {
                self[0] = newValue
            }
        }
    }
    
    var cols: Int {
        get {
            second ?? 0
        }
        set {
            if count > 1 {
                self[1] = newValue
            } else {
                append(newValue)
            }
        }
    }
}

extension IndexPath {
    var second: Element? {
        guard count > 1 else {
            return nil
        }
        
        return self[1]
    }
}
