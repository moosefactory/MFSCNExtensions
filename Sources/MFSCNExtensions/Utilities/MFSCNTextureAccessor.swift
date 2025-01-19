/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSceneKitUtils                                  */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  MFSCNTextureAccessor.swift
//  Created by Tristan Leblanc on 30/12/2024.

import Foundation
import MFFoundation
import SceneKit

// MARK: - Texture Accessor

/// Convenience object to load textures
///
/// It uses the given name as a prefix to access channels files
///
/// MFSCNTextureAccessor("Sand").image(for: .diffuse) will return the image named "Sand_Diffuse"
///
public struct MFSCNTextureAccessor {
    
    /// The name that will be used to load the texture
    public let baseName: String
    
    /// The base image, which should be returned by loading the file named basename without extension

    public var base: PlatformImage? { PlatformImage(named: "\(baseName)") }

    public init(baseName: String) {
        self.baseName = baseName
    }
    
    public func image(for type: MapType) -> PlatformImage? {
        PlatformImage(named: "\(baseName)_\(type.rawValue)")
    }
    
    public enum MapType: String {
        case baseColor = "BaseColor"
        case diffuse = "Diffuse"
        case transparent = "Transparent"
        case ambientOcclusion = "AmbientOcclusion"
        case glossiness = "Glossiness"
        case height = "Height"
        case displacement = "Displacement"
        case metalic = "Metalic"
        case normal = "Normal"
        case roughness = "Roughness"
        case specular = "Specular"
        case specularLevel = "SpecularLevel"
    }
}

// MARK: - SCNMaterial

public extension SCNMaterial {
    
    func loadWithTextureAccessor(_ accessor: MFSCNTextureAccessor) {
        self.diffuse.contents = accessor.image(for: .diffuse)
        ?? accessor.base
        self.ambientOcclusion.contents = accessor.image(for: .ambientOcclusion)
        self.transparent.contents = accessor.image(for: .transparent)
        self.metalness.contents = accessor.image(for: .metalic)
        self.displacement.contents = accessor.image(for: .displacement)
        self.metalness.contents = accessor.image(for: .metalic)
        self.displacement.contents = accessor.image(for: .displacement)
        self.normal.contents = accessor.image(for: .normal)

        self.roughness.contents = accessor.image(for: .roughness)
        self.specular.contents = accessor.image(for: .specular)

        lightingModel = .physicallyBased
        isDoubleSided = true
    }
}
