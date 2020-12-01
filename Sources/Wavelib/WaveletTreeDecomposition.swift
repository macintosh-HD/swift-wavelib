//
//  File.swift
//  
//
//  Created by Julian Gentges on 12.11.20.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import cwavelib

public class WaveletTreeDecomposition: WaveletTransform {
    
    private(set) var treeObject: wtree_object
    
    let signalLength: Int
    let decompositionLevels: Int
    
    public var maxIterations: Int {
        get {
            Int(treeObject.pointee.MaxIter)
        }
        set {
            guard newValue >= decompositionLevels else {
                return
            }
            
            let iterations = Int32(newValue)
            treeObject.pointee.MaxIter = iterations
        }
    }
    
    private(set) var `extension`: Extension?
    
    private var outlength: Int {
        Int(treeObject.pointee.outlength)
    }
    
    var coefficientsCount: [Int] {
        (0...decompositionLevels).map {
            Int(treeObject.pointee.coeflength[$0])
        }
    }
    
    public var output: [Double] {
        (0..<outlength).map {
            treeObject.pointee.output[$0]
        }
    }
    
    public init(wave: Wave, signalLength: Int, decompositionLevels: Int) {
        self.signalLength = signalLength
        let signalLength32 = Int32(signalLength)
        
        self.decompositionLevels = decompositionLevels
        let levels32 = Int32(decompositionLevels)
        
        treeObject = wtree_init(wave.waveObject, signalLength32, levels32)
        
        super.init()
    }
    
    deinit {
        wtree_free(treeObject)
    }
    
    public func execution(on signal: [Double]) {
        wtree(treeObject, signal)
    }
    
    public func set(extension: Extension) {
        self.extension = `extension`
        let extensionName = `extension`.rawValue.bytes
        setWTREEExtension(treeObject, extensionName)
    }
    
    private func nodeLength(at level: Int) -> Int {
        let level32 = Int32(level)
        let length = getWTREENodelength(treeObject, level32)
        return Int(length)
    }
    
    public func getCoefficients(at point: IndexPath) -> [Double] {
        let x = Int32(point.x)
        let y = Int32(point.y)
        let lengthAtLevel = nodeLength(at: point.x)
        let length32 = Int32(lengthAtLevel)
        var coefficients = [Double](repeating: 0, count: lengthAtLevel)
        getWTREECoeffs(treeObject, x, y, &coefficients, length32)
        return coefficients
    }
    
    public func printSummary() {
        wtree_summary(treeObject)
    }
    
}
