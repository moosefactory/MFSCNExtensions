/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSceneKitUtils - TerrainMesh                    */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/

import Foundation
import CoreGraphics
// For platform color
import MFFoundation

public extension MFSCNTerrainMesh {
    
    /// TextureInfo contains basic texture mapping information.
    ///
    /// TextureInfo object can be nil, in which case the user is responsible
    /// of applying the material later.
    
    public struct TextureInfo {
        
        public init(textureScale: CGSize = .one,
                    textureBaseName: String?,
                    color: PlatformColor? = nil) {
            self.textureScale = textureScale
            self.textureBaseName = textureBaseName
            self.color = color
        }
        
        public init(textureScale: CGSize = .one,
                    textureBitmap: CGContext?,
                    color: PlatformColor? = nil) {
            self.textureScale = textureScale
            self.textureBitmap = textureBitmap
            self.color = color
        }
        
        var textureScale: CGSize = .one
        var textureBaseName: String?
        var textureBitmap: CGContext?
        
        /// An optional diffuse color to apply over the texture
        var color: PlatformColor?
        
        /// An optional diffuse color computation block
        /// If set, it will fill a texture with squares of different colors
        var colorCompute: MFSKHeightComputeBlock?
        
    }
    
}
