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
        
        /// The height compute function block. If set, it will compute a height map picture and hold it in the computedTextureBitmap property.
        
        var heightComputeBlock: MFSCNHeightComputeBlock?
        
        /// Height map image is an optionnal grayscale height map
        /// Each (x,y) pixel gray value will be added to the computed height.
        ///
        /// Computed height is returned by the computeHeightBlock closure, or is 0.0 is block is not set
        /// A grid mesh without heightCOmputeBlock and heightMapImage will be flat.
        
        public var heightMapImage: PlatformImage? { didSet {
            heightMapBitmap = try? heightMapImage?.bitmap()
        }}
        
        public var heightMapBitmap: CGContext?
        
        /// This bitmap is readable only.
        /// It is computed by mixing the heights from the hightMapBitmap and the height computation block
        public private(set) var computedHeightMapBitmap: CGContext?
        
        // MARK: - Initializers
        
        /// Init from CGContext and elevation infos
        public init(with bitmap: CGContext? = nil,
                    height: Double = 1,
                    textureScale: CGSize = CGSize(width: 1, height: 1),
                    heightComputeBlock: MFSCNHeightComputeBlock? = nil) {
            self.heightMapBitmap = bitmap
            self.height = height
            self.textureScale = textureScale
            self.heightComputeBlock = heightComputeBlock
        }
        
        /// Init from image ( UIImage or NSImage) and elevation infos
        public init(with image: PlatformImage,
                    height: Double = 1,
                    textureScale: CGSize = CGSize(width: 1, height: 1),
                    heightComputeBlock: MFSCNHeightComputeBlock? = nil) throws {
            self.init(with: try image.bitmap(),
            height: height,
            textureScale: textureScale,
            heightComputeBlock: heightComputeBlock)
            self.heightMapImage = image
        }
    }
}
