//
//  File.swift
//  
//
//  Created by Julian Gentges on 11.11.20.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import cwavelib

public class Wave {
    
    public struct Wavelet {
        public enum WaveletType: String {
            case haar
            case daubechies = "db"
            case biorthogonal = "bior"
            case coiflets = "coif"
            case symmlets = "sym"
        }
        
        private static let biorthogonalLevels: [Float] = [1.1, 1.3, 1.5, 2.2, 2.4, 2.6, 2.8, 3.1, 3.3, 3.5, 3.7, 3.9, 4.4, 5.5, 6.8]
        
        public static var haar = Wavelet(type: .haar, level: 0)
        
        public static func daubechies(_ level: Int) -> Wavelet? {
            guard 1...15 ~= level else {
                return nil
            }
            
            return Wavelet(type: .daubechies, level: Float(level))
        }
        
        public static func biorthogonal(_ level: Float) -> Wavelet? {
            guard biorthogonalLevels.contains(level) else {
                return nil
            }
            
            return Wavelet(type: .biorthogonal, level: level)
        }
        
        public static func coiflets(_ level: Int) -> Wavelet? {
            guard 1...5 ~= level else {
                return nil
            }
            
            return Wavelet(type: .coiflets, level: Float(level))
        }
        
        public static func symmlets(_ level: Int) -> Wavelet? {
            guard 2...10 ~= level else {
                return nil
            }
            
            return Wavelet(type: .symmlets, level: Float(level))
        }
        
        let type: WaveletType
        let level: Float
        
        var description: String {
            switch type {
            case .haar:
                return type.rawValue
            default:
                return "\(type.rawValue)\(level)"
            }
        }
        
        private init(type: WaveletType, level: Float) {
            self.type = type
            self.level = level
        }
    }
    
    private(set) var waveObject: wave_object
    
    let wavelet: Wavelet
    
    var filterLength: Int {
        get {
            Int(waveObject.pointee.filtlength)
        }
    }
    
    private var lpDecompositionLength: Int {
        Int(waveObject.pointee.lpd_len)
    }
    
    private var hpDecompositionLength: Int {
        Int(waveObject.pointee.hpd_len)
    }
    
    private var lpRecompositionLength: Int {
        Int(waveObject.pointee.lpr_len)
    }
    
    private var hpRecompositionLength: Int {
        Int(waveObject.pointee.hpr_len)
    }
    
    public var lowPassDecompositionFilter: [Double] {
        get {
            (0..<lpDecompositionLength).map { index in
                waveObject.pointee.lpd[index]
            }
        }
    }
    
    public var highPassDecompositionFilter: [Double] {
        get {
            (0..<hpDecompositionLength).map { index in
                waveObject.pointee.hpd[index]
            }
        }
    }
    
    public var lowPassRecompositionFilter: [Double] {
        get {
            (0..<lpRecompositionLength).map { index in
                waveObject.pointee.lpr[index]
            }
        }
    }
    
    public var highPassRecompositionFilter: [Double] {
        get {
            (0..<hpRecompositionLength).map { index in
                waveObject.pointee.hpr[index]
            }
        }
    }
    
    public init(wavelet: Wavelet) {
        self.wavelet = wavelet
        waveObject = wave_init(wavelet.description)
    }
    
    deinit {
        wave_free(waveObject)
    }
    
    public func printSummary() {
        wave_summary(waveObject)
    }
    
}
