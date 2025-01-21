/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSCTerrainMesh                                  */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  MFSKTerrainNode.swift
//  Created by Tristan Leblanc on 30/12/2024.

import Foundation
import SceneKit
import MFGridUtils
import MFFoundation

/// Responsible of allocating buffers to hold the mesh data

public class MFSCNMeshBuffer {
    
    /// The errors that can be thrown by the MeshBuffer
    public enum Errors: String, Error {
        case cantFindImageBitmapByName
        
        case notEnoughMemoryToAllocateVerticesBuffer
        case notEnoughMemoryToAllocateIndicesBuffer
        case notEnoughMemoryToAllocateTexturesBuffer
        case notEnoughMemoryToAllocateNormalsBuffer
    }
    
    public struct TexturePoint {
        let x: CFloat
        let y: CFloat
    }
    
    /// TriangleIndice structure, used to build vertexes indices
    public struct TriangleIndice {
        let i0:CInt
        let i1:CInt
        let i2:CInt
    }
    
    /// Data per side, used to build vertex indices
    public struct SideTrianglesIndice {
        let t1: TriangleIndice
        let t2: TriangleIndice
    }
    
    // MARK: Buffers
    
    public private(set) var vertices: MFSCNElementDataBuffer<SCNVector3>?
    
    public private(set) var normals: MFSCNElementDataBuffer<SCNVector3>?
    
    public private(set) var indices: MFSCNElementDataBuffer<SideTrianglesIndice>?
    
    // Set if textureInfo is set
    public private(set) var textureCoordinates: MFSCNElementDataBuffer<TexturePoint>?
    
    public private(set) var colors: MFSCNElementDataBuffer<SCNVector4>?
    
    // Swift Array accessor
    
    var verticesArray: [SCNVector3] { vertices?.array ?? [] }
    
    var normalsArray: [SCNVector3] { normals?.array ?? [] }
    
    /// The resolution of the grid, in number of cells
    let meshInfo: MFSCNMeshInfo
    
    // Convenience accessors to the mesh info
    var gridInfo: MFSCNMeshGridInfo { meshInfo.gridInfo }
    
    // The grid size
    var squaresGridSize: MFGridSize { meshInfo.gridInfo.gridSize }
    
    // The vertices grid size
    var verticesGridSize: MFGridSize { meshInfo.gridInfo.verticesGridSize }
    
    /// Returns the number of triangles
    var numberOfTriangles: Int { meshInfo.gridInfo.numberOfTriangles}
    
    /// Inits a mesh buffer using the passed grid size
    ///
    /// - parameters:
    /// - gridSize: The mesh resolution on X and Y axes
    /// - heightMapImageName: An optional image name
    /// If set, the processor will use the height map to set the altitute of the vertex ( Z axis )
    
    // MARK: - Init Mesh
    
    init(meshInfo: MFSCNMeshInfo) throws {
        self.meshInfo = meshInfo
        try rebuildAllBuffers()
    }
    
    func rebuildAllBuffers() throws {
        let meshInfo = meshInfo
        
        // If the height compute block is not set, we provide a simple block that returns
        // a flat plane
        let heightFromHeightMap: MFSCNHeightComputeBlock = meshInfo.heightMapInfo?.heightComputeBlock
        ?? { _, _, _ in return 0.0 }
        
        
        vertices = try makeVerticesArray() { value, gridLoc, fracLoc in
            let double = value / Double(UInt8.max)
            return heightFromHeightMap(double, gridLoc, fracLoc)
        }
        
        normals = try makeNormalsArray()
        indices = try makeIndices()
        colors = try makeColorBuffer()
        
        textureCoordinates = try makeTexturesBuffer()
        
    }
    
    var updating: Bool = false
    
    /// This function recomputes the buffers
    
//    func updateBuffers() throws {
//        
//        if updating {
//            return
//        }
//        
//        updating = true
//        let meshInfo = meshInfo
//        
//        // If the height compute block is not set, we provide a simple block that returns
//        // a flat plane
//        let heightFromHeightMap: MFSCNHeightComputeBlock =
//        meshInfo.heightMapInfo?.heightComputeBlock
//        ?? { _, _, _ in return 0.0 }
//        
//        self.vertices = try makeVerticesArray() { value, gridLoc, fracLoc in
//            let double = value / Double(UInt8.max)
//            return heightFromHeightMap(double, gridLoc, fracLoc)
//        }
//        
//        normals = try makeNormalsArray()
//        indices = try makeIndices()
//        textureCoordinates = try makeTexturesBuffer()
//        colors = try makeColorBuffer()
//
//        updating = false
//    }
    
    /// Allocates the normals buffer
    
    func makeNormalsArray() throws -> MFSCNElementDataBuffer<SCNVector3> {
        do {
            return try MFSCNElementDataBuffer<SCNVector3>(gridSize: verticesGridSize) { index, location in
                SCNVector3(x: 0, y: 0, z: 1)
            }
        }
        catch {
            throw(Errors.notEnoughMemoryToAllocateNormalsBuffer)
        }
    }
    
