using System;
using System.IO;

namespace SpyroScope {
	static class ModelTest {
		public static void Test() {
			let objPath = "/home/runner/work/Spyro-Scope/Spyro-Scope/test_cube.obj";
			
			Console.WriteLine("Testing model loading...");
			
			// Test model loading
			let result = ModelLoader.LoadOBJ(objPath);
			switch (result) {
				case .Ok(let model):
					Console.WriteLine("Model loaded successfully!");
					Console.WriteLine($"Name: {model.name}");
					Console.WriteLine($"Vertices: {model.vertices.Count}");
					Console.WriteLine($"Normals: {model.normals.Count}");
					Console.WriteLine($"Texture Coords: {model.textureCoords.Count}");
					Console.WriteLine($"Indices: {model.indices.Count}");
					Console.WriteLine($"Materials: {model.materials.Count}");
					Console.WriteLine($"Triangles: {model.GetTriangleCount()}");
					
					// Test bounds calculation
					model.CalculateBounds();
					Console.WriteLine($"Bounds: {model.minBounds} to {model.maxBounds}");
					Console.WriteLine($"Center: {model.GetCenter()}");
					Console.WriteLine($"Size: {model.GetSize()}");
					
					delete model;
				case .Err:
					Console.WriteLine("Failed to load model");
			}
		}
	}
}