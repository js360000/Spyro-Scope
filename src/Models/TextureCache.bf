using System;
using System.Collections;
using System.IO;

namespace SpyroScope {
	static class TextureCache {
		static Dictionary<String, uint32> textureMap = new .() ~ DeleteDictionaryAndKeysAndValues!(_);
		
		public static uint32 LoadTexture(StringView filePath) {
			// Check if texture is already loaded
			if (textureMap.ContainsKey(scope String(filePath))) {
				return textureMap[scope String(filePath)];
			}
			
			// Load new texture
			uint32 textureID = 0;
			if (File.Exists(filePath)) {
				// Use the existing Texture class
				let texture = new Texture(scope String(filePath));
				if (texture.textureObjectID != 0) {
					textureID = texture.textureObjectID;
					
					// Cache the texture - we need to keep the texture object alive
					String key = new String(filePath);
					textureMap[key] = textureID;
				}
				// Note: We're not deleting the texture object because we want to keep it cached
			}
			
			return textureID;
		}
		
		public static void UnloadTexture(StringView filePath) {
			if (textureMap.ContainsKey(scope String(filePath))) {
				uint32 textureID = textureMap[scope String(filePath)];
				// Note: We can't safely delete the texture without keeping track of the Texture object
				// This is a limitation of the current approach
				
				// Remove from cache
				String key = scope String(filePath);
				textureMap.Remove(key);
				delete key;
			}
		}
		
		public static void ClearCache() {
			// Clear the map - note that we're not deleting the actual texture objects
			// This is a design limitation that should be addressed in a full implementation
			DeleteDictionaryAndKeysAndValues!(textureMap);
			textureMap = new .();
		}
		
		public static int GetCacheSize() {
			return textureMap.Count;
		}
	}
}