Shader "DM/Planet With Poles" {
	Properties {
		_Seed ("Seed", Range(0.0,1.0)) = 0.5
		
		_NoiseScale1 ("Noise Scale", Float) = 1
		_NoiseTexture1 ("Noise Texture", 2D) = "white" {}
		_RampTexture ("Ramp Texture", 2D) = "white" {}
		_BandFilter ("Band Filter", Range(0.0,1.0)) = 0.5
		_BandWidth ("Band Width", Range(0.0,1.0)) = 0.5
		_PoleWidth ("Pole Width", Float) = 5
		
		_NoiseTexture2 ("City Lights Noise Texture", 2D) = "white" {}
		_CityLightColor ("City Light Color", Color) = (1,1,1)
		_CityScale ("City Lights Scale", Float) = 1
		_CityWidth ("City Lights Width", Range(0,0.5)) = 0.1
		_CityRimPower ("City Rim Power", Range(0.5,32.0)) = 1.0
		
		
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower ("Rim Power", Range(0.5,32.0)) = 3.0
		_WaterColor ("Water Color", Color) = (0.5,0.5,0.5,1)
		
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125 
	}
	
	SubShader {
		Tags { "RenderType" = "Opaque" }
		
  		CGPROGRAM

		#pragma surface surf PlanetSpecular vertex:vert
		#pragma target 3.0
		
		
		struct Input {
			float4 localPos;
			float3 viewDir;
			float3 lightDir; 
			float3 normal;
		};
		
		float _NoiseScale1;
		float _CityScale;
		float _CityWidth;
		float _Shininess;
		float _BandFilter;
		float _BandWidth;
		float _Seed;
		float _PoleWidth;
		float4 _RimColor;
		float4 _CityLightColor;
		float4 _WaterColor;
      	float _RimPower;
      	float _CityRimPower;
      
		
		sampler2D _NoiseTexture1;
		sampler2D _NoiseTexture2;
		sampler2D _RampTexture;
		
		half4 LightingPlanetSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			half3 h = normalize (lightDir + viewDir);
			half diff = max (0, dot (s.Normal, lightDir));
			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, 48.0) * s.Alpha;
			half4 c;
			half rim = 1-saturate(dot (normalize((viewDir-(lightDir/3.5))), s.Normal));
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec * _Shininess * _SpecColor) * (atten * 2);
			c.rgb += _RimColor.rgb * pow (rim, _RimPower);
			c.a = s.Alpha;
			return c;
      	}
		
		
		void vert (inout appdata_full v, out Input o) {
        	o.localPos = v.vertex;
        	o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
        	o.normal = v.normal;
      	}
		
		void surf (Input IN, inout SurfaceOutput o) {
			float3 w = (IN.localPos * _NoiseScale1) + _Seed;
			
			
			float X = tex2D(_NoiseTexture1, _Seed+w.xy).r;
			float Y = tex2D(_NoiseTexture1, _Seed+w.yz).r;
			float Z = tex2D(_NoiseTexture1, _Seed+w.xz).r;
			float H = (X+Y+Z)/3;

			float C = H;
			
			H = clamp(H, _BandFilter, _BandFilter+_BandWidth);
			H = saturate((H-_BandFilter) / (_BandFilter+_BandWidth-H));
			half4 c;
			half2 uv = (1,H);
			half4 _Land = tex2D(_RampTexture, uv);
			c = H<0.0001?_WaterColor:_Land;
			
			w *= _CityScale;
			half rim = 1.0 - saturate(dot (IN.lightDir, IN.normal));
			X = tex2D(_NoiseTexture2, _Seed+w.xy).r;
			Y = tex2D(_NoiseTexture2, _Seed+w.yz).r;
			Z = tex2D(_NoiseTexture2, _Seed+w.xz).r;
			half CH = (X+Y+Z)/3;
			
			half lat = abs(IN.localPos.y);
			
			
			
			if(lat > _PoleWidth && H>=0.0001) {
				half f = ((lat - _PoleWidth) / 0.5);
				//c = lerp(half4(1,1,1,1), c, 1-f);
				c += (half4(1,1,1,1) * f);
				
			} else {
				if(C-_BandFilter > 0 && C-_BandFilter < _CityWidth) { //this is where the city lights get calculated.
					o.Emission = _CityLightColor * pow(rim, _CityRimPower) * CH;
				}
			}
			
			
			
			
			
			
			o.Albedo = c;
			
			
			
			o.Alpha = (H>0?0:1);
		}		
  	ENDCG
	} 
}
