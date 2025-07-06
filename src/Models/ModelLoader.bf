using System;
using System.Collections;
using System.IO;

namespace SpyroScope {
	static class ModelLoader {
		public static Result<ModelData> LoadOBJ(StringView filePath) {
			if (!File.Exists(filePath)) {
				return .Err;
			}
			
			let model = new ModelData(Path.GetFileNameWithoutExtension(filePath));
			
			// Try to load MTL file
			String mtlPath = scope String(Path.GetDirectoryPath(filePath));
			mtlPath.Append("/");
			mtlPath.Append(Path.GetFileNameWithoutExtension(filePath));
			mtlPath.Append(".mtl");
			
			Dictionary<String, Material> materialMap = scope .();
			if (File.Exists(mtlPath)) {
				LoadMTL(mtlPath, materialMap, model.materials);
			}
			
			// Parse OBJ file
			let lines = scope String();
			if (File.ReadAllText(filePath, lines) case .Err) {
				delete model;
				return .Err;
			}
			
			Material currentMaterial = null;
			
			for (let line in lines.Split('\n')) {
				let trimmedLine = line.Trim();
				if (trimmedLine.IsEmpty || trimmedLine.StartsWith('#')) {
					continue;
				}
				
				let parts = scope List<StringView>();
				for (let part in trimmedLine.Split(' ')) {
					let trimmedPart = part.Trim();
					if (!trimmedPart.IsEmpty) {
						parts.Add(trimmedPart);
					}
				}
				
				if (parts.Count == 0) continue;
				
				switch (parts[0]) {
				case "v":
					// Vertex
					if (parts.Count >= 4) {
						if (Float.Parse(parts[1]) case .Ok(let x) &&
							Float.Parse(parts[2]) case .Ok(let y) &&
							Float.Parse(parts[3]) case .Ok(let z)) {
							model.vertices.Add(.(x, y, z));
						}
					}
					
				case "vn":
					// Normal
					if (parts.Count >= 4) {
						if (Float.Parse(parts[1]) case .Ok(let x) &&
							Float.Parse(parts[2]) case .Ok(let y) &&
							Float.Parse(parts[3]) case .Ok(let z)) {
							model.normals.Add(.(x, y, z));
						}
					}
					
				case "vt":
					// Texture coordinate
					if (parts.Count >= 3) {
						if (Float.Parse(parts[1]) case .Ok(let u) &&
							Float.Parse(parts[2]) case .Ok(let v)) {
							model.textureCoords.Add(.(u, v));
						}
					}
					
				case "f":
					// Face
					if (parts.Count >= 4) {
						ParseFace(parts, model, currentMaterial);
					}
					
				case "usemtl":
					// Use material
					if (parts.Count >= 2) {
						let materialName = scope String(parts[1]);
						if (materialMap.ContainsKey(materialName)) {
							currentMaterial = materialMap[materialName];
						}
					}
				}
			}
			
			// Generate normals if not provided
			if (model.normals.Count == 0) {
				model.GenerateNormals();
			}
			
			// Calculate bounds
			model.CalculateBounds();
			
			return .Ok(model);
		}
		
		static void ParseFace(List<StringView> parts, ModelData model, Material currentMaterial) {
			// Support triangles and quads
			List<uint32> faceIndices = scope .();
			
			for (int i = 1; i < parts.Count; i++) {
				let vertexData = parts[i];
				let components = scope List<StringView>();
				for (let component in vertexData.Split('/')) {
					components.Add(component);
				}
				
				if (components.Count > 0 && !components[0].IsEmpty) {
					if (UInt32.Parse(components[0]) case .Ok(let vertexIndex)) {
						faceIndices.Add(vertexIndex - 1); // OBJ indices are 1-based
					}
				}
			}
			
			// Convert quads to triangles
			if (faceIndices.Count == 3) {
				// Triangle
				model.indices.Add(faceIndices[0]);
				model.indices.Add(faceIndices[1]);
				model.indices.Add(faceIndices[2]);
				model.materialIndices.Add(currentMaterial != null ? model.materials.IndexOf(currentMaterial) : -1);
			} else if (faceIndices.Count == 4) {
				// Quad - split into two triangles
				model.indices.Add(faceIndices[0]);
				model.indices.Add(faceIndices[1]);
				model.indices.Add(faceIndices[2]);
				model.materialIndices.Add(currentMaterial != null ? model.materials.IndexOf(currentMaterial) : -1);
				
				model.indices.Add(faceIndices[0]);
				model.indices.Add(faceIndices[2]);
				model.indices.Add(faceIndices[3]);
				model.materialIndices.Add(currentMaterial != null ? model.materials.IndexOf(currentMaterial) : -1);
			}
		}
		
