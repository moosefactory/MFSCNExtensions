//   /\/\__/\/\      MFSCNExtensions
//   \/\/..\/\/      Swift Framework - v2.0
//      (oo)
//  MooseFactory     ©2007-2025 - Moose
//    Software
//  ------------------------------------------
//  􀈿 MFSCNGridMesh.swift
//  􀐚 MFSCNExtensions
//  􀓣 Created by Tristan Leblanc on 30/12/2024.

import SceneKit
import MFFoundation
import MFGridUtils

public extension PlatformColor {
    
    /// RGBA To SCNVector4
    var asSCNVector4: SCNVector4 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SCNVector4(x: SCNFloat(r), y: SCNFloat(g), z: SCNFloat(b), w: SCNFloat(a))
    }
    
    /// RGB3 To SCNVector3
    var asSCNVector3: SCNVector3 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SCNVector3(x: SCNFloat(r), y: SCNFloat(g), z: SCNFloat(b))
    }
}

/// TerrainMeshGeometryBuilder is responsible of holding MeshBuffer datas.

public class MFSCNGridMeshGeometry {
    
    public enum Errors: String, Error {
        case undeterminatedGridSize
        case cantBuildMeshBuffers
    }
    
    /// The mesh information.
    /// - geometry : The grid size and the height modifiers ( heightmap and compute block )
    
    public var meshInfo: MFSCNMeshInfo
        
    // public var heightMapBitmap: CGContext? = nil
    
    var material: SCNMaterial?
    
    /// Initialize the mesh builder
    ///
    /// - Parameters:
    /// - size : The terrain resolution
    /// - color: the color to use for material
    /// - textureImageName: the texture image name
    
    public init(meshInfo: MFSCNMeshInfo) throws {
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
        
        
        // Colors
        
        var colorSource: SCNGeometrySource? = nil

        if let colors = mesh.colors {
            colorSource = SCNGeometrySource(data: colors.data,
                                                semantic: .color,
                                                vectorCount: colors.numberOfElements,
                                                usesFloatComponents: true,
                                                componentsPerVector: 4,
                                                bytesPerComponent: MemoryLayout<SCNFloat>.size,
                                                dataOffset: 0,
                                                dataStride: MemoryLayout<SCNVector4>.stride)
        }
        
        let sources = [vertices, normals, textureCoordinates, colorSource].compactMap { $0 }
        
        let geometry = SCNGeometry(sources: sources,
                                   elements: [geometryElement])
        return geometry;
    }

    /// Default material provider, from info.
    /// Subclass to create complex materials and address various textures channels
    
    public func makeMaterials() -> [SCNMaterial] {
        var materials = [SCNMaterial]()
        let info = meshInfo.mappingInfo
        
        if let color = info?.color {
            let material = SCNMaterial()
            material.diffuse.contents = color
            materials.append( material )
        }
        
        if let baseName = info?.textureBaseName {
            let material = SCNMaterial()
            material.loadWithTextureAccessor(MFSCNTextureAccessor(baseName: baseName))
            materials.append( material )
        }

        if let computeTextureImage = info?.computedTextureBitmap {
            let material = SCNMaterial()
            material.diffuse.contents = computeTextureImage
            materials.append( material )
        }
        
        materials.forEach { material in
            material.isLitPerPixel = true
            material.lightingModel = .physicallyBased
        }
        return materials
    }
    
    public func makeMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        let info = meshInfo.mappingInfo
        
        if let computeTextureImage = info?.textureBitmap {
            material.diffuse.contents = computeTextureImage
        }
        else if let baseName = info?.textureBaseName {
            material.loadWithTextureAccessor(MFSCNTextureAccessor(baseName: baseName))
        }
        material.isLitPerPixel = true
        material.lightingModel = .physicallyBased
        return material
    }
}
