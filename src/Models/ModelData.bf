using System;
using System.Collections;

namespace SpyroScope {
	class ModelData {
		public String name ~ delete _;
		
		// Vertex data
		public List<Vector3> vertices = new .() ~ delete _;
		public List<Vector3> normals = new .() ~ delete _;
		public List<Vector2> textureCoords = new .() ~ delete _;
		
		// Face data - stored as indices into vertex arrays
		public List<uint32> indices = new .() ~ delete _;
		
		// Material data
		public List<Material> materials = new .() ~ DeleteContainerAndItems!(_);
		public List<int> materialIndices = new .() ~ delete _; // Per-face material indices
		
		// Bounds
		public Vector3 minBounds = .(float.MaxValue, float.MaxValue, float.MaxValue);
		public Vector3 maxBounds = .(float.MinValue, float.MinValue, float.MinValue);
		
		// Transformation
		public Vector3 position = .Zero;
		public Vector3 rotation = .Zero;
		public Vector3 scale = .(1, 1, 1);

		public this(StringView name) {
			this.name = new String(name);
		}

		public void CalculateBounds() {
			minBounds = .(float.MaxValue, float.MaxValue, float.MaxValue);
			maxBounds = .(float.MinValue, float.MinValue, float.MinValue);
			
			for (let vertex in vertices) {
				if (vertex.x < minBounds.x) minBounds.x = vertex.x;
				if (vertex.y < minBounds.y) minBounds.y = vertex.y;
				if (vertex.z < minBounds.z) minBounds.z = vertex.z;
				
				if (vertex.x > maxBounds.x) maxBounds.x = vertex.x;
				if (vertex.y > maxBounds.y) maxBounds.y = vertex.y;
				if (vertex.z > maxBounds.z) maxBounds.z = vertex.z;
			}
		}

		public Vector3 GetCenter() {
			return (minBounds + maxBounds) * 0.5f;
		}

		public Vector3 GetSize() {
			return maxBounds - minBounds;
		}

		public void GenerateNormals() {
			// Clear existing normals
			normals.Clear();
			normals.Resize(vertices.Count);
			
			// Initialize all normals to zero
			for (int i = 0; i < normals.Count; i++) {
				normals[i] = .Zero;
			}
			
			// Calculate face normals and add to vertex normals
			for (int i = 0; i < indices.Count; i += 3) {
				let i0 = indices[i];
				let i1 = indices[i + 1];
				let i2 = indices[i + 2];
				
				let v0 = vertices[i0];
				let v1 = vertices[i1];
				let v2 = vertices[i2];
				
				let edge1 = v1 - v0;
				let edge2 = v2 - v0;
				let normal = Vector3.Cross(edge1, edge2);
				
				normals[i0] += normal;
				normals[i1] += normal;
				normals[i2] += normal;
			}
			
			// Normalize all vertex normals
			for (int i = 0; i < normals.Count; i++) {
				normals[i] = normals[i].Normalized;
			}
		}

		public int GetTriangleCount() {
			return indices.Count / 3;
		}
	}
}