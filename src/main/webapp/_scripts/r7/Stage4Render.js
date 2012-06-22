define(['THREE', 'console', 'r7/evt', 'r7/models', 'webglDetector', 'underscore'], function(THREE, console, evt, models, webglDetector, _) {
  return function(container) {

    var _scene = new THREE.Scene();
    var _cube = null;
    var w = container.clientWidth;
    var h = container.clientHeight;

    var _camera = new THREE.PerspectiveCamera(
      75, //             VIEW_ANGLE
      w / h, //             ASPECT
      1, //             NEAR,
      10000 //FAR
    );

    _camera.position.z = 100;
    _scene.add(_camera);

    //_cameraControls = new THREE.DragPanControls(_camera);

    
    var _renderer = null;
    if (webglDetector.webgl) {
      _renderer = new THREE.WebGLRenderer({
        antialias : true,
        preserveDrawingBuffer : true // to allow screenshot
      });
    } else {
      //TODO display message if Webgl required
      _renderer = new THREE.CanvasRenderer();
    }
    _renderer.setSize(w, h);
    _renderer.setClearColorHex(0xEEEEEE, 1.0);
    _renderer.clear();
    container.appendChild( _renderer.domElement);

    // Lights
		//_scene.add( new THREE.AmbientLight( 0xFFFFFF ) );
		/*
    var light = new THREE.DirectionalLight(0xFFFFFF);  // changed to directional light - easier as a first step
    light.position.set(0, 0, 200).normalize(); // for directional lights, position is actually a direction vector
    _scene.add(light); 
*/
		//var pointLight = new THREE.PointLight( 0xffffff, 5, 30 );
		//pointLight.position.set( 5, 0, 0 );
		//_scene.add( pointLight );

    console.log('renderer', _renderer);
    console.log('camera', _camera);
    console.log('scene', _scene);

    self.onEvent = function (e, out) {
      switch(e.k) {
        case 'SpawnArea'     :
          if (!!e.scene3d) spawnScene(e.objId, e.pos, e.scene3d);
          break;
        case 'SpawnTargetG1' :      
        case 'SpawnShip'     :
          if (!!e.obj3d) spawnObj(e.objId, e.pos, e.obj3d);
          break;
        case 'MoveObjTo'     : moveObjTo(e.objId, e.pos); break;
        case 'SpawnCube'     : spawnCube(); break;
        case 'Render'        : render(); break;
        case 'Start'         : out.push(start()); break;                               
        default :
         // pass
      }
    };

    var start = function() {
      spawnAxis();
      return evt.SetupDatGui(function(gui) {
          var f2 = gui.addFolder('Camera');
          f2.add(_camera.position, 'x').min(-300).max(300);
          f2.add(_camera.position, 'y').min(-300).max(300);
          f2.add(_camera.position, 'z').min(-300).max(300);
//          .onFinishChange(function(){
//            var e = evt.AskValueOf(timer.t(), 'scale', self, function(v) { return _params['scale'];});
//            _pending.push(e);
//    });

      });
    };

    var render = function() {
      //_cameraControl.update();
      //console.log(_scene, _camera);
      if (!!_cube) {
        _cube.rotation.x += 0.01;
        _cube.rotation.y += 0.02;
      }
      //console.log(_camera.position.z);
      // you need to update lookAt every frame
      if (!!_renderer && !!_scene && !!_camera) {
        _camera.lookAt(_scene.position);
        _renderer.render(_scene, _camera);
      }
    };
 
    var spawnAxis = function() {
      function v(x,y,z){ 
        return new THREE.Vector3(x,y,z); 
      } 
      var lineGeo = new THREE.Geometry();
      lineGeo.vertices.push(
        v(-500, 0, 0), v(500, 0, 0), v(50,0,0), v(45,5,0), v(50,0,0), v(45,-5,0),
        v(0, -500, 0), v(0, 500, 0), v(0,50,0), v(5,45,0), v(0,50,0), v(-5,45,0)
//        v(0, 0, -500), v(0, 0, 500), v(0,0,50), v(5,0,45), v(0,0,50), v(-5,0,45)
      );
      var lineMat = new THREE.LineBasicMaterial({
        color: 0x888888,
        lineWidth: 1
      });
      var line = new THREE.Line(lineGeo, lineMat);
      line.type = THREE.Lines;
      _scene.add(line);
    };
    var spawnObj = function(id, pos, obj3d) {
      console.log('create in renderer', id, pos, obj3d);
      obj3d.name = id;
      obj3d.position.x = pos.x;
      obj3d.position.y = pos.y;
      obj3d.position.z = 0.0;
      obj3d.rotation.z = pos.a;
      //var s = w/75;
      //mesh.scale.set(s, s, s);
      _scene.add(obj3d);
    };

    var spawnScene = function(id, pos, scene3d) {
      console.log(scene3d);
      //_camera = scene3d.cameras.Camera; // if exists, Camera is the id of the object
      //_scene.add(_camera);
      //_scene = scene3d.scene;
      console.log(scene3d.objects);
      _.each(scene3d.objects, function(obj3d) { _scene.add(obj3d); });
      _.each(scene3d.lights, function(light){ _scene.add(light); });

      var wall = scene3d.objects.wall;
      var vertices = wall.geometry.vertices;
      var areaBox = _.reduce(vertices, function(acc, v){
        acc.x0 = Math.min(acc.x0, v.x);
        acc.y0 = Math.min(acc.y0, v.y);
        acc.x1 = Math.max(acc.x1, v.x);
        acc.y1 = Math.max(acc.y1, v.y);
        return acc;
      }, {x0 : vertices[0].x, y0 : vertices[0].y, x1 : vertices[0].x, y1 : vertices[0].y});

      areaBox.x0 = areaBox.x0 * wall.scale.x + wall.position.x;
      areaBox.y0 = areaBox.y0 * wall.scale.y + wall.position.y;
      areaBox.x1 = areaBox.x1 * wall.scale.x + wall.position.x;
      areaBox.y1 = areaBox.y1 * wall.scale.y + wall.position.y;
  
      var areaObj = new THREE.Mesh( new THREE.PlaneGeometry( areaBox.x1 - areaBox.x0, areaBox.y1 - areaBox.y0 ), new THREE.MeshBasicMaterial( { color: 0xffaa00 } ) );
      areaObj.position.x = areaBox.x0 + (areaBox.x1 - areaBox.x0)/2;
      areaObj.position.y = areaBox.y0 + (areaBox.y1 - areaBox.y0)/2;
      areaObj.doubleSided = true;
      //TODO rotate x 90°
      console.log('areaObj', areaObj);
			_scene.add( areaObj );
      //spawnAxis();
    };
/*
    //TODO rewrite to use JSONLoader
    var Area = function(model) {
      var back = new THREE.Object3D();

      var fragments = models.findArea(model);
      fragments.forEach(function(fragment) {
        var geometry = new THREE.Geometry();
        //geometry.vertices = new Array<Vector3>();
        fragment.points.forEach(function(p) {
          geometry.vertices.push( new THREE.Vector3( new THREE.Vector3(p[0], p[1], 0) ));

          var color = new THREE.Color( 0xffffff );
          color.setHSV( 0.6, ( 200 + p[0] ) / 400, 1.0 );
          geometry.colors.push(color);
        });
        if (fragment.closed && fragment.points.length > 2) {
          var p = fragment.points[0];
          geometry.vertices.push( new THREE.Vector3( new THREE.Vector3(p[0], p[1], 0) ));
        }
        console.log(geometry.vertices);
        var material = new THREE.LineBasicMaterial( { color: 0xffffff, opacity: 1, linewidth: fragment.radius } );
        material.vertexColors = true;
        var line = new THREE.Line(geometry, material);
        back.add(line);
      });
      console.log(back);
      return back;
    };
    var spawnShip = function(id, model, pos) {
      console.log("create ship in renderer");
      var mesh = Ship(model);
      mesh.name = id;
      mesh.position.x = pos.x;
      mesh.position.y = pos.y;
      mesh.rotation.z = pos.a;
      //TODO mesh.ation = 
      _scene.add(mesh);
      console.log(mesh);
    };

*/
    /** @return {THREE.Object3D} */
/*    
    var Ship = function(model) {
      var geometry = new THREE.Geometry();
      var v = function(x, y, z ) {
        var b = new THREE.Vector3( new THREE.Vector3( x, y, z ) );
        geometry.vertices.push(b);
        return b;
      }
      var f3 = function( a, b, c ) {
        geometry.faces.push( new THREE.Face3( a, b, c ) );
      }
      var v0 = v(   20,   0,   0 );
      var v1 = v(  -10,  -10,   0 );
      var v2 = v(  -10,   10,   0 );
      var v3 = v(   0,   0,   10 );
      f3( 0, 1, 2 );
      f3( 1, 0, 3 );
      f3( 0, 2, 3 );
      f3( 1, 3, 2 );

      geometry.computeCentroids();
      geometry.computeFaceNormals();

      geometry.computeVertexNormals();

      //var material = new THREE.MeshNormalMaterial();
      var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
      var mesh = new THREE.Mesh(geometry, material);
      //var s = w/75;
      //mesh.scale.set(s, s, s);
      return mesh; 
    };
*/
    var moveObjTo = function(objId, pos) {
      var obj = _scene.getChildByName(objId, false);
      if (obj != null) {
        obj.position.x = pos.x;
        obj.position.y = pos.y;
        obj.rotation.z = pos.a;
      }
    };

    var spawnCube = function() {
      _cube = Cube(w/50);
      _scene.add(_cube);
/*      
      models.find('plan', function(geometry) {
        var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe:  false} );
        var obj3d = new THREE.Mesh( geometry, material );
        console.log('spawn plan.js', obj3d);
        _scene.add(obj3d);
      });
      models.find('ship01', function(geometry) {
        //var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
        var material = new THREE.MeshNormalMaterial();
        var obj3d = new THREE.Mesh( geometry, material );
        console.log('spawn ship01.js', obj3d);
        _scene.add(obj3d);
      });      
*/      
    };

    var Cube = function(s) {
      var geometry = new THREE.CubeGeometry( s, s, s );
      var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
      return new THREE.Mesh( geometry, material );
    };
  
    var spawnTargetG1 = function(id, pos) {
      var geometry = new THREE.Geometry();
      var sprite = THREE.ImageUtils.loadTexture( "_images/sprites/disc.png" );

      var x = 0; //2000 * Math.random() - 1000;
      var y = 0; //2000 * Math.random() - 1000;
      var z = 0; //2000 * Math.random() - 1000;
      var vector = new THREE.Vector3( x, y, z );
      geometry.vertices.push( new THREE.Vector3( vector ) );

      var material = new THREE.ParticleBasicMaterial( { size: 10, sizeAttenuation: false, map: sprite } );
      material.color.setHSV( 1.0, 0.2, 0.8 );
      var obj = new THREE.ParticleSystem( geometry, material );
      //particles.sortParticles = true;
      /*
      function particleRender( context ) {
         
        // we get passed a reference to the canvas context
        context.beginPath();
        // and we just have to    draw our shape at 0,0 - in this
        // case an arc from 0 to 2Pi radians ourr 360º - a full circle!
        context.arc( 0, 0, 1, 0,  Math.PI * 2, true );
        context.fill();
      };
      
      console.log("create targetG1 in renderer");
      // we make a particle material and pass through the 
      // colour and custom particle render function we defined. 
      var material = new THREE.ParticleCanvasMaterial( { color: 0xffffff, program: particleRender } );
      // make the particle
      var obj = new THREE.Particle(material);
       
      // scale it up        a bit
      obj.scale.x = obj.scale.y = 100;
      */
      obj.name = id;
      obj.position.x = pos.x;
      obj.position.y = pos.y;
      obj.position.z = 0;
      obj.rotation.z = pos.a;
      _scene.add(obj);
    };

    return self;
  };
});
