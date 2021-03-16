using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GenerateVolumeTexture : EditorWindow
{
    [MenuItem("Window/VolumeTextureBuilder")]
    static void Init()
    {
        var window = EditorWindow.GetWindow(typeof(GenerateVolumeTexture));
        window.Show();
    }

    string inputPath, outputPath;
    int width = 500, height = 500, depth = 100;
    Object asset;

    void OnEnable()
    {
        inputPath = "Assets/lsabel2/pf21.bin";
        outputPath = "Assets/Textures/pf21.asset";
    }

    void OnGUI()
    {
        const float headerSize = 120f;

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("Input binary file path", GUILayout.Width(headerSize));
            asset = EditorGUILayout.ObjectField(asset, typeof(Object), true);  
            inputPath = AssetDatabase.GetAssetPath(asset);       
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("Width", GUILayout.Width(headerSize));
            width = EditorGUILayout.IntField(width);
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("Height", GUILayout.Width(headerSize));
            height = EditorGUILayout.IntField(height);
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("Depth", GUILayout.Width(headerSize));
            depth = EditorGUILayout.IntField(depth);
        }

        using (new EditorGUILayout.HorizontalScope())
        {
            GUILayout.Label("Depth", GUILayout.Width(headerSize));
            outputPath = EditorGUILayout.TextField(outputPath);
        }

        if (GUILayout.Button("Build"))
        {

            var volume = Build(inputPath, width, height, depth);
        
            AssetDatabase.CreateAsset(volume, outputPath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Debug.LogWarning("OK");
      
        }
    }

    float[] LoadFloatArrayFromFile(string path)
    {
        byte[] a = System.IO.File.ReadAllBytes(path);
        float[] b = new float[a.Length / 4]; 
        System.Buffer.BlockCopy(a, 0, b, 0, a.Length);
        return b;
    }

    Texture3D Build(string inputPath, int size_x, int size_y, int size_z)
    {
        float[] source = LoadFloatArrayFromFile(inputPath);
        Texture3D volume = new Texture3D(size_x, size_y, size_z, TextureFormat.ARGB32, true);

        var voxels = new Color[size_x * size_y * size_z];
        int i = 0;
        Color color = Color.black; //RGBA (0, 0, 0, 1)
        for (int z = 0; z < size_z; ++z)
        {
            for (int y = 0; y < size_y; ++y)
            {
                for (int x = 0; x < size_x; ++x, ++i)
                {
                    if (source[i] == 0) {
                        color.r = 1.0f; //source[i];
                    }
                    else
                    {
                        color.r = 0.0f;
                    }
                    
        
                    color.g = color.b = color.a = 0.0f;
                    color.a = 1.0f;
                    voxels[i] = color;
                }
            }
        }

        volume.SetPixels(voxels);
        volume.Apply();
        volume.filterMode = FilterMode.Point;
        return volume;
    }

}
