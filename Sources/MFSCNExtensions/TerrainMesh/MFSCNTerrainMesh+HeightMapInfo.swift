/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSceneKitUtils - TerrainMesh                    */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  HeightMapInfo.swift
//  MFSCNExtensions
//
//  Created by Tristan Leblanc on 06/01/2025.
//

import Foundation
import CoreGraphics

import MFFoundation

public extension MFSCNTerrainMesh {
    
    /// HeightMapInfo contains elevation mapping information.
    /// ( The Y coordinate)
    
    public struct HeightMapInfo {
        
        public var height = 1.0
        public var textureScale = CGSize()
        
        var heightCompute: MFSKHeightComputeBlock?
        
        public var heightMapImage: PlatformImage? { didSet {
            heightMapBitmap = try? heightMapImage?.bitmap()
        }}
        
        public var heightMapBitmap: CGContext?
        
        // MARK: - Initializers
        
        /// Init from CGContext and elevation infos
        public init(with bitmap: CGContext? = nil,
                    height: Double = 1,
                    textureScale: CGSize = CGSize(width: 1, height: 1),
                    heightComputeBlock: MFSKHeightComputeBlock? = nil) {
            self.heightMapBitmap = bitmap
            self.height = height
            self.textureScale = textureScale
            self.heightCompute = heightComputeBlock
        }
        
        /// Init from image ( UIImage or NSImage) and elevation infos
        public init(with image: PlatformImage,
                    height: Double = 1,
                    textureScale: CGSize = CGSize(width: 1, height: 1),
                    heightComputeBlock: MFSKHeightComputeBlock? = nil) throws {
            self.init(with: try image.bitmap(),
                      height: height,
                      textureScale: textureScale,
                      heightComputeBlock: heightComputeBlock)
            self.heightMapImage = image
        }
    }
}
