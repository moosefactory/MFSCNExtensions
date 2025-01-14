/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSCTerrainMesh                                  */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  TerrainMeshGeometryBuilder.swift
//  Created by Tristan Leblanc on 30/12/2024.

import SceneKit
import MFFoundation
import MFGridUtils

/// TerrainMeshGeometryBuilder is responsible of
/// - hold a MeshBuffer object, allocating the underlying buffers used by
///
public class MFSCNTerrainMeshGeometryBuilder {
    
    public enum Errors: String, Error {
        case undeterminatedGridSize
        case cantBuildMeshBuffers
    }
    
    public var meshInfo: MFSKMeshInfo
    
    public var textureImage: PlatformImage? = nil
    
    public var heightMapImage: PlatformImage? = nil {
        didSet {
            if let bitmap = try? heightMapImage?.bitmap() {
                mesh?.updateHeights(with: bitmap)
            }
        }
    }
    
    public var heightMapBitmap: CGContext? = nil {
        didSet {
            guard let heightMapBitmap = heightMapBitmap else { return }
            mesh?.updateHeights(with: heightMapBitmap)
        }
    }
    
    var material: SCNMaterial?
    
    /// Initialize the mesh builder
    ///
    /// - Parameters:
    /// - size : The terrain resolution
    /// - color: the color to use for material
    /// - textureImageName: the texture image name
    
    public init(meshInfo: MFSKMeshInfo) throws {
        self.meshInfo = meshInfo
    }
    
    var mesh: MFSCNMeshBuffer?
    
    /// Makes a new geometry
    
    public func makeGeometry() throws -> SCNGeometry
    {
        let mesh = try MFSCNMeshBuffer(meshInfo: meshInfo)

        let textureCoordinates = SCNGeometrySource(
            data: mesh.textureCoordinates!.data,
            semantic: .texcoord,
            vectorCount: mesh.textureCoordinates!.numberOfElements,
            usesFloatComponents: true,
            componentsPerVector: 2,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Float>.size * 2
        )

        let vertices = SCNGeometrySource(vertices: mesh.verticesArray)
        
        let normals = SCNGeometrySource(normals: mesh.normalsArray)
        
        let geometryElement = SCNGeometryElement(
            data: mesh.indices!.data,
            primitiveType: .triangles,
            primitiveCount: meshInfo.gridInfo.numberOfTriangles,
            bytesPerIndex: MemoryLayout<CInt>.size
        )
        
        let geometry = SCNGeometry(sources: [vertices,normals,textureCoordinates],
                                   elements: [geometryElement])
        return geometry;
    }
    
    public func makeMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        var info = meshInfo.mappingInfo
        
        if let computeTextureImage = info?.textureBitmap {
            //let bitmap = try! ?.bitmap()

            material.transparent.contents = computeTextureImage.makeImage()
            material.diffuse.contents = PlatformImage(named: "Icon_512")

        }
        else
        if let baseName = info?.textureBaseName {
            material.loadWithTextureAccessor(MFSCNTextureAccessor(baseName: baseName))
        }
        material.isLitPerPixel = true
        material.lightingModel = .physicallyBased
        return material
    }
}
