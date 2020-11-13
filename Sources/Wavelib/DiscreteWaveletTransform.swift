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

public class DiscreteWaveletTransform: WaveletTransform {
    
    public enum Method: String {
        case dwt, swt, modwt
    }
    
    public enum ConvolutionMethod: String {
        case direct, fft
    }
    
    enum WaveletTransformError: LocalizedError {
        case invalidExtension, unavailableConvolution
        
        var errorDescription: String {
            switch self {
            case .invalidExtension:
                return "Extensions are only allowed for dwt transforms."
            case .unavailableConvolution:
                return "Convolution method \"FFT\" is not available for method \"modwt\"!"
            }
        }
    }
    
    private(set) var transformObject: wt_object
    
    let method: Method
    let signalLength: Int
    let decompositionLevels: Int
    
    private(set) var extensionType: Extension?
    private(set) var convolutionMethod: ConvolutionMethod = .direct
    
    private var outputLength: Int {
        Int(transformObject.pointee.outlength)
    }
    
    private var outputDimension: Int {
        Int(transformObject.pointee.lenlength)
    }
    
    var maxIterations: Int {
        get {
            Int(transformObject.pointee.MaxIter)
        }
    }
    
    public var output: [Double] {
        (0..<outputLength).map { index in
            transformObject.pointee.output[index]
        }
    }
    
    public init(wave: Wave, method: Method, signalLength: Int, decompositionLevels: Int) {
        let signalLength32 = Int32(signalLength)
        let levels = Int32(decompositionLevels)
        let rawMethod = [UInt8](method.rawValue.utf8).map { Int8($0) }
        
        self.decompositionLevels = decompositionLevels
        self.signalLength = signalLength
        self.method = method
        transformObject = wt_init(wave.waveObject, rawMethod, signalLength32, levels)
        
        super.init()
    }
    
    deinit {
        wt_free(transformObject)
    }
    
    public func setDWTExtension(_ extensionType: Extension) throws {
        guard method == .dwt else {
            throw WaveletTransformError.invalidExtension
        }
        
        let rawExtension = [UInt8](extensionType.rawValue.utf8).map { Int8($0) }
        cwavelib.setDWTExtension(transformObject, rawExtension)
        
        self.extensionType = extensionType
    }
    
    public func setWTConvolution(_ convolution: ConvolutionMethod) throws {
        guard !(method == .modwt && convolution != .fft) else {
            throw WaveletTransformError.unavailableConvolution
        }
        
        let rawConvolution = [UInt8](convolution.rawValue.utf8).map { Int8($0) }
        setWTConv(transformObject, rawConvolution)
        
        self.convolutionMethod = convolution
    }
    
    public func printSummary() {
        wt_summary(transformObject)
    }
    
}
