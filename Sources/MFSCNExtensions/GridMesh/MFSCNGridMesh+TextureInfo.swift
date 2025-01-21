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

public extension MFGridMesh {
    
    /// TextureInfo contains basic texture mapping information.
    ///
    /// TextureInfo object can be nil, in which case the user is responsible
    /// of applying the material later.
    
    struct TextureInfo {
        
        public init(textureScale: CGSize = .one,
                    textureBaseName: String? = nil,
                    color: PlatformColor? = nil,
                    colorComputeBlock: MFSCNColorComputeBlock? = nil) {
            self.textureScale = textureScale
            self.textureBaseName = textureBaseName
            self.color = color
            self.colorComputeBlock = colorComputeBlock
        }
        
        public init(textureScale: CGSize = .one,
                    textureBitmap: CGContext?,
                    color: PlatformColor? = nil) {
            self.textureScale = textureScale
            self.computedTextureBitmap = textureBitmap
            self.color = color
        }
        
        var textureScale: CGSize = .one
        
        var textureBaseName: String?

        var textureBitmap: CGContext?
        
        private(set) var computedTextureBitmap: CGContext?

        /// An optional diffuse color to apply over the texture
        var color: PlatformColor?
        
        /// An optional diffuse color computation block
        var colorComputeBlock: MFSCNColorComputeBlock?

    }
}
