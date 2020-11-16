//
//  File.swift
//  
//
//  Created by Julian Gentges on 13.11.20.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import cwavelib

public class WaveletTransform2D: WaveletTransform {
    
    public enum Method: CustomStringConvertible {
        case dwt(Extension)
        case swt, modwt
        
        public var description: String {
            switch self {
            case .dwt:
                return "dwt"
            case .swt:
                return "swt"
            case .modwt:
                return "modwt"
            }
        }
    }
    
    public enum Coefficient: String {
        case approximation = "A"
        case horizontal = "H"
        case vertical = "V"
        case diagonal = "D"
    }
    
    private(set) var transformObject: wt2_object
    
    public let method: Method
    public let decompositionLevels: Int
    
    var rows: Int {
        Int(transformObject.pointee.rows)
    }
    var cols: Int {
        Int(transformObject.pointee.cols)
    }
    
    var outlength: Int {
        Int(transformObject.pointee.outlength)
    }
    
    private var _maximumIterations: Int
    public var maximumIterations: Int {
        get {
            _maximumIterations
        }
        set {
            if newValue >= decompositionLevels {
                _maximumIterations = newValue
            }
        }
    }
    
    private var coeffAccessLength: Int {
        Int(transformObject.pointee.coeffaccesslength)
    }
    
    public var dimensions: [Int] {
        (0..<(rows * cols)).map { index in
            Int(transformObject.pointee.dimensions[index])
        }
    }
    
    public var coefficients: [Int] {
        (0..<coeffAccessLength).map { index in
            Int(transformObject.pointee.coeffaccess[index])
        }
    }
    
    public init(wave: Wave, method: Method, dimensions: IndexPath, decompositionLevels: Int) {
        self.method = method
        let methodName = method.description.bytes
        
        let rows = Int32(dimensions.rows)
        let cols = Int32(dimensions.cols)
        
        self.decompositionLevels = decompositionLevels
        self._maximumIterations = decompositionLevels
        let levels32 = Int32(decompositionLevels)
        
        transformObject = wt2_init(wave.waveObject, methodName, rows, cols, levels32)
        
        super.init()
    }
    
    deinit {
        wt2_free(transformObject)
    }
    
    public func forward(on signal: [Double]) -> [Double] {
        var signal = signal
        var result: UnsafeMutablePointer<Double>
        switch method {
        case .dwt:
            result = dwt2(transformObject, &signal)
        case .swt:
            result = swt2(transformObject, &signal)
        case .modwt:
            result = modwt2(transformObject, &signal)
        }
        let count = MemoryLayout.size(ofValue: result)
        return Array(UnsafeBufferPointer(start: result, count: count))
    }
    
    public func inverse(with coeff: [Double], and dimensions: IndexPath) -> [Double] {
        var coeff = coeff
        var output = [Double](repeating: 0, count: dimensions.rows * dimensions.cols)
        switch method {
        case .dwt:
            idwt2(transformObject, &coeff, &output)
        case .swt:
            iswt2(transformObject, &coeff, &output)
        case .modwt:
            imodwt2(transformObject, &coeff, &output)
        }
        return output
    }
    
    public func getCoefficients(from coefficients: [Double], at level: Int, of type: Coefficient) -> [Double] {
        let level32 = Int32(level)
        var typeName = type.rawValue.bytes
        var rows = Int32(self.rows)
        var cols = Int32(self.cols)

        var coefficients = coefficients
        let result = getWT2Coeffs(transformObject, &coefficients, level32, &typeName, &rows, &cols)
        return Array(UnsafeBufferPointer(start: result, count: MemoryLayout.size(ofValue: result)))
    }
    
    public func display(coefficients: [Double], with rows: Int, and cols: Int) {
        var coefficients = coefficients
        let rows32 = Int32(rows)
        let cols32 = Int32(cols)
        dispWT2Coeffs(&coefficients, rows32, cols32)
    }
    
    public func printSummary() {
        wt2_summary(transformObject)
    }
    
}
