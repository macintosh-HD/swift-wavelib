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

public class ContinuousWaveletTransform {
    
    public struct ContinuousWavelet {
        enum Wavelet: String {
            case morl, paul, dog
        }
        
        static func morl(parameter: Double) throws -> ContinuousWavelet? {
            guard 4...6 ~= parameter else {
                return nil
            }
            
            return ContinuousWavelet(wavelet: .morl, parameter: parameter)
        }
        
        static func paul(parameter: Int = 4) throws -> ContinuousWavelet? {
            guard 0...20 ~= parameter else {
                return nil
            }
            
            return ContinuousWavelet(wavelet: .paul, parameter: Double(parameter))
        }
        
        static func dog(parameter: UInt) throws -> ContinuousWavelet? {
            guard parameter % 2 == 0 else {
                return nil
            }
            
            return ContinuousWavelet(wavelet: .dog, parameter: Double(parameter))
        }
        
        private init(wavelet: Wavelet, parameter: Double) {
            self.wavelet = wavelet
            self.parameter = parameter
        }
        
        let wavelet: Wavelet
        let parameter: Double
    }
    
    public enum ScaleType: String {
        case power, linear
    }

    enum CWTError: LocalizedError {
        case noPower
    }
    
    private(set) var transformObject: cwt_object
    
    public init(wavelet: ContinuousWavelet, signalLength: Int, samplingRate: Double, totalScales: Int) {
        let waveName = wavelet.wavelet.rawValue.bytes
        let signalLength32 = Int32(signalLength)
        let totalScales32 = Int32(totalScales)
        
        transformObject = cwt_init(waveName, wavelet.parameter, signalLength32, samplingRate, totalScales32)
    }
    
    deinit {
        cwt_free(transformObject)
    }
    
    public func execute(on signal: inout [Double], inverse: Bool = false) {
        if inverse {
            icwt(transformObject, &signal)
        } else {
            cwt(transformObject, signal)
        }
    }
    
    public func setScales(type: ScaleType, power: Int?, s0: Double, dj: Double) throws {
        if type == .power && power == nil {
            throw CWTError.noPower
        }
        
        let typeName = type.rawValue.bytes
        let power32 = Int32(power ?? 0)
        
        setCWTScales(transformObject, s0, dj, typeName, power32)
    }
    
    public func setScales(vector: [Double], s0: Double, dj: Double) throws {
        let totalScales32 = Int32(vector.count)
        setCWTScaleVector(transformObject, vector, totalScales32, s0, dj)
    }
    
}
