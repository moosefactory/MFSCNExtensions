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
///
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
    
    public private(set) var colors: MFSCNElementDataBuffer<PlatformColor>?
    
    // Swift Array accessor
    
    var verticesArray: [SCNVector3] { vertices?.array ?? [] }
    var normalsArray: [SCNVector3] { normals?.array ?? [] }
    
    /// The resolution of the grid, in number of cells
    let meshInfo: MFSKMeshInfo
    
    // Convenience accessors to the mesh info
    var gridInfo: MFSKMeshGridInfo { meshInfo.gridInfo }
    
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
    
    init(meshInfo: MFSKMeshInfo) throws {
        
        self.meshInfo = meshInfo
        
        var heightClosure: MFSKHeightComputeBlock?
        var bitmapClosure: MFSKGridComputeBlock?
        
        let height: CGFloat = meshInfo.heightMapInfo?.height ?? 1.0
        
        try rebuildAllBuffers()
    }
    
    func rebuildAllBuffers() throws {
        let meshInfo = meshInfo
        
        let heightFromHeightMap: MFSKHeightComputeBlock = meshInfo.heightMapInfo?.heightCompute
        ?? {
            value, _, _ in
            return value * (meshInfo.heightMapInfo?.height ?? 1.0)
        }

        vertices = try makeVerticesArray() { value, gridLoc, fracLoc in
            let double = value / Double(UInt8.max)
            return heightFromHeightMap(double, gridLoc, fracLoc)
        }
        
        normals = try makeNormalsArray()
        indices = try makeIndices()
        textureCoordinates = try makeTexturesBuffer()
    }
    
    var updating: Bool = false
    
    func updateBuffers() throws {
        if updating {
            return
        }
        updating = true
        let meshInfo = meshInfo
        
        let heightFromHeightMap: MFSKHeightComputeBlock =
        meshInfo.heightMapInfo?.heightCompute ?? {
            value, _, _ in
            return value * (meshInfo.heightMapInfo?.height ?? 1.0)
        }

        self.vertices = try makeVerticesArray() { value, gridLoc, fracLoc in
            let double = value / Double(UInt8.max)
            return heightFromHeightMap(double, gridLoc, fracLoc)
        }
        
        normals = try makeNormalsArray()
        indices = try makeIndices()
        textureCoordinates = try makeTexturesBuffer()
        
        updating = false
    }
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
                index, gridLocation in
                
                let squareLoc: (h: CInt, v: CInt) = gridLocation.asCInts
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

    
    func updateHeights(with HeightMap: CGContext) {
    }
    
    func makeVerticesArray(heightFromHeightMap: @escaping MFSKHeightComputeBlock) throws -> MFSCNElementDataBuffer<SCNVector3> {
        do {
            let cellSize = meshInfo.gridInfo.cellSize
            return try MFSCNElementDataBuffer<SCNVector3>(gridSize: verticesGridSize) { index, location in
                
                var height: CGFloat = 0
                let fractionalLoc = location.fractionalLocation(for: self.verticesGridSize)

                if let info = self.meshInfo.heightMapInfo, let heightMapBitmap = info.heightMapBitmap {
                    if let comps = heightMapBitmap.colorComponents(fractionalX: fractionalLoc.x,
                                                                   fractionalY: fractionalLoc.y) {
                        let value = 1 - CGFloat( comps.r )
                        height = heightFromHeightMap(value, location, fractionalLoc)
                    }
                }
                else {
                    height = heightFromHeightMap(0, location, fractionalLoc)
                }
                
                
                let cgLocation = location.asCGFloats
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
        let gridSize = meshInfo.gridInfo.gridSize
        let gridSizef = gridSize.asCGFloat

        do {
            
            return try MFSCNElementDataBuffer<TexturePoint>(gridSize: verticesGridSize, cellSize: cellSize) { index, gridLocation in
                let cellFractionalLocation = gridLocation.fractionalLocation(for: gridSize)
                let frac = 0.999999
                let texLocX = cellFractionalLocation.x * frac// * textureScale.width * gridSizef.columns
                let texLocY = (1.0 - cellFractionalLocation.y) * frac// * textureScale.height * gridSizef.rows
                var mx: Double = 1
                var my: Double = 1
                let point = TexturePoint(
                    x: CFloat(modf(texLocX, &mx)) ,
                    y: CFloat(modf(texLocY, &my))
                )
                
                return point
            }
        }
        catch {
            throw(Errors.cantFindImageBitmapByName)
        }
    }
    //        colors = ElementDataBuffer<SCNColor>(gridSize: verticesGridSize) { index, location in
    //            return SCNColor.clear
    //        }
}


