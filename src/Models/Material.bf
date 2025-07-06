using System;

namespace SpyroScope {
	class Material {
		public String name ~ delete _;
		public Vector3 ambientColor = .(0.2f, 0.2f, 0.2f);
		public Vector3 diffuseColor = .(0.8f, 0.8f, 0.8f);
		public Vector3 specularColor = .(1.0f, 1.0f, 1.0f);
		public float specularExponent = 1.0f;
		public float alpha = 1.0f;

		public String diffuseMapPath ~ delete _;
		public String normalMapPath ~ delete _;
		public String specularMapPath ~ delete _;
		
		public uint32 diffuseTextureID;
		public uint32 normalTextureID;
		public uint32 specularTextureID;

		public this(StringView name) {
			this.name = new String(name);
		}

		public bool HasDiffuseMap => diffuseMapPath != null && !diffuseMapPath.IsEmpty;
		public bool HasNormalMap => normalMapPath != null && !normalMapPath.IsEmpty;
		public bool HasSpecularMap => specularMapPath != null && !specularMapPath.IsEmpty;

		public void SetDiffuseMap(StringView path) {
			DeleteAndNullify!(diffuseMapPath);
			if (!path.IsEmpty) {
				diffuseMapPath = new String(path);
			}
		}

		public void SetNormalMap(StringView path) {
			DeleteAndNullify!(normalMapPath);
			if (!path.IsEmpty) {
				normalMapPath = new String(path);
			}
		}

		public void SetSpecularMap(StringView path) {
			DeleteAndNullify!(specularMapPath);
			if (!path.IsEmpty) {
				specularMapPath = new String(path);
			}
		}
	}
}