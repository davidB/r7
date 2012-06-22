{

"metadata" :
{
    "formatVersion" : 3,
    "sourceFile"    : "area01.blend",
    "generatedBy"   : "Blender 2.63 Exporter",
    "objects"       : 1,
    "geometries"    : 1,
    "materials"     : 1,
    "textures"      : 0
},

"type" : "scene",
"urlBaseType" : "relativeToScene",


"objects" :
{
    "wall" : {
        "geometry"  : "geo_Plane",
        "groups"    : [  ],
        "materials" : [ "Material.001" ],
        "position"  : [ -26.067688, -2.683169, -0.026086 ],
        "rotation"  : [ 0.000000, -0.000000, 0.000000 ],
        "quaternion": [ 1.000000, 0.000000, 0.000000, 0.000000 ],
        "scale"     : [ 10.000000, 10.000000, 10.000000 ],
        "visible"       : true,
        "castShadow"    : false,
        "receiveShadow" : false,
        "doubleSided"   : false
    }
},


"geometries" :
{
    "geo_Plane" : {
        "type" : "embedded_mesh",
        "id"  : "emb_Plane"
    }
},


"materials" :
{
    "Material.001" : {
        "type": "MeshLambertMaterial",
        "parameters": { "color": 1690692, "opacity": 1, "vertexColors": "vertex", "blending": "NormalBlending" }
    }
},


"cameras" :
{
    "default_camera" : {
        "type"  : "perspective",
        "fov"   : 60.000000,
        "aspect": 1.333000,
        "near"  : 1.000000,
        "far"   : 10000.000000,
        "position": [ 0.000000, 0.000000, 10.000000 ],
        "target"  : [ 0.000000, 0.000000, 0.000000 ]
    }
},


"lights" :
{
    "default_light": {
        "type"    	 : "directional",
        "direction"	 : [ 0.000000, 1.000000, 1.000000 ],
        "color" 	 : 16777215,
        "intensity"	 : 0.80
    }
},


"embeds" :
{
"emb_Plane": {    "scale" : 1.000000,

    "materials": [	{
	"DbgColor" : 15658734,
	"DbgIndex" : 0,
	"DbgName" : "Material.001",
	"blending" : "NormalBlending",
	"colorAmbient" : [0.0, 0.0, 0.0],
	"colorDiffuse" : [0.09850950539112091, 0.800000011920929, 0.26667943596839905],
	"colorSpecular" : [0.0, 0.0, 0.0],
	"depthTest" : true,
	"depthWrite" : true,
	"shading" : "Lambert",
	"specularCoef" : 50,
	"transparency" : 1.0,
	"transparent" : false,
	"vertexColors" : false
	}],

    "vertices": [-0.048957,-0.220610,-0.000000,0.179820,1.008202,0.000000,-0.647343,3.352307,0.000000,-0.983596,4.059269,0.000000,6.249149,3.583565,0.000000,7.610647,3.550758,0.000000,7.594243,3.944444,0.000000,6.954503,1.336274,0.000000,6.306561,-2.124884,-0.000000,7.668059,-2.157691,-0.000000,0.092289,-1.522480,-0.000000,-0.967193,-2.230269,-0.000000,1.795574,-1.844785,-0.000000,2.804395,-1.287063,-0.000000,3.747602,-1.787372,-0.000000,4.715413,-1.393686,-0.000000,6.306561,-2.123646,-0.000000],

    "morphTargets": [],

    "normals": [0.000000,0.000000,1.000000,0.000000,0.000000,0.999969],

    "colors": [],

    "uvs": [[]],

    "faces": [34,9,7,8,0,0,0,0,34,7,5,4,0,0,0,0,34,3,0,1,0,1,0,0,34,11,12,10,0,0,0,0,34,14,16,15,0,0,0,0,34,3,1,2,0,1,0,0,34,7,4,8,0,0,0,0,34,10,0,3,0,0,0,1,34,14,15,13,0,0,0,1,34,3,2,4,0,1,0,0,34,5,3,4,0,0,1,0,34,14,13,12,0,0,1,0,34,6,3,5,0,0,1,0,34,3,11,10,0,1,0,0,34,11,14,12,0,0,0,0]

}
},


"transform" :
{
    "position"  : [ 0.000000, 0.000000, 0.000000 ],
    "rotation"  : [ -1.570796, 0.000000, 0.000000 ],
    "scale"     : [ 1.000000, 1.000000, 1.000000 ]
},

"defaults" :
{
    "bgcolor" : [ 0.000000, 0.000000, 0.000000 ],
    "bgalpha" : 1.000000,
    "camera"  : "default_camera"
}

}
