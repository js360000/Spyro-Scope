using System;
using System.Collections;
using System.IO;
using OpenGL;

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
				// Try to load the texture using the existing Image class
				let image = scope Image(filePath);
				if (image.IsValid) {
					textureID = CreateOpenGLTexture(image);
					
					// Cache the texture
					String key = new String(filePath);
					textureMap[key] = textureID;
				}
			}
			
			return textureID;
		}
		
		static uint32 CreateOpenGLTexture(Image image) {
			uint32 textureID = 0;
			GL.glGenTextures(1, &textureID);
			GL.glBindTexture(GL.GL_TEXTURE_2D, textureID);
			
			// Set texture parameters
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_REPEAT);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_LINEAR_MIPMAP_LINEAR);
			GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_LINEAR);
			
			// Upload texture data
			GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_RGBA, image.width, image.height, 0, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, image.pixels);
			GL.glGenerateMipmap(GL.GL_TEXTURE_2D);
			
			return textureID;
		}
		
		public static void UnloadTexture(StringView filePath) {
			if (textureMap.ContainsKey(scope String(filePath))) {
				uint32 textureID = textureMap[scope String(filePath)];
				GL.glDeleteTextures(1, &textureID);
				
				// Remove from cache
				String key = scope String(filePath);
				textureMap.Remove(key);
				delete key;
			}
		}
		
		public static void ClearCache() {
			// Delete all OpenGL textures
			for (let kv in textureMap) {
				uint32 textureID = kv.value;
				GL.glDeleteTextures(1, &textureID);
			}
			
			// Clear the map
			DeleteDictionaryAndKeysAndValues!(textureMap);
			textureMap = new .();
		}
		
		public static int GetCacheSize() {
			return textureMap.Count;
		}
	}
}