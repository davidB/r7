{

"metadata" :
{
    "formatVersion" : 3,
    "sourceFile"    : "ship01.blend",
    "generatedBy"   : "Blender 2.63 Exporter",
    "objects"       : 2,
    "geometries"    : 2,
    "materials"     : 1,
    "textures"      : 0
},

"type" : "scene",
"urlBaseType" : "relativeToScene",


"objects" :
{
    "ship01.2d" : {
        "geometry"  : "geo_Cube.001",
        "groups"    : [  ],
        "materials" : [  ],
        "position"  : [ -0.015920, 0.024778, 1.998574 ],
        "rotation"  : [ 0.000000, -0.000000, 0.000000 ],
        "quaternion": [ 1.000000, 0.000000, 0.000000, 0.000000 ],
        "scale"     : [ 1.000000, 1.000000, 1.000000 ],
        "visible"       : true,
        "castShadow"    : false,
        "receiveShadow" : false,
        "doubleSided"   : false
    },

    "ship01" : {
        "geometry"  : "geo_Cube",
        "groups"    : [  ],
        "materials" : [ "Material" ],
        "position"  : [ -0.022583, 0.057269, 1.891053 ],
        "rotation"  : [ 0.000000, -0.000000, 0.000000 ],
        "quaternion": [ 1.000000, 0.000000, 0.000000, 0.000000 ],
        "scale"     : [ 1.000000, 1.000000, 1.000000 ],
        "visible"       : true,
        "castShadow"    : false,
        "receiveShadow" : false,
        "doubleSided"   : false
    }
},


"geometries" :
{
    "geo_Cube.001" : {
        "type" : "embedded_mesh",
        "id"  : "emb_Cube.001"
    },

    "geo_Cube" : {
        "type" : "embedded_mesh",
        "id"  : "emb_Cube"
    }
},


"materials" :
{
    "Material" : {
        "type": "MeshLambertMaterial",
        "parameters": { "color": 10709561, "opacity": 1, "blending": "NormalBlending" }
    }
},


"embeds" :
{
"emb_Cube.001": {    "scale" : 1.000000,

    "materials": [	{
	"DbgColor" : 15658734,
	"DbgIndex" : 0,
	"DbgName" : "default",
	"vertexColors" : false
	}],

    "vertices": [3.018378,0.000000,-2.000000,-1.000000,-1.000000,-2.000000,-1.000000,1.000000,-2.000000],

    "morphTargets": [],

    "normals": [0.000000,0.000000,-1.000000],

    "colors": [],

    "uvs": [[]],

    "faces": [34,0,1,2,0,0,0,0]

},

"emb_Cube": {    "scale" : 1.000000,

    "materials": [	{
	"DbgColor" : 15658734,
	"DbgIndex" : 0,
	"DbgName" : "Material",
	"blending" : "NormalBlending",
	"colorAmbient" : [0.0, 0.0, 0.0],
	"colorDiffuse" : [0.6400000190734865, 0.41904841093791134, 0.22387421464732604],
	"colorSpecular" : [1.0, 1.0, 1.0],
	"depthTest" : true,
	"depthWrite" : true,
	"shading" : "Lambert",
	"specularCoef" : 50,
	"transparency" : 1.0,
	"transparent" : false,
	"vertexColors" : false
	}],

    "vertices": [3.037859,-0.005498,-1.239009,-1.000000,-1.000000,-1.000000,-1.000000,1.000000,-1.000000,-0.155354,0.000000,-0.525859,-1.000000,-1.000000,-1.000000,-1.000000,1.000000,-1.000000],

    "morphTargets": [],

    "normals": [0.098575,-0.000214,-0.995117,-0.622272,-0.776360,-0.100070,-0.621570,0.776910,-0.100070,-0.002106,0.000702,0.999969,-0.059084,0.000000,-0.998230],

    "colors": [],

    "uvs": [[]],

    "faces": [34,0,1,2,0,0,1,2,34,1,3,2,0,1,3,2,34,0,2,3,0,0,2,3,34,0,3,1,0,0,3,1,34,0,4,5,0,0,4,4]

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
    "camera"  : ""
}

}
