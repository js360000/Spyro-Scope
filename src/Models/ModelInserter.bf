using System;
using System.Collections;

namespace SpyroScope {
	static class ModelInserter {
		// Scale factor to convert from standard 3D coordinates to Spyro's coordinate system
		public static float CoordinateScale = 256.0f;
		
		public static void InsertModel(ModelData model, TerrainCollision collision, bool clearLevel = false) {
			if (model == null || collision == null) return;
			
			// Clear existing level if requested
			if (clearLevel) {
				collision.Clear();
			}
			
			// Convert model to Spyro coordinates and generate collision
			let spyroTriangles = ConvertToSpyroTriangles(model);
			
			// Add triangles to collision system
			for (let triangle in spyroTriangles) {
				collision.AddTriangle(triangle);
			}
			
			// Update collision grid
			collision.GenerateGrid();
			collision.GenerateMesh();
		}
		
		static List<CollisionTriangle> ConvertToSpyroTriangles(ModelData model) {
			let triangles = new List<CollisionTriangle>();
			
			// Apply model transformation
			let transformedVertices = scope List<Vector3>();
			for (let vertex in model.vertices) {
				let transformed = ApplyTransformation(vertex, model.position, model.rotation, model.scale);
				transformedVertices.Add(transformed);
			}
			
			// Convert triangles
			for (int i = 0; i < model.indices.Count; i += 3) {
				let i0 = model.indices[i];
				let i1 = model.indices[i + 1];
				let i2 = model.indices[i + 2];
				
				let v0 = transformedVertices[i0];
				let v1 = transformedVertices[i1];
				let v2 = transformedVertices[i2];
				
				// Convert to Spyro coordinates
				let spyroV0 = ConvertToSpyroCoordinates(v0);
				let spyroV1 = ConvertToSpyroCoordinates(v1);
				let spyroV2 = ConvertToSpyroCoordinates(v2);
				
				// Create triangle array for packing
				Vector3Int[3] triangleVertices = .(spyroV0, spyroV1, spyroV2);
				
				// Pack into CollisionTriangle format
				let packedTriangle = CollisionTriangle.Pack(triangleVertices);
				triangles.Add(packedTriangle);
			}
			
			return triangles;
		}
		
		static Vector3 ApplyTransformation(Vector3 vertex, Vector3 position, Vector3 rotation, Vector3 scale) {
			// Apply scale
			let scaled = vertex * scale;
			
			// Apply rotation (Euler angles)
			let rotated = ApplyRotation(scaled, rotation);
			
			// Apply translation
			return rotated + position;
		}
		
		static Vector3 ApplyRotation(Vector3 vertex, Vector3 eulerAngles) {
			// Convert degrees to radians
			let radians = eulerAngles * (Math.PI_f / 180.0f);
			
			// Create rotation matrix
			let rotationMatrix = Matrix3.Euler(radians.x, radians.y, radians.z);
			
			// Apply rotation
			return rotationMatrix * vertex;
		}
		
		static Vector3Int ConvertToSpyroCoordinates(Vector3 vertex) {
			// Convert from standard 3D coordinates to Spyro's fixed-point system
			let scaled = vertex * CoordinateScale;
			
			return Vector3Int(
				(int32)Math.Round(scaled.x),
				(int32)Math.Round(scaled.y),
				(int32)Math.Round(scaled.z)
			);
		}
		
		public static Vector3 ConvertFromSpyroCoordinates(Vector3Int spyroVertex) {
			// Convert from Spyro's fixed-point system to standard 3D coordinates
			return Vector3(
				(float)spyroVertex.x / CoordinateScale,
				(float)spyroVertex.y / CoordinateScale,
				(float)spyroVertex.z / CoordinateScale
			);
		}
		
		public static Mesh CreateRenderMesh(ModelData model) {
			if (model == null || model.vertices.Count == 0) return null;
			
			// Convert model data to mesh format
			let vertexCount = model.vertices.Count;
			let vertices = new Vector3[vertexCount];
			let normals = new Vector3[vertexCount];
			let colors = new Renderer.Color4[vertexCount];
			let uvs = new Vector2[vertexCount];
			
			// Copy vertices
			for (int i = 0; i < vertexCount; i++) {
				vertices[i] = model.vertices[i];
			}
			
			// Copy normals
			if (model.normals.Count == vertexCount) {
				for (int i = 0; i < vertexCount; i++) {
					normals[i] = model.normals[i];
				}
			} else {
				// Use default normals
				for (int i = 0; i < vertexCount; i++) {
					normals[i] = .(0, 1, 0);
				}
			}
			
			// Copy texture coordinates
			if (model.textureCoords.Count == vertexCount) {
				for (int i = 0; i < vertexCount; i++) {
					uvs[i] = model.textureCoords[i];
				}
			} else {
				// Use default UVs
				for (int i = 0; i < vertexCount; i++) {
					uvs[i] = .(0, 0);
				}
			}
			
			// Set default colors
			for (int i = 0; i < vertexCount; i++) {
				colors[i] = .(255, 255, 255, 255);
			}
			
			// Create mesh
			let mesh = new Mesh(vertices, uvs, normals, colors);
			
			// Set indices if available
			if (model.indices.Count > 0) {
				delete mesh.indices;
				mesh.indices = new uint32[model.indices.Count];
				for (int i = 0; i < model.indices.Count; i++) {
					mesh.indices[i] = model.indices[i];
				}
			}
			
			return mesh;
		}
	}
}