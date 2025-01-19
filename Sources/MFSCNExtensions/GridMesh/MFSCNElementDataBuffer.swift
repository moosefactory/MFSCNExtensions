//   /\/\__/\/\      MFSCNExtensions
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2025 - Moose
//    Software
//  ------------------------------------------
//  􀈿 MFSCNElementDataBuffer.swift
//  􀐚 MFSCNExtensions
//  􀓣 Created by Tristan Leblanc on 30/12/2024.

import Foundation
import MFGridUtils

/// The ElementDataBuffer class is responsible of raw buffers creation and management.

public class MFSCNElementDataBuffer<T>: CustomStringConvertible {
    
    enum Errors: Error {
        case memoryError
    }
    
    public var description: String {
        [
            "Buffer <\(T.self)>",
            "capacity:\(allocatedCapacity)",
            "numberOfElements:\(numberOfElements)",
            "data:\(data)"
        ].joined(separator: "\r")
    }
    
    public var data: Data {
        guard let buffer = buffer else {
            return Data()
        }
        return NSData(bytesNoCopy: buffer, length: neededCapacity, freeWhenDone: true) as Data
    }
    
    var array: [T] {
        
        guard let elementsPtr = buffer?.bindMemory(to: T.self, capacity: numberOfElements) else {
            return []
        }
        let elementsArray = UnsafeBufferPointer(start: elementsPtr, count: numberOfElements)
        return Array(elementsArray)
    }
    
    private var buffer: UnsafeMutableRawPointer?
    
    public private(set) var elementsArray: UnsafeMutablePointer<T>!
    
    public let numberOfElements: Int
    
    /// Returns the needed capacity to allocate the buffer
    public var neededCapacity: Int { numberOfElements * MemoryLayout<T>.stride }
    public private(set) var allocatedCapacity: Int = 0
    
    static func populate(buffer: UnsafeMutableRawPointer,
                         numberOfElements: Int,
                         elementProcessor: (Int)->T) {
        let bufferArray = buffer.bindMemory(to: T.self, capacity: numberOfElements)
        for i in 0 ..< numberOfElements {
            bufferArray[i] = elementProcessor(i)
        }
    }
    
    static func populateGrid(buffer: UnsafeMutableRawPointer,
                             gridSize: MFGridSize,
                             elementProcessor: @escaping MFDataGridProcessorClosure<T>) {
        
        let bufferArray = buffer.bindMemory(to: T.self, capacity: gridSize.numberOfCells)
        
        gridSize.scanner().cellScan { scanner in
            if let data = elementProcessor(scanner, nil) {
                bufferArray[scanner.cell.index] = data
            }
        }
    }
    
    static func populateGeoGrid(buffer: UnsafeMutableRawPointer,
                                      gridSize: MFGridSize,
                                      cellSize: CGSize,
                                elementProcessor: @escaping MFDataGridProcessorClosure<T>) {
        let bufferArray = buffer.bindMemory(to: T.self, capacity: gridSize.numberOfCells)
        gridSize.scanner().cellScan { scanner in
            if let data = elementProcessor(scanner, nil) {
                bufferArray[scanner.cell.index] = data
            }
        }
    }
    
    /// Creates a data buffer by processing cell index,
    /// and location in grid
    
    public init(gridSize: MFGridSize, elementProcessor: @escaping MFDataGridProcessorClosure<T>) throws {
        self.numberOfElements = gridSize.numberOfCells
        
        let newBuffer: UnsafeMutableRawPointer = try allocateBuffer()
        
        MFSCNElementDataBuffer.populateGrid(buffer: newBuffer,
                                       gridSize: gridSize,
                                       elementProcessor: elementProcessor)
    }
    
    /// Creates a data buffer by processing cell index,
    /// location in grid, fractional location and location in frame
    
    public init(gridSize: MFGridSize,
                cellSize: CGSize,
                elementProcessor: @escaping MFDataGridProcessorClosure<T>) throws {
        self.numberOfElements = gridSize.numberOfCells
        
        let newBuffer: UnsafeMutableRawPointer = try allocateBuffer()
        
        MFSCNElementDataBuffer.populateGeoGrid(buffer: newBuffer,
                                                gridSize: gridSize,
                                                cellSize: cellSize,
                                                elementProcessor: elementProcessor)
    }
    
    // MARK: - Private Functions
    
    /// Allocate memory if possible, throws an error if not
    private func allocateBuffer() throws -> UnsafeMutableRawPointer {
        
        guard let newBuffer = malloc(neededCapacity) else {
            throw(Errors.memoryError)
        }
        
        self.allocatedCapacity = neededCapacity
        self.buffer = newBuffer
        
        return newBuffer
    }
}
