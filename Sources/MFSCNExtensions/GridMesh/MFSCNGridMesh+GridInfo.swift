//   /\/\__/\/\      MFSCNExtensions
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2025 - Moose
//    Software
//  ------------------------------------------
//  􀈿 MFSCNGridMesh.swift
//  􀐚 MFSCNExtensions
//  􀓣 Created by Tristan Leblanc on 30/12/2024.

//  GridInfo.swift
//  MFSCNExtensions
//
//  Created by Tristan Leblanc on 06/01/2025.
//

import Foundation
import MFFoundation
import MFGridUtils

public extension MFGridMesh {
    
    /// The structure to pass to create a minimal mesh,
    /// resulting in a flat grid.
    ///
    /// MeshInfo contains the geometric definition of the grid.
    ///
    /// It exposes some convenience accessors to work vertices
    
    struct GridInfo {
        
        public var gridSize = MFGridSize(size: 100)
        public var cellSize = CGSize.one
        
        public var elevation: CGFloat = 0.0
        
        // MARK: - Initialisation
        
        public init(gridSize: MFGridSize,
                    cellSize: CGSize = CGSize.one,
                    elevation: CGFloat = 0.0) {
            self.gridSize = gridSize
            self.cellSize = cellSize
            self.elevation = elevation
        }
        
        // MARK: - Convenience accessors
        
        // We keep a convenient access to th enumber of triangles in the mesh, which is two times the number of squares
        var numberOfTriangles: Int {gridSize.numberOfCells * 2 }
        var numberOfSquares: Int {gridSize.numberOfCells  }
        var numberOfVertices: Int {verticesGridSize.numberOfCells }
        
        var verticesGridSize: MFGridSize {
            gridSize.grownBy(1)
        }
    }
    
}
