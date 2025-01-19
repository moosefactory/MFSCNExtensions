/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MFSceneKitUtils                                  */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             MooseFactory SceneKit Extensions                 */
/*        (oo)                                                              */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
//  CameraManager.swift
//  Created by Tristan Leblanc on 29/12/2024.

import SceneKit

/// Manages a list of cameras in the scene
///
/// Call the next() function to sequentially access cameras
public class MFSCNCameraManager {
    
    public init(scene: SCNScene, sceneRenderer: any SCNSceneRenderer, cameraNames: [String]) {
        self.scene = scene
        self.sceneRenderer = sceneRenderer
        self.cameraNames = cameraNames
    }
    
    var scene: SCNScene
    var sceneRenderer: SCNSceneRenderer
    
    var cameraNames: [String]
    
    lazy var cameraNodes: [SCNNode] = {
        return cameraNames.compactMap {
            let node = self.scene.rootNode.childNode(withName: $0, recursively: true)
            return node
        }
    }()
    
    public func cameraNode(at index: Int) -> SCNNode {
        cameraNodes[ index % (cameraNodes.count) ]
    }
    

    public var camIndex: Int = 1 {
        didSet {
            let idx = camIndex % cameraNodes.count
            sceneRenderer.pointOfView = cameraNode(at: idx)
        }
    }
    
    public func nextCam() {
        camIndex += 1
    }
}