    /// Allocates the indices buffer
    
    private func makeIndices() throws -> MFSCNElementDataBuffer<SideTrianglesIndice> {
        do {
            return try MFSCNElementDataBuffer<SideTrianglesIndice>(gridSize: squaresGridSize) {
                scanner, data in
                
                let squareLoc: (h: CInt, v: CInt) = scanner.cell.gridLocation.asCInts
                let verticesGridSize = self.verticesGridSize.asCInt
                
                let verticesPerRow: CInt = verticesGridSize.columns
                let verticesPerCol: CInt = verticesGridSize.rows
                
                let topRightIndex: CInt = (squareLoc.v + 1) * verticesPerRow + (squareLoc.h + 1 )
                let topLeftIndex: CInt = topRightIndex - 1;
                let bottomLeftIndex: CInt = topRightIndex - verticesPerCol - 1
                let bottomRightIndex: CInt = topRightIndex - verticesPerCol
                
                return SideTrianglesIndice(t1: TriangleIndice(i0: topRightIndex,
                                                              i1: topLeftIndex,
                                                              i2: bottomLeftIndex),
                                           t2: TriangleIndice(i0: topRightIndex,
                                                              i1: bottomLeftIndex,
                                                              i2: bottomRightIndex))
            }
        }
        catch {
            throw(Errors.notEnoughMemoryToAllocateIndicesBuffer)
        }
    }
    
    /// Allocates the vertices buffer
    
    func makeVerticesArray(heightFromHeightMap: @escaping MFSCNHeightComputeBlock) throws -> MFSCNElementDataBuffer<SCNVector3> {
        do {
            
            let cellSize = meshInfo.gridInfo.cellSize
            
            return try MFSCNElementDataBuffer<SCNVector3>(gridSize: verticesGridSize) { scanner, data in
                
                var height: CGFloat = 0
                
                // TODO: Optimize to use cell computed values
                
                let fractionalLoc = scanner.cell.gridLocation.fractionalLocation(for: self.verticesGridSize)
                
                if let info = self.meshInfo.heightMapInfo, let heightMapBitmap = info.heightMapBitmap {
                    if let comps = heightMapBitmap.colorComponents(fractionalX: fractionalLoc.x,
                                                                   fractionalY: fractionalLoc.y) {
                        let value = 1 - CGFloat( comps.r )
                        height = heightFromHeightMap(value, scanner.cell.gridLocation, fractionalLoc)
                    }
                } else {
                    height = heightFromHeightMap(0, scanner.cell.gridLocation, fractionalLoc)
                }
                
                
                let cgLocation = scanner.cell.gridLocation.asCGFloats
                return SCNVector3(x: SCNFloat(cgLocation.h * cellSize.width),
                                  y: SCNFloat(cgLocation.v * cellSize.height),
                                  z: SCNFloat(height))
            }
        }
        catch {
            throw(Errors.notEnoughMemoryToAllocateVerticesBuffer)
        }
    }
    
    /// Allocates the texture coordinates buffer
    
    func makeTexturesBuffer() throws -> MFSCNElementDataBuffer<TexturePoint> {
        let textureScale: CGSize = meshInfo.mappingInfo?.textureScale ?? CGSize.one
        let cellSize = meshInfo.gridInfo.cellSize
        
        do {
            
            return try MFSCNElementDataBuffer<TexturePoint>(gridSize: verticesGridSize, cellSize: cellSize) { scanner, data in
                let f = scanner.cell.fractionalLocation
                // Not sure why I have to do this
                // It looks like if we go to 1.0, SceneKit does a cubic mapping or something.
                // TODO: investigate further
                let frac = 0.999
                let texLocX = (f.x * frac) * textureScale.width
                let texLocY = (1.0 - f.y) * frac * textureScale.height
                var mx: Double = 1
                var my: Double = 1
                let texLocXMod = modf(texLocX, &mx)
                let texLocYMod = modf(texLocY, &my)
                let point = TexturePoint(
                    x: CFloat(texLocXMod),
                    y: CFloat(texLocYMod)
                )
                return point
            }
        }
        catch {
            throw(Errors.cantFindImageBitmapByName)
        }
    }
    
    /// Builds the color buffer

    func makeColorBuffer() throws -> MFSCNElementDataBuffer<SCNVector4>? {
        guard let colorBlock = meshInfo.mappingInfo?.colorComputeBlock else { return nil }
        let vertices = verticesArray
        return try MFSCNElementDataBuffer<SCNVector4>(gridSize: verticesGridSize) { scanner, data in
            colorBlock(0, scanner.cell.gridLocation, .zero, vertices[scanner.cell.index])
        }
    }
    
}


