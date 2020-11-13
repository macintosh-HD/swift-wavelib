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
    
    public enum WaveType: CustomStringConvertible, CaseIterable {
        case haar
        
        static func findType(by name: String) -> WaveType? {
            let onlyName = name.trimmingCharacters(in: CharacterSet.decimalDigits.union(.whitespaces)).lowercased()
            
            return allCases.first {
                $0.name == onlyName
            }
        }
        
        var name: String {
            switch self {
            case .haar:
                return "haar"
            }
        }
        
        public var description: String {
            switch self {
            case .haar:
                return name
            }
        }
    }
    
    private(set) var waveObject: wave_object
    
    var type: WaveType? {
        var wname = waveObject.pointee.wname
        let nameRaw = [Int8](UnsafeBufferPointer(start: &wname.0, count: MemoryLayout.size(ofValue: wname)))
        let name = String(cString: nameRaw)
        
        return WaveType.findType(by: name)
    }
    
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
    
    var lowPassDecompositionFilter: [Double] {
        get {
            (0..<lpDecompositionLength).map { index in
                waveObject.pointee.lpd[index]
            }
        }
    }
    
    var highPassDecompositionFilter: [Double] {
        get {
            (0..<hpDecompositionLength).map { index in
                waveObject.pointee.hpd[index]
            }
        }
    }
    
    var lowPassRecompositionFilter: [Double] {
        get {
            (0..<lpRecompositionLength).map { index in
                waveObject.pointee.lpr[index]
            }
        }
    }
    
    var highPassRecompositionFilter: [Double] {
        get {
            (0..<hpRecompositionLength).map { index in
                waveObject.pointee.hpr[index]
            }
        }
    }
    
    public init(type: WaveType) {
        waveObject = wave_init(type.description)
    }
    
    deinit {
        wave_free(waveObject)
    }
    
    func printSummary() {
        wave_summary(waveObject)
    }
    
}
