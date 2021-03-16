Shader "Unlit/IsosurfaceRendering"
{
    Properties
	{
		_Volume ("Volume", 3D) = "" {}
		_NoiseTex("Noise Texture (Generated)", 2D) = "white" {}
		_GradientTex("Gradient Texture (Generated)", 3D) = "" {}
		_TFTex("Transfer Function Texture (Generated)", 2D) = "" {}
		_MinVal("Min val", Range(0.0, 1.0)) = 0.0
        _MaxVal("Max val", Range(0.0, 1.0)) = 1.0
	}

	CGINCLUDE

	ENDCG

	SubShader {
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100
        Cull Front
        ZTest LEqual
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha


		Pass
		{
			CGPROGRAM

      #define ITERATIONS 100
			#include "./IsosurfaceRendering.cginc"
			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}
}
