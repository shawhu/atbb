Shader "DM/SunZ" {
	Properties {
		_Seed ("Seed", Range(0.0,1.0)) = 0.5
		_NoiseScale1 ("Noise Scale", Float) = 1
		_NoiseTexture1 ("Noise Texture", 2D) = "white" {}
		_RampTexture ("Ramp Texture", 2D) = "white" {}
		_BandFilter ("Band Filter", Range(0.0,1.0)) = 0.5
		_BandWidth ("Band Width", Range(0.0,1.0)) = 0.5
		_RippleScale ("Ripple Scale", Float) = 0.001
	}
	
	SubShader {
		Tags { "RenderType" = "Opaque" }
		
  		CGPROGRAM

		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0
		
		
		struct Input {
			float4 localPos;
			float3 viewDir;
			float3 lightDir; 
			float3 normal;
		};
		
		float _NoiseScale1;
		float _Shininess;
		float _BandFilter;
		float _BandWidth;
		float _Seed;
		float _RippleScale;
      
		
		sampler2D _NoiseTexture1;
		sampler2D _RampTexture;
		
	
		void vert (inout appdata_full v, out Input o) {
        	o.localPos = v.vertex;
        	o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
        	o.normal = v.normal;
      	}
		
		void surf (Input IN, inout SurfaceOutput o) {
			//_Seed += _SinTime[1] * _RippleScale;
			float3 w = (IN.localPos * _NoiseScale1) + _Seed;
			
			float X = tex2D(_NoiseTexture1, _Seed+w.xy).r;
			float Y = tex2D(_NoiseTexture1, _Seed+w.yz).r;
			float Z = tex2D(_NoiseTexture1, _Seed+w.xz).r;
			float H = (X+Y+Z)/3;

			float C = H;
			_BandWidth += _CosTime[3] * _RippleScale * 10;
			H = clamp(H, _BandFilter, _BandFilter+_BandWidth);
			H = saturate((H-_BandFilter) / (_BandFilter+_BandWidth-H));
			half4 c;
			
			float2 uv = (1, H);
			c = tex2D(_RampTexture, uv);
		
			
		
			
			
			
			o.Emission = c;
			o.Alpha = (H>0?0:1);
		}		
  	ENDCG
	} 
}
