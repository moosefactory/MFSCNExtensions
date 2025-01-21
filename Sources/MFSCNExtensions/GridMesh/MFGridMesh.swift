/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSceneKitUtils - TerrainMesh                    */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  TerrainMesh.swift
//  Created by Tristan Leblanc on 30/12/2024.

import Foundation
import CoreGraphics
import SceneKit

import MFFoundation
import MFGridUtils

// MARK: - MFSCNTerrainMesh Library -

// MARK: Publicly exposed types

public typealias MFSCNMeshInfo = MFGridMesh.MeshInfo
public typealias MFSCNMeshGridInfo = MFGridMesh.GridInfo
public typealias MFSCNMeshHeightMapInfo = MFGridMesh.HeightMapInfo
public typealias MFSCNMeshTextureInfo = MFGridMesh.TextureInfo
public typealias MFSCNHeightComputeBlock = (Double, MFGridLocation, CGPoint) -> Double

public typealias MFSCNColorComputeBlock = (Double, MFGridLocation, CGPoint, SCNVector3) -> SCNVector4
//public typealias MFSKGridComputeBlock = (Int, MFGridLocation, CGPoint, CGPoint) -> Double

/// MFSCNTerrainMesh Library Scope

public struct MFGridMesh {
    
    /// The full structure to define geometry and texture
    public struct MeshInfo {
        public var gridInfo: GridInfo
        public var heightMapInfo: HeightMapInfo?
        public var mappingInfo: TextureInfo?
        
        var useTextureSizeIfPossible: Bool = false
        
        public init(gridInfo: MFGridMesh.GridInfo,
                    heightMapInfo: MFGridMesh.HeightMapInfo? = nil,
                    mappingInfo: MFGridMesh.TextureInfo? = nil,
                    useTextureSizeIfPossible: Bool = false) {
            self.gridInfo = gridInfo
            self.heightMapInfo = heightMapInfo
            self.mappingInfo = mappingInfo
            self.useTextureSizeIfPossible = useTextureSizeIfPossible
        }
    }
}
