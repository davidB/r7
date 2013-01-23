define(
  ['THREE', 'console', 'r7/evt', 'webglDetector', 'underscore', 'r7/cameraMode2D'],
  (THREE, console, evt, webglDetector, _, cameraConstraint) ->
    (container, context) ->

      _scene = new THREE.Scene()
      _devMode = false
      _areaBox = null
      _cameraTargetObjId = null
      #_camera = new THREE.PerspectiveCamera(75, 1, 1, 500)
      _camera = new THREE.OrthographicCamera(10,10,10,10, 1, 1000)
      #_camera =  new THREE.CombinedCamera(-20, -20, 45, 1, 500, 1, 1000)
      #_camera.toOrthographic()
      _camera.gameDriven = true
      #HACK to clean
      #see http://help.dottoro.com/ljorlllt.php
      nLookAt = (camera, v3) ->
        dx = ( (cmove.x + cmove.deltaX) / container.clientWidth - 0.5 ) * 100
        dy =- ( (cmove.y + cmove.deltaY) / container.clientHeight - 0.5 ) * 100
        camera.position.z = v3.z + 30
        camera.position.y = v3.y + dy
        camera.position.x = v3.x + dx
        camera.lookAt(v3)


      cmove = {
        offsetX : -1
        offsetY : -1
        deltaX : 0
        deltaY : 0
        x : container.clientWidth / 2
        y : container.clientHeight / 2
      }
      container.addEventListener( 'mousemove', (evt) ->
        cmove.deltaX = evt.clientX - cmove.offsetX if (cmove.offsetX > -1)
        cmove.deltaY = evt.clientY - cmove.offsetY if (cmove.offsetY > -1)
      , false )
      container.addEventListener( 'mousedown', (evt) ->
        cmove.offsetX = evt.clientX
        cmove.offsetY = evt.clientY
      , false)
      container.addEventListener( 'mouseup', (evt) ->
        cmove.offsetX = -1
        cmove.offsetY = -1
        cmove.x = cmove.x + cmove.deltaX
        cmove.y = cmove.y + cmove.deltaY
        cmove.deltaX = 0
        cmove.deltaY = 0
      , false)
      nLookAt(_camera, _scene.position)
      _scene.add(_camera)
      #_cameraControls = new THREE.DragPanControls(_camera)

      _renderer = if webglDetector.webgl
        _renderer = new THREE.WebGLRenderer({
          clearAlpha: 1
          antialias: true
          #preserveDrawingBuffer: true # to allow screenshot
        })

      #_renderer.shadowMapEnabled = true;
      #_renderer.shadowMapSoft = true;
      else

        #TODO display message if Webgl required
        _renderer = new THREE.CanvasRenderer()

      _renderer.shadowMapEnabled = true
      #_renderer.shadowMapSoft = true # to antialias the shadow
      _renderer.shadowMapType = THREE.PCFShadowMap
      _renderer.setClearColorHex(0xEEEEEE, 1.0)
      _renderer.autoClear = false
      _renderer.clear()

      updateViewportSize = (event) ->
        w = container.clientWidth #window.innerWidth
        h = container.clientHeight #window.innerHeight
        _renderer.setSize(w, h)
        _camera.aspect = w /  h
        unitperpixel = 0.1
        _camera.left = w / -2 * unitperpixel
        _camera.right = w / 2 * unitperpixel
        _camera.top = h /2 * unitperpixel
        _camera.bottom = h / -2 * unitperpixel
        _camera.updateProjectionMatrix()
        #_controls.handleResize()

      updateViewportSize()
      container.appendChild(_renderer.domElement)
      window.addEventListener( 'resize', updateViewportSize, false )

      # Lights
      #_scene.add( new THREE.AmbientLight( 0xFFFFFF ) );
      #
      #    var light = new THREE.DirectionalLight(0xFFFFFF);  // changed to directional light - easier as a first step
      #    light.position.set(0, 0, 200).normalize(); // for directional lights, position is actually a direction vector
      #    _scene.add(light);
      #
      #var pointLight = new THREE.PointLight( 0xffffff, 5, 30 );
      #pointLight.position.set( 5, 0, 0 );
      #_scene.add( pointLight );
      #
      self.onEvent = (e, out) ->
        switch e.k
          when 'DevMode'
            _devMode = true
          when "Start"
            #TODO initialize/reset
            e1 = start()
            out.push(e1) if e1?
          when "Render"
            render()
          when "SetLocalDroneId"
            _cameraTargetObjId = e.objId
          when "SpawnArea"
            spawnObj(e.objId, e.pos, e.gpof)
            #spawnScene(e.objId, e.pos, e.scene3d)
          when "SpawnObj"
            spawnObj(e.objId, e.pos, e.gpof, e.options)
          when "MoveObjTo"
            moveObjTo(e.objId, e.pos)
          when "DespawnObj"
            despawnObj(e.objId, e.options)
          else
            # pass
      start = ->
        addLights(_scene, _camera)
        if (_devMode)
          evt.SetupDatGui((gui) ->
            f2 = gui.addFolder("Camera")
            f2.add(_camera, "gameDriven")
            f2.add(_camera.position, "x").listen()
            f2.add(_camera.position, "y").listen()
            f2.add(_camera.position, "z").listen()
            f2.add(_camera, "fov").listen() if _camera.fov?
            f2.add(_camera, "inPerspectiveMode").onFinishChange((value) ->
              updateViewportSize()
            ) if _camera.inPerspectiveMode?
            gui.remember(_camera)
          )
        else
          null

        #_controls = new THREE.FirstPersonControls( _camera, container )
        #_controls.movementSpeed = 10
        #_controls.lookSpeed = 0.125
        #_controls.lookVertical = true
        #_controls.constrainVertical = true
        #_controls.verticalMin = 1.1
        #_controls.verticalMax = 2.2

      #          .onFinishChange(function(){
      #            var e = evt.AskValueOf(timer.t(), 'scale', self, function(v) { return _params['scale'];});
      #            _pending.push(e);
      #    });
      #
      #      controls = new THREE.TrackballControls(_camera)
      #      controls.rotateSpeed = 1.0
      #      controls.zoomSpeed = 1.2
      #      controls.panSpeed = 0.8
      #      controls.noZoom = false
      #      controls.noPan = false
      #      controls.staticMoving = true
      #      controls.dynamicDampingFactor = 0.3
      #      controls.keys = [65, 83, 68]

      #controls.addEventListener( 'change', render );
      #_cameraControls = controls
      render = ->
        # you need to update lookAt every frame
        if !!_renderer and !!_scene and !!_camera and !!_cameraTargetObjId

          #TODO optim apply cameraCoinstraint only on MoveObjectTo,...
          obj = _scene.getChildByName(_cameraTargetObjId, false)

          #
          #if (!!obj && !!_areaBox)
          #  cameraConstraint(obj.position, _camera.position.z, _camera, _areaBox)
          #else
          #  _camera.lookAt(_scene.position)
          #        }
          #
          #_cameraControls.update()
          nLookAt(_camera, obj.position) if obj? and _camera.gameDriven
          _renderer.clear()
          _renderer.render(_scene, _camera)

      addLights = (scene, camera) ->
        ambient= new THREE.AmbientLight( 0x444444 )
        scene.add(ambient)

        light = new THREE.SpotLight( 0xffffff, 1, 0, Math.PI, 1 )
        light.position.set( 0, 10, 100 )
        light.target.position.set( 0, 0, 0 )

        light.castShadow = true

        light.shadowCameraNear = 700
        light.shadowCameraFar = camera.far
        light.shadowCameraFov = 50

        light.shadowCameraVisible = _devMode

        light.shadowBias = 0.0001
        light.shadowDarkness = 0.5

        light.shadowMapWidth = 128
        light.shadowMapHeight = 128

        scene.add(light)

        mainlight = new THREE.DirectionalLight( 0xffffff )
        #shadow stuff
        mainlight.shadowCameraNear = 10
        mainlight.shadowCameraFar = 500

        mainlight.castShadow = true
        mainlight.shadowDarkness = 0.5
        mainlight.shadowCameraVisible = true
        mainlight.shadowMapWidth = 2048
        mainlight.shadowMapHeight = 2048
        mainlight.target = _scene
        mainlight.position.set(0,-10,50)
        mainlight.rotation.set(0,-0.5,1) #setting elevation and azimuth via mainlight's parent

        #group
        lights = new THREE.Object3D()
        lights.name = "lights"

        lights.add( mainlight ) #adding mainlight as child to lightTarget (easy rotation controls via parent)
        lights.add( ambient )
        lights

      #TODO support spawn animation
      spawnObj = (id, pos, gpof, options) ->
        return if !(gpof? && gpof.obj3dF?)
        ids = id.split('>')
        parent = _scene
        i = 0
        while(i< (ids.length - 1))
          if (parent?)
            parent = parent.getChildByName(ids[i], false)
          else
            console.warn("parent not found", id, ids[i])
          i++
        return if ! parent?
        name = ids[ids.length - 1]
        obj = parent.getChildByName(name, false)
        if obj?
          console.warn("ignore spawnObj with exiting id", id, obj)

  #console.trace();
          return
        obj = gpof.obj3dF(options)
        obj.name = name
        obj.position.x = pos.x
        obj.position.y = pos.y
        #obj.position.z = 0.0
        obj.rotation.z = pos.a
        parent.add(obj)
        obj.anims = gpof.anims #clone ?
        obj.anims.spawn?(obj, null, options)

      #TODO support despawn animation
      despawnObj = (id, options) ->
        obj = _scene.getChildByName(id, false)
        if obj?
          anim = obj.anims.despawn
          if anim?
            anim(obj, ((obj)-> _scene.remove(obj)), options)
          else
            _scene.remove(obj)

      spawnScene = (id, pos, scene3d) ->

        #_camera = scene3d.cameras.Camera; // if exists, Camera is the id of the object
        #_scene.add(_camera);
        #_scene = scene3d.scene;
        _.each(scene3d.objects, (obj3d) ->

          #obj3d.castShadow = false;
          #obj3d.receiveShadow  = false;
          _scene.add(obj3d)
        )
        _.each(scene3d.lights, (light) ->
          light.castShadow = true
          _scene.add(light)
        )
        wall = scene3d.objects.wall
        updateAreaBox(wall.geometry.vertices, wall.scale, wall.position)

      updateAreaBox = (vertices, scale, position) ->
        _areaBox = _.reduce(vertices, (acc, v) ->
          acc.xmin = Math.min(acc.xmin, v.x)
          acc.ymin = Math.min(acc.ymin, v.y)
          acc.xmax = Math.max(acc.xmax, v.x)
          acc.ymax = Math.max(acc.ymax, v.y)
          acc
        ,{
          xmin: vertices[0].x
          ymin: vertices[0].y
          xmax: vertices[0].x
          ymax: vertices[0].y
        })
        _areaBox.xmin = _areaBox.xmin * scale.x + position.x
        _areaBox.ymin = _areaBox.ymin * scale.y + position.y
        _areaBox.xmax = _areaBox.xmax * scale.x + position.x
        _areaBox.ymax = _areaBox.ymax * scale.y + position.y
        console.debug("_areaBox", _areaBox)
        _areaBox


      #
      #      var areaObj = new THREE.Mesh( new THREE.PlaneGeometry( _areaBox.xmax - _areaBox.xmin, _areaBox.ymax - _areaBox.ymin ), new THREE.MeshBasicMaterial( { color: 0xffaa00 } ) );
      #      areaObj.position.x = _areaBox.xmin + (_areaBox.xmax - _areaBox.xmin)/2;
      #      areaObj.position.y = _areaBox.ymax - (_areaBox.ymax - _areaBox.ymin)/2;
      #      areaObj.position.z = -1; //vertices[0].z - 0.01;
      #      areaObj.doubleSided = true;
      #      //TODO rotate x 90°
      #      areaObj.rotation.x = Math.PI/2;
      #			_scene.add( areaObj );
      #

      #
      #    //TODO rewrite to use JSONLoader
      #    var Area = function(model) {
      #      var back = new THREE.Object3D();
      #
      #      var fragments = models.findArea(model);
      #      fragments.forEach(function(fragment) {
      #        var geometry = new THREE.Geometry();
      #        //geometry.vertices = new Array<Vector3>();
      #        fragment.points.forEach(function(p) {
      #          geometry.vertices.push( new THREE.Vector3( new THREE.Vector3(p[0], p[1], 0) ));
      #
      #          var color = new THREE.Color( 0xffffff );
      #          color.setHSV( 0.6, ( 200 + p[0] ) / 400, 1.0 );
      #          geometry.colors.push(color);
      #        });
      #        if (fragment.closed && fragment.points.length > 2) {
      #          var p = fragment.points[0];
      #          geometry.vertices.push( new THREE.Vector3( new THREE.Vector3(p[0], p[1], 0) ));
      #        }
      #        console.log(geometry.vertices);
      #        var material = new THREE.LineBasicMaterial( { color: 0xffffff, opacity: 1, linewidth: fragment.radius } );
      #        material.vertexColors = true;
      #        var line = new THREE.Line(geometry, material);
      #        back.add(line);
      #      });
      #      console.log(back);
      #      return back;
      #    };
      #    var spawnShip = function(id, model, pos) {
      #      console.log("create ship in renderer");
      #      var mesh = Ship(model);
      #      mesh.name = id;
      #      mesh.position.x = pos.x;
      #      mesh.position.y = pos.y;
      #      mesh.rotation.z = pos.a;
      #      //TODO mesh.ation =
      #      _scene.add(mesh);
      #      console.log(mesh);
      #    };
      #
      #

      ###
      @return {THREE.Object3D}
      ###

      #
      #    var Ship = function(model) {
      #      var geometry = new THREE.Geometry();
      #      var v = function(x, y, z ) {
      #        var b = new THREE.Vector3( new THREE.Vector3( x, y, z ) );
      #        geometry.vertices.push(b);
      #        return b;
      #      }
      #      var f3 = function( a, b, c ) {
      #        geometry.faces.push( new THREE.Face3( a, b, c ) );
      #      }
      #      var v0 = v(   20,   0,   0 );
      #      var v1 = v(  -10,  -10,   0 );
      #      var v2 = v(  -10,   10,   0 );
      #      var v3 = v(   0,   0,   10 );
      #      f3( 0, 1, 2 );
      #      f3( 1, 0, 3 );
      #      f3( 0, 2, 3 );
      #      f3( 1, 3, 2 );
      #
      #      geometry.computeCentroids();
      #      geometry.computeFaceNormals();
      #
      #      geometry.computeVertexNormals();
      #
      #      //var material = new THREE.MeshNormalMaterial();
      #      var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
      #      var mesh = new THREE.Mesh(geometry, material);
      #      //var s = w/75;
      #      //mesh.scale.set(s, s, s);
      #      return mesh;
      #    };
      #
      moveObjTo = (objId, pos) ->
        obj = _scene.getChildByName(objId, false)
        if obj isnt null and typeof obj isnt "undefined"
          obj.position.x = pos.x
          obj.position.y = pos.y
          obj.rotation.z = pos.a


      #
      #      models.find('plan', function(geometry) {
      #        var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe:  false} );
      #        var obj3d = new THREE.Mesh( geometry, material );
      #        console.log('spawn plan.js', obj3d);
      #        _scene.add(obj3d);
      #      });
      #      models.find('ship01', function(geometry) {
      #        //var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );
      #        var material = new THREE.MeshNormalMaterial();
      #        var obj3d = new THREE.Mesh( geometry, material );
      #        console.log('spawn ship01.js', obj3d);
      #        _scene.add(obj3d);
      #      });
      #

      #
      #    var spawnTargetG1 = function(id, pos) {
      #      var geometry = new THREE.Geometry();
      #      var sprite = THREE.ImageUtils.loadTexture( "_images/sprites/disc.png" );
      #
      #      var x = 0; //2000 * Math.random() - 1000;
      #      var y = 0; //2000 * Math.random() - 1000;
      #      var z = 0; //2000 * Math.random() - 1000;
      #      var vector = new THREE.Vector3( x, y, z );
      #      geometry.vertices.push( new THREE.Vector3( vector ) );
      #
      #      var material = new THREE.ParticleBasicMaterial( { size: 10, sizeAttenuation: false, map: sprite } );
      #      material.color.setHSV( 1.0, 0.2, 0.8 );
      #      var obj = new THREE.ParticleSystem( geometry, material );
      #      //particles.sortParticles = true;
      #
      #      function particleRender( context ) {
      #
      #        // we get passed a reference to the canvas context
      #        context.beginPath();
      #        // and we just have to    draw our shape at 0,0 - in this
      #        // case an arc from 0 to 2Pi radians ourr 360º - a full circle!
      #        context.arc( 0, 0, 1, 0,  Math.PI * 2, true );
      #        context.fill();
      #      };
      #
      #      console.log("create targetG1 in renderer");
      #      // we make a particle material and pass through the
      #      // colour and custom particle render function we defined.
      #      var material = new THREE.ParticleCanvasMaterial( { color: 0xffffff, program: particleRender } );
      #      // make the particle
      #      var obj = new THREE.Particle(material);
      #
      #      // scale it up        a bit
      #      obj.scale.x = obj.scale.y = 100;
      #
      #      obj.name = id;
      #      obj.position.x = pos.x;
      #      obj.position.y = pos.y;
      #      obj.position.z = 0;
      #      obj.rotation.z = pos.a;
      #      _scene.add(obj);
      #    };
      #
      self
)
