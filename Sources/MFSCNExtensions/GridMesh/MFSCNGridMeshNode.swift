//
//  MFSCNGridMeshNode.swift
//  MFGridMeshLab
//
//  Created by Tristan Leblanc on 19/01/2025.
//

import SceneKit
import MFGridUtils

public class MFSCNGridMeshNode: SCNNode {
    
    public var grid: MFGrid = MFGrid(gridSize: MFGridSize.init(size: 20))
    
    public init(grid: MFGrid) {
        self.grid = grid
        super.init()
        buildMesh()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildMesh()
    }
    
    public lazy var meshNode = MFSCNGridMeshNode.makeMeshNode(with: grid)
    
    static func makeMeshNode(with grid: MFGrid) -> SCNNode {
        let gridInfo = MFSCNMeshGridInfo(gridSize: grid.gridSize,
                                         cellSize: grid.cellSize,
                                         elevation: 0)
        do {
            let meshInfo = MFSCNMeshInfo(gridInfo: gridInfo)
            let mesh = try MFSCNGridMesh(meshInfo: meshInfo)
            let geometry = try mesh.makeGeometry()
            geometry.materials.first?.fillMode = .lines
            return SCNNode(geometry: geometry)
        }
        catch {
            return SCNNode()
        }
    }
    
    func buildMesh() {
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
