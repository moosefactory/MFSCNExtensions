//
//  MFSCNGridMeshNode.swift
//  MFGridMeshLab
//
//  Created by Tristan Leblanc on 19/01/2025.
//

import SceneKit
import MFGridUtils

public class MFSCNGridMeshNode: SCNNode {
    
    public var meshNode: SCNNode!

    public var grid: MFGrid = MFGrid(gridSize: MFGridSize.init(size: 20))
    
    /// The most simple mesh creation function.
    ///
    public init(grid: MFGrid,
                heightComputeBlock: MFSCNHeightComputeBlock? = nil,
                colorComputeBlock: MFSCNColorComputeBlock? = nil) {
        self.grid = grid
        super.init()
        buildMesh(heightComputeBlock: heightComputeBlock,
                  colorComputeBlock: colorComputeBlock)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildMesh()
    }
    
    /// Creates the mesh geometry node
    ///
    /// The geometry noe is used to correctly center and rotate the mesh.
    
    static func makeMeshNode(with grid: MFGrid,
                             heightComputeBlock: MFSCNHeightComputeBlock? = nil,
                             colorComputeBlock: MFSCNColorComputeBlock? = nil) -> SCNNode {
        let gridInfo = MFSCNMeshGridInfo(gridSize: grid.gridSize,
                                         cellSize: grid.cellSize,
                                         elevation: 0)
        do {
            
            let heightMapInfo = MFSCNMeshHeightMapInfo(heightComputeBlock: heightComputeBlock)
            
            let textureInfo = MFSCNMeshTextureInfo(colorComputeBlock: colorComputeBlock)
            
            let meshInfo = MFSCNMeshInfo(gridInfo: gridInfo,
                                         heightMapInfo: heightMapInfo,
                                         mappingInfo: textureInfo)
            let mesh = try MFSCNGridMeshGeometry(meshInfo: meshInfo)
            let geometry = try mesh.makeGeometry()

            return SCNNode(geometry: geometry)
        }
        catch {
            return SCNNode()
        }
    }
    
    func buildMesh(heightComputeBlock: MFSCNHeightComputeBlock? = nil,
                   colorComputeBlock: MFSCNColorComputeBlock? = nil) {
        let meshNode = MFSCNGridMeshNode.makeMeshNode(with: grid,
                                                      heightComputeBlock: heightComputeBlock,
                                                      colorComputeBlock: colorComputeBlock)
        self.meshNode = meshNode
        addChildNode(meshNode)
        recenterMesh()
    }
    
    var yAxisUp: Bool = true
    
    func recenterMesh() {
        let center = meshNode.boundingSphere.center
        if yAxisUp {
            meshNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0)
            meshNode.position = SCNVector3(x: -center.x, y: -center.z, z: center.y)
        } else {
            meshNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
            meshNode.position = SCNVector3(x: -center.x, y: -center.y, z: -center.z)
        }
    }
}
