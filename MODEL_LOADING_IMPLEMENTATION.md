# Model Loading Pipeline Implementation

This document describes the model loading system implemented for Spyro-Scope.

## Overview

The model loading system consists of several components that work together to load OBJ/MTL files and insert them into the Spyro game world with proper collision detection.

## Core Components

### 1. `Material.bf`
Represents material data from MTL files:
- Ambient, diffuse, and specular colors
- Texture map paths (diffuse, normal, specular)
- Alpha transparency
- OpenGL texture IDs for loaded textures

### 2. `ModelData.bf`
Container for loaded model information:
- Vertex positions, normals, texture coordinates
- Face indices
- Material assignments
- Bounding box calculations
- Automatic normal generation

### 3. `ModelLoader.bf`
Handles parsing of OBJ and MTL files:
- Supports vertices (v), normals (vn), texture coordinates (vt)
- Handles faces (f) with proper triangulation
- Loads associated MTL files automatically
- Robust error handling with Result types

### 4. `TextureCache.bf`
Manages texture loading and caching:
- Prevents duplicate texture loading
- Uses existing Texture class for OpenGL integration
- Simple cache management

### 5. `ModelInserter.bf`
Converts models to Spyro's coordinate system:
- Coordinate conversion with configurable scale factor
- Transformation support (position, rotation, scale)
- Generates collision triangles using Spyro's packed format
- Integration with existing collision system

## Integration Points

### TerrainCollision.bf
Added `AddTriangle()` method to insert collision triangles into the existing collision system.

### ViewerMenu.bf
Added UI controls:
- "Load Model" button - opens file dialog for OBJ selection
- "Clear Level" button - clears existing geometry

### ViewerState.bf
Added core functionality:
- `LoadModel()` - file dialog and model loading
- `ClearLevel()` - clears collision data
- `LoadModelFile()` - processes loaded models

## Usage

1. User clicks "Load Model" button
2. File dialog opens for OBJ file selection
3. System automatically loads associated MTL file
4. Model is positioned at current camera location
5. Textures are loaded and cached
6. Model is converted to Spyro coordinates
7. Collision triangles are generated and added
8. Visual feedback is provided via message feed

## Coordinate System

The system converts from standard 3D modeling coordinates to Spyro's fixed-point coordinate system:
- Default scale factor: 256.0
- Handles X, Y, Z axis transformations
- Maintains proper orientation

## Collision Generation

Models are converted to collision triangles using:
- Spyro's packed triangle format
- Automatic vertex ordering
- Integration with spatial grid system

## File Format Support

### OBJ Files
- Vertices (v)
- Normals (vn)
- Texture coordinates (vt)
- Faces (f) - triangles and quads
- Material usage (usemtl)

### MTL Files
- Material definitions (newmtl)
- Colors (Ka, Kd, Ks)
- Transparency (d, Tr)
- Texture maps (map_Kd, map_Ks, map_Bump)

## Error Handling

- Robust parsing with Result types
- File existence checking
- Graceful handling of malformed data
- User feedback via message system

## Memory Management

- Proper cleanup of loaded resources
- Texture caching to prevent duplicates
- Automatic disposal of temporary objects

## Testing

Test files included:
- `test_cube.obj` - Simple cube model
- `test_cube.mtl` - Basic material definition

## Future Enhancements

Possible improvements:
- Better texture cache management
- Support for more OBJ features
- Advanced material properties
- Model scaling UI controls
- Multiple model management
- Undo/redo functionality