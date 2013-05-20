Shader "DM/AtmosphereZ" {
	Properties {
		_Speed ("Speed", Range(0.01, 0.5)) = 0.5
		_NoiseScale1 ("Noise Scale", Float) = 1
		_NoiseTexture1 ("Noise Texture", 2D) = "white" {}
		_RampTexture ("Ramp Texture", 2D) = "white" {}
		_BandFilter ("Band Filter", Range(0.0,1.0)) = 0.5
		_BandWidth ("Band Width", Range(0.0,1.0)) = 0.5
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower ("Rim Power", Range(0.5,32.0)) = 3.0
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
	}
	
	SubShader {
		Tags { "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha	
		Cull Off
  		CGPROGRAM

		#pragma surface surf PlanetSpecular vertex:vert
		#pragma target 2.0
		
		
		struct Input {
			float4 localPos;
			float3 viewDir;
		};
		
		float _NoiseScale1;
		float _BandFilter;
		float _BandWidth;
		float _Speed;
		float4 _RimColor;
      	float _RimPower;
      
		
		sampler2D _NoiseTexture1;
		sampler2D _RampTexture;
		
		half4 LightingPlanetSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			half3 h = normalize (lightDir + viewDir);
			half diff = max (0, dot (s.Normal, lightDir));
			float nh = max (0, dot (s.Normal, h));
			half4 c;
			half rim = 1-saturate(dot (normalize(viewDir), s.Normal));
			c.rgb = (s.Albedo * _LightColor0.rgb * diff) * (atten * 2);
			float rp = pow (rim, _RimPower);
			c.rgb *= _RimColor.rgb * (1-rp);
			c.a = s.Alpha * (1-rp);
			return c;
      	}
		
		
		void vert (inout appdata_full v, out Input o) {
        	o.localPos = v.vertex;
      	}
		
		void surf (Input IN, inout SurfaceOutput o) {
		
			float3 w = (IN.localPos * _NoiseScale1);
			
			float _Seed =  _Time[0] * _Speed;
			float X = tex2D(_NoiseTexture1, _Seed+w.xy).r;
			float Y = tex2D(_NoiseTexture1, _Seed+w.yz).r;
			float Z = tex2D(_NoiseTexture1, _Seed+w.xz).r;
			float H = (X+Y+Z)/3;
      		
			
			H = clamp(H, _BandFilter, _BandFilter+_BandWidth);
			H = saturate((H-_BandFilter) / (_BandFilter+_BandWidth-H));
			float2 uv = (1, H);
			half4 c = tex2D(_RampTexture, uv);
			
			o.Alpha = (1-H)*0.8;
			o.Albedo = (o.Alpha<0.1?0:c);
		}		
  	ENDCG
	} 
}