		static void LoadMTL(StringView filePath, Dictionary<String, Material> materialMap, List<Material> materialList) {
			let lines = scope String();
			if (File.ReadAllText(filePath, lines) case .Err) {
				return;
			}
			
			Material currentMaterial = null;
			String basePath = scope String(Path.GetDirectoryPath(filePath));
			basePath.Append("/");
			
			for (let line in lines.Split('\n')) {
				let trimmedLine = line.Trim();
				if (trimmedLine.IsEmpty || trimmedLine.StartsWith('#')) {
					continue;
				}
				
				let parts = scope List<StringView>();
				for (let part in trimmedLine.Split(' ')) {
					let trimmedPart = part.Trim();
					if (!trimmedPart.IsEmpty) {
						parts.Add(trimmedPart);
					}
				}
				
				if (parts.Count == 0) continue;
				
				switch (parts[0]) {
				case "newmtl":
					// New material
					if (parts.Count >= 2) {
						currentMaterial = new Material(parts[1]);
						materialList.Add(currentMaterial);
						materialMap[new String(parts[1])] = currentMaterial;
					}
					
				case "Ka":
					// Ambient color
					if (currentMaterial != null && parts.Count >= 4) {
						if (Float.Parse(parts[1]) case .Ok(let r) &&
							Float.Parse(parts[2]) case .Ok(let g) &&
							Float.Parse(parts[3]) case .Ok(let b)) {
							currentMaterial.ambientColor = .(r, g, b);
						}
					}
					
				case "Kd":
					// Diffuse color
					if (currentMaterial != null && parts.Count >= 4) {
						if (Float.Parse(parts[1]) case .Ok(let r) &&
							Float.Parse(parts[2]) case .Ok(let g) &&
							Float.Parse(parts[3]) case .Ok(let b)) {
							currentMaterial.diffuseColor = .(r, g, b);
						}
					}
					
				case "Ks":
					// Specular color
					if (currentMaterial != null && parts.Count >= 4) {
						if (Float.Parse(parts[1]) case .Ok(let r) &&
							Float.Parse(parts[2]) case .Ok(let g) &&
							Float.Parse(parts[3]) case .Ok(let b)) {
							currentMaterial.specularColor = .(r, g, b);
						}
					}
					
				case "Ns":
					// Specular exponent
					if (currentMaterial != null && parts.Count >= 2) {
						if (Float.Parse(parts[1]) case .Ok(let ns)) {
							currentMaterial.specularExponent = ns;
						}
					}
					
				case "d", "Tr":
					// Alpha/transparency
					if (currentMaterial != null && parts.Count >= 2) {
						if (Float.Parse(parts[1]) case .Ok(let alpha)) {
							currentMaterial.alpha = alpha;
						}
					}
					
				case "map_Kd":
					// Diffuse texture
					if (currentMaterial != null && parts.Count >= 2) {
						String texturePath = scope String(basePath);
						texturePath.Append(parts[1]);
						currentMaterial.SetDiffuseMap(texturePath);
					}
					
				case "map_Ks":
					// Specular texture
					if (currentMaterial != null && parts.Count >= 2) {
						String texturePath = scope String(basePath);
						texturePath.Append(parts[1]);
						currentMaterial.SetSpecularMap(texturePath);
					}
					
				case "map_Bump", "bump":
					// Normal map
					if (currentMaterial != null && parts.Count >= 2) {
						String texturePath = scope String(basePath);
						texturePath.Append(parts[1]);
						currentMaterial.SetNormalMap(texturePath);
					}
				}
			}
		}
	}
}