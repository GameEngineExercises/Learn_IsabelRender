#ifndef __ISOSURFACE_RENDERING_INCLUDED__
#define __ISOSURFACE_RENDERING_INCLUDED__

#include "UnityCG.cginc"

#ifndef ITERATIONS
#define ITERATIONS 100
#endif

half4 _Color;
sampler3D _Volume;
half _Intensity, _Threshold;
half3 _SliceMin, _SliceMax;
float4x4 _AxisRotationMatrix;

struct appdata
{
  float4 vertex : POSITION;
  float4 normal : NORMAL; //new add
  float2 uv : TEXCOORD0;
};

struct v2f
{
  float4 vertex : SV_POSITION;
  float2 uv : TEXCOORD0;
  float3 vertexLocal : TEXCOORD1; // new add
  float3 normal : NORMAL; //new add
};

//new +
struct frag_out 
{
    float4 colour : SV_TARGET;
};

sampler3D _GradientTex;

sampler2D _TFTex;
float _MinVal;
float _MaxVal;

float getDensity(float3 pos)
{
    return tex3Dlod(_Volume, float4(pos.x, pos.y, pos.z, 0.0f));
}

// Performs lighting calculations, and returns a modified colour.
float3 calculateLighting(float3 col, float3 normal, float3 lightDir, float3 eyeDir, float specularIntensity)
{
    float ndotl = max(lerp(0.0f, 1.5f, dot(normal, lightDir)), 0.5f); // modified, to avoid volume becoming too dark
    float3 diffuse = ndotl * col;
    float3 v = eyeDir;
    float3 r = normalize(reflect(-lightDir, normal));
    float rdotv = max( dot( r, v ), 0.0 );
    float3 specular = pow(rdotv, 32.0f) * float3(1.0f, 1.0f, 1.0f) * specularIntensity;
    return diffuse + specular;
}

// Gets the gradient at the specified position
float3 getGradient(float3 pos)
{
    return tex3Dlod(_GradientTex, float4(pos.x, pos.y, pos.z, 0.0f)).rgb;
}

float4 getTF1DColour(float density)
{
    return tex2Dlod(_TFTex, float4(density, 0.0f, 0.0f, 0.0f));
}

frag_out frag_surf(v2f i)
{
#define NUM_STEPS 1024
        const float stepSize = 1.732f/*greatest distance in box*/ / NUM_STEPS;

        float3 rayStartPos = i.vertexLocal + float3(0.5f, 0.5f, 0.5f);
        float3 rayDir = normalize(ObjSpaceViewDir(float4(i.vertexLocal, 0.0f)));
        // Start from the end, tand trace towards the vertex
        rayStartPos += rayDir * stepSize * NUM_STEPS;
        rayDir = -rayDir;

        // Create a small random offset in order to remove artifacts
        rayStartPos = rayStartPos + (2.0f * rayDir / NUM_STEPS);

        float4 col = float4(0,0,0,0);
        for (uint iStep = 0; iStep < NUM_STEPS; iStep++)
        {
            const float t = iStep * stepSize;
            const float3 currPos = rayStartPos + rayDir * t;
            // Make sure we are inside the box
            if (currPos.x < 0.0f || currPos.x >= 1.0f || currPos.y < 0.0f || currPos.y > 1.0f || currPos.z < 0.0f || currPos.z > 1.0f) // TODO: avoid branch?
                continue;

            const float density = getDensity(currPos);
            if (density > _MinVal && density < _MaxVal)
            {
                float3 normal = normalize(getGradient(currPos));
                col = getTF1DColour(density);
                col.rgb = calculateLighting(col.rgb, normal, -rayDir, -rayDir, 0.15);
                col.a = 1.0f;
                break;
            }
        }

        // Write fragment output
        frag_out output;
        output.colour = col;

        return output;
}

v2f vert(appdata v)
{
  v2f o;
  o.vertex = UnityObjectToClipPos(v.vertex);
  o.uv = v.uv;
  //o.world = mul(unity_ObjectToWorld, v.vertex).xyz;
  //o.local = v.vertex.xyz;
  o.vertexLocal = v.vertex;
  o.normal = UnityObjectToWorldNormal(v.normal); // new add
  return o;
}

//new + 
frag_out frag(v2f i)
{
    return frag_surf(i) ;
}


#endif 
