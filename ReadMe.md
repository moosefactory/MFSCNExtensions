# MFSCNExtensions

![MFSCNExtensions logo](Icon_128.png)

Some cool extensions for **SceneKit** frameworks

## Utils

### MFSCNCameraManager

Camera switch helper. 

### MFSCNTextureAccessor

Texture images loader

### MFSCNTextureAccessor

Texture images loader

## MFGridMesh

### Usage:

To quickly try the mesh object, create a new multiplatform SceneKit based game project,
you know, the one with the forever rotating plane.

Then do as following to add a simple quare mesh node:

```

// Add a mesh node ( must import MFSCNExtension and MFGridUtils )

// 1 - Create a grid object
let grid = MFGrid(gridSize: 40, cellSize: 2)

// 2 - Create a mesh using the grid
let meshNode = MFSCNGridMeshNode(grid: grid)

// 3 - Slightly move the mesh down so wee see it in perspective
meshNode.position.y = -3.0

sceneRenderer.scene = scene

```

Build and run.

![MeshLabScreenshot Image](MeshLabScreenshot.jpg)

### MFSCNElementDataBuffer

Buffer helper.

### MFSCNMeshBuffer

Mesh Buffer

### MFSCNTerrainMesh

The library main file

### MFSCNTerrainMeshGeometryBuilder

Builds SceneKit nodes using a MFSCNMeshBuffer

--

*©2024 Moose Factory Software*
