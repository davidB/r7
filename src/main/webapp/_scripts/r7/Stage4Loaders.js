define(['console', 'THREE', 'r7/evt', 'underscore', ], function(console, THREE, evt, _) {

  return function() {
    var self = {};
    var _pending =[];
  
    self.onEvent = function onEvent(e, out) {
      switch(e.k) {
        case 'SpawnTargetG1' :
        case 'SpawnShip' :
          if (!!e.modelId & !e.obj3d) {
            loadObj3d(e);
          }
          break;
        case 'SpawnArea' :
          if (!!e.modelId & !e.scene3d) {
            loadScene(e);
          }
          break;
        default :
           //pass
      }
      evt.moveInto(_pending, out);
    };

    // Blenders euler order is 'XYZ', but the equivalent euler rotation order in Three.js is 'ZYX'
    var fixOrientation = function(obj3d) {
      var y2 = obj3d.rotation.z;
      var z2 = - obj3d.rotation.y;
      //m.rotation.x = ob.rot[0];
      //obj3d.rotation.y = y2;
      //obj3d.rotation.z = z2;
      obj3d.eulerOrder = 'ZYX';
      return obj3d;
    };

    var loadScene = function(e){
      new THREE.SceneLoader().load('_models/' + e.modelId + '.scene.js?' + new Date().getTime(), function(result){
        _.each(result.objects, fixOrientation);
        e.scene3d = result;
        console.log('spawn scene3d ', e.modelId);
        _pending.push(e);
      });
    };

    var loadObj3d = function(e){
      new THREE.JSONLoader().load('_models/' + e.modelId + '.js?' + new Date().getTime(), function(geometry){
        //var material = new THREE.MeshNormalMaterial();
        //var material = new THREE.MeshNormalMaterial( { shading: THREE.SmoothShading } );
        //geometry.materials[ 0 ].shading = THREE.FlatShading; 
        //var material = new THREE.MeshFaceMaterial();
        var material = geometry.materials[0];
        //TODO should create a new object or at least change the timestamp
        e.obj3d = fixOrientation(new THREE.Mesh( geometry, material ));
        console.log('spawn obj3d ', e.modelId);
        _pending.push(e);
      });
    };
    return self;
  };
});
