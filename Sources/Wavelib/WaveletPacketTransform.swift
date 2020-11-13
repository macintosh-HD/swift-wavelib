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

public class WaveletPacketTransform: WaveletTransform {
    
    public enum Entropy: String {
        case shannon, threshold, norm, logenergy
    }
    
    private(set) var packetObject: wpt_object
    private(set) var entropy: Entropy = .shannon
    
    private var outLength: Int {
        Int(packetObject.pointee.outlength)
    }
    
    public var output: [Double] {
        (0..<outLength).map { index in
            packetObject.pointee.output[index]
        }
    }
    
    public init(wave: Wave, signalLength: Int, decompositionLevels: Double) {
        let signalLength32 = Int32(signalLength)
        let levels32 = Int32(decompositionLevels)
        
        packetObject = wpt_init(wave.waveObject, signalLength32, levels32)
        
        super.init()
    }
    
    deinit {
        wpt_free(packetObject)
    }
    
    public func execute(on signal: inout [Double], inverse: Bool = false) {
        if inverse {
            idwpt(packetObject, &signal)
        } else {
            dwpt(packetObject, signal)
        }
    }
    
    public func set(extension: Extension) {
        let extensionName = `extension`.rawValue.bytes
        setDWPTExtension(packetObject, extensionName)
    }
    
    func nodeLength(at level: Int) -> Int {
        let level32 = Int32(level)
        let length32 = getDWPTNodelength(packetObject, level32)
        return Int(length32)
    }
    
    public func coefficients(at point: IndexPath) -> [Double] {
        let x = Int32(point.x)
        let y = Int32(point.y)
        let length = nodeLength(at: point.x)
        let length32 = Int32(length)
        var coefficients = [Double](repeating: 0, count: length)
        getDWPTCoeffs(packetObject, x, y, &coefficients, length32)
        return coefficients
    }
    
    public func set(entropy: Entropy, parameter: Double) {
        let entropyName = entropy.rawValue.bytes
        setDWPTEntropy(packetObject, entropyName, parameter)
        self.entropy = entropy
    }
    
    public func printSummary() {
        wpt_summary(packetObject)
    }
    
}
